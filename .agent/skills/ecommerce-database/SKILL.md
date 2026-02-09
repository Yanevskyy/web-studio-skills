---
name: ecommerce-database
description: "Use when designing a database for an online store. Schemas for products, orders, users. Prisma + Supabase patterns."
---

# E-commerce Database Design

## When to use

**WHEN STARTING AN E-COMMERCE PROJECT** — design the DB before writing code.

---

## Recommended Stack

- **ORM:** Prisma
- **Database:** Supabase (PostgreSQL) or PlanetScale (MySQL)
- **Auth:** Supabase Auth or NextAuth.js

---

## Prisma Installation

```bash
npm install prisma @prisma/client
npx prisma init
```

---

## Database Schema

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============ USERS ============

model User {
  id        String   @id @default(cuid())
  email     String   @unique
  name      String?
  phone     String?
  role      Role     @default(CUSTOMER)
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  
  orders    Order[]
  addresses Address[]
  cart      CartItem[]
}

enum Role {
  CUSTOMER
  ADMIN
}

model Address {
  id        String  @id @default(cuid())
  userId    String
  user      User    @relation(fields: [userId], references: [id])
  
  firstName String
  lastName  String
  street    String
  city      String
  state     String?
  zip       String
  country   String
  isDefault Boolean @default(false)
}

// ============ PRODUCTS ============

model Category {
  id       String    @id @default(cuid())
  name     String
  slug     String    @unique
  image    String?
  products Product[]
}

model Product {
  id          String   @id @default(cuid())
  name        String
  slug        String   @unique
  description String?
  price       Decimal  @db.Decimal(10, 2)
  comparePrice Decimal? @db.Decimal(10, 2) // strikethrough price
  sku         String?  @unique
  stock       Int      @default(0)
  isActive    Boolean  @default(true)
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  categoryId  String?
  category    Category? @relation(fields: [categoryId], references: [id])
  
  images      ProductImage[]
  variants    ProductVariant[]
  orderItems  OrderItem[]
  cartItems   CartItem[]
}

model ProductImage {
  id        String  @id @default(cuid())
  url       String
  alt       String?
  position  Int     @default(0)
  productId String
  product   Product @relation(fields: [productId], references: [id], onDelete: Cascade)
}

model ProductVariant {
  id        String  @id @default(cuid())
  name      String  // "Red / L"
  sku       String? @unique
  price     Decimal @db.Decimal(10, 2)
  stock     Int     @default(0)
  productId String
  product   Product @relation(fields: [productId], references: [id], onDelete: Cascade)
}

// ============ CART ============

model CartItem {
  id        String  @id @default(cuid())
  quantity  Int     @default(1)
  
  userId    String
  user      User    @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  productId String
  product   Product @relation(fields: [productId], references: [id])
  
  variantId String?
  
  @@unique([userId, productId, variantId])
}

// ============ ORDERS ============

model Order {
  id              String      @id @default(cuid())
  orderNumber     String      @unique
  status          OrderStatus @default(PENDING)
  
  subtotal        Decimal     @db.Decimal(10, 2)
  shipping        Decimal     @db.Decimal(10, 2)
  tax             Decimal     @db.Decimal(10, 2)
  total           Decimal     @db.Decimal(10, 2)
  
  // Stripe
  stripeSessionId String?
  stripePaymentId String?
  
  // Shipping address (copy, not reference)
  shippingName    String
  shippingStreet  String
  shippingCity    String
  shippingZip     String
  shippingCountry String
  
  createdAt       DateTime    @default(now())
  updatedAt       DateTime    @updatedAt
  
  userId          String
  user            User        @relation(fields: [userId], references: [id])
  
  items           OrderItem[]
}

enum OrderStatus {
  PENDING
  PAID
  PROCESSING
  SHIPPED
  DELIVERED
  CANCELLED
  REFUNDED
}

model OrderItem {
  id        String  @id @default(cuid())
  quantity  Int
  price     Decimal @db.Decimal(10, 2) // price at time of purchase
  
  orderId   String
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  
  productId String
  product   Product @relation(fields: [productId], references: [id])
  
  variantName String? // store variant name
}
```

---

## Migrations

```bash
# Create migration
npx prisma migrate dev --name init

# Apply in production
npx prisma migrate deploy

# Generate client
npx prisma generate
```

---

## Prisma Client

```ts
// lib/prisma.ts
import { PrismaClient } from '@prisma/client'

const globalForPrisma = globalThis as unknown as { prisma: PrismaClient }

export const prisma = globalForPrisma.prisma || new PrismaClient()

if (process.env.NODE_ENV !== 'production') globalForPrisma.prisma = prisma
```

---

## Example Queries

```ts
// Get products with category
const products = await prisma.product.findMany({
  where: { isActive: true },
  include: {
    category: true,
    images: { orderBy: { position: 'asc' } },
  },
})

// Create order
const order = await prisma.order.create({
  data: {
    orderNumber: `ORD-${Date.now()}`,
    userId: user.id,
    subtotal: 100,
    shipping: 10,
    tax: 0,
    total: 110,
    shippingName: 'John Doe',
    // ...remaining fields
    items: {
      create: cartItems.map(item => ({
        productId: item.productId,
        quantity: item.quantity,
        price: item.product.price,
      })),
    },
  },
})
```

---

## Checklist

- [ ] Prisma installed
- [ ] DATABASE_URL in env
- [ ] Schema created
- [ ] Migrations applied
- [ ] Prisma Client generated
- [ ] Basic CRUD operations working
