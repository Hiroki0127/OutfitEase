#!/bin/bash

echo "🚀 Starting OutfitEase Local Server"
echo "===================================="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "🐳 Docker is not running. Please start Docker Desktop first."
    echo "   Then run this script again."
    exit 1
fi

# Start database
echo "🗄️  Starting PostgreSQL database..."
cd "$(dirname "$0")"
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Start server
echo "🖥️  Starting backend server on http://localhost:3000"
cd backend
npm start

