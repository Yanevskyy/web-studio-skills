---
name: ecommerce-database
description: "Используй при проектировании БД для интернет-магазина. Схемы для товаров, заказов, пользователей. Prisma + Supabase паттерны."
---

# E-commerce Database Design

## Когда использовать

**ПРИ СТАРТЕ E-COMMERCE ПРОЕКТА** — спроектируй БД до написания кода.

---

## Рекомендуемый стек

- **ORM:** Prisma
- **Database:** Supabase (PostgreSQL) или PlanetScale (MySQL)
- **Auth:** Supabase Auth или NextAuth.js

---

## Установка Prisma

```bash
npm install prisma @prisma/client
npx prisma init
```

---

## Схема базы данных

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// ============ ПОЛЬЗОВАТЕЛИ ============

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

// ============ ТОВАРЫ ============

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
  comparePrice Decimal? @db.Decimal(10, 2) // зачёркнутая цена
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
  name      String  // "Красный / L"
  sku       String? @unique
  price     Decimal @db.Decimal(10, 2)
  stock     Int     @default(0)
  productId String
  product   Product @relation(fields: [productId], references: [id], onDelete: Cascade)
}

// ============ КОРЗИНА ============

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

// ============ ЗАКАЗЫ ============

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
  
  // Адрес доставки (копия, не ссылка)
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
  price     Decimal @db.Decimal(10, 2) // цена на момент покупки
  
  orderId   String
  order     Order   @relation(fields: [orderId], references: [id], onDelete: Cascade)
  
  productId String
  product   Product @relation(fields: [productId], references: [id])
  
  variantName String? // сохраняем название варианта
}
```

---

## Миграции

```bash
# Создать миграцию
npx prisma migrate dev --name init

# Применить на production
npx prisma migrate deploy

# Сгенерировать клиент
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

## Примеры запросов

```ts
// Получить товары с категорией
const products = await prisma.product.findMany({
  where: { isActive: true },
  include: {
    category: true,
    images: { orderBy: { position: 'asc' } },
  },
})

// Создать заказ
const order = await prisma.order.create({
  data: {
    orderNumber: `ORD-${Date.now()}`,
    userId: user.id,
    subtotal: 100,
    shipping: 10,
    tax: 0,
    total: 110,
    shippingName: 'John Doe',
    // ...остальные поля
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

## Чеклист

- [ ] Prisma установлен
- [ ] DATABASE_URL в env
- [ ] Схема создана
- [ ] Миграции применены
- [ ] Prisma Client сгенерирован
- [ ] Базовые CRUD операции работают
