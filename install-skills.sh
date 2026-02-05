#!/bin/bash
# install-skills.sh
# Установка Web Studio Skills в текущий проект

set -e

REPO_URL="https://github.com/yourusername/web-studio-skills/archive/main.tar.gz"

echo "📦 Downloading Web Studio Skills..."

# Скачать и распаковать
curl -sL "$REPO_URL" | tar xz

# Переместить .agent
if [ -d ".agent" ]; then
    echo "⚠️  .agent directory already exists. Merging skills..."
    cp -r web-studio-skills-main/.agent/skills/* .agent/skills/
else
    mv web-studio-skills-main/.agent .
fi

# Очистка
rm -rf web-studio-skills-main

echo "✅ Skills installed successfully!"
echo ""
echo "Installed skills:"
ls -1 .agent/skills/
