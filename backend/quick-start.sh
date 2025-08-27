#!/bin/bash

echo "🚀 OutfitEase Server Quick Start"
echo "================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "🐳 Starting Docker..."
    open -a Docker
    echo "⏳ Waiting for Docker to start..."
    sleep 15
fi

# Start database
echo "🗄️ Starting PostgreSQL database..."
cd /Users/hiro/OutfitEase
docker-compose up -d

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 5

# Check if .env file exists
if [ ! -f "backend/.env" ]; then
    echo "⚠️ .env file not found. Please create backend/.env with:"
    echo ""
    echo "DATABASE_URL=postgresql://hiroki:Usausa127%21@localhost:5432/outfitease"
    echo "PORT=3000"
    echo "JWT_SECRET=your_jwt_secret_key_here"
    echo "CLOUDINARY_CLOUD_NAME=dloz83z8m"
    echo "CLOUDINARY_API_KEY=575187126515995"
    echo "CLOUDINARY_API_SECRET=am0RWpW9f4gzZnmMjy4vZnqHBGM"
    echo ""
    echo "Press Enter when you've created the .env file..."
    read
fi

# Start server
echo "🖥️ Starting backend server..."
cd backend
npm start
