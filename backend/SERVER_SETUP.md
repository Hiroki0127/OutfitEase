# OutfitEase Server Setup Guide

## 🚀 Quick Start

Your OutfitEase server is now ready for testing! Here's everything you need to know:

### Current Status ✅
- **Server**: Running on http://localhost:3000
- **Database**: PostgreSQL running via Docker (port 5432)
- **Authentication**: Working with test credentials
- **All Major Endpoints**: Functional and tested

## 📋 Prerequisites

1. **Docker Desktop** - For PostgreSQL database
2. **Node.js** - For running the Express.js server
3. **Environment File** - `.env` file with credentials

## 🔧 Setup Steps

### 1. Create Environment File
Create `backend/.env` file with:
```env
DATABASE_URL=postgresql://hiroki:Usausa127%21@localhost:5432/outfitease
PORT=3000
JWT_SECRET=your_jwt_secret_key_here
CLOUDINARY_CLOUD_NAME=dloz83z8m
CLOUDINARY_API_KEY=575187126515995
CLOUDINARY_API_SECRET=am0RWpW9f4gzZnmMjy4vZnqHBGM
```

### 2. Start Database
```bash
cd /Users/hiro/OutfitEase
docker-compose up -d
```

### 3. Start Server
```bash
cd backend
npm start
```

### 4. Run Tests
```bash
node test-server.js
```

## 🧪 Test Credentials

- **Email**: test@example.com
- **Password**: password
- **User ID**: 284a936e-6c26-455c-bf38-72887c76a0c5

## 📊 Available Data

### Clothing Items: 3 items
- Test test (Shirt)
- Test (Pants)
- Blue T-Shirt (Shirt)

### Outfits: 8 outfits
- Test kid
- Summer Night Out
- Hello
- Evening Outfit
- Casual Weekend Look
- And more...

### Posts: 5 posts
- Community posts with captions
- Some with associated outfits

### Planning: 19 planned outfits
- Calendar-based outfit planning data

## 🔗 API Endpoints

### Authentication
- `POST /auth/login` - User login
- `POST /auth/register` - User registration

### Clothing Management
- `GET /clothes` - Get user's clothing items
- `POST /clothes` - Add new clothing item
- `PUT /clothes/:id` - Update clothing item
- `DELETE /clothes/:id` - Delete clothing item

### Outfits
- `GET /outfits` - Get user's outfits
- `POST /outfits` - Create new outfit
- `PUT /outfits/:id` - Update outfit
- `DELETE /outfits/:id` - Delete outfit

### Community
- `GET /posts` - Get community posts
- `POST /posts` - Create new post
- `GET /comments` - Get comments
- `POST /comments` - Add comment

### Planning
- `GET /planning` - Get planned outfits
- `POST /planning` - Plan new outfit

### Upload
- `POST /upload` - Upload images to Cloudinary

## 🧪 Testing Commands

### Quick Server Test
```bash
curl http://localhost:3000
```

### Authentication Test
```bash
node test-auth.js
```

### Comprehensive Test
```bash
node test-server.js
```

### Manual API Testing
```bash
# Login
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password"}'

# Get clothes (use token from login)
curl -H "Authorization: Bearer YOUR_TOKEN" \
  http://localhost:3000/clothes
```

## 🐛 Troubleshooting

### Server won't start
1. Check if port 3000 is available
2. Verify `.env` file exists
3. Ensure all dependencies are installed: `npm install`

### Database connection issues
1. Check if Docker is running
2. Verify database container is up: `docker ps`
3. Restart database: `docker-compose down && docker-compose up -d`

### Authentication fails
1. Verify test credentials are correct
2. Check JWT_SECRET in `.env` file
3. Ensure database has test data

## 📱 iOS App Configuration

Your iOS app should be configured to connect to:
- **Base URL**: http://127.0.0.1:3000
- **Test User**: test@example.com / password

## 🎯 Next Steps

1. **Test iOS App**: Open your iOS app and test all features
2. **Add More Test Data**: Use the scripts in `/scripts` folder
3. **Monitor Logs**: Check `server.log` for any issues
4. **API Testing**: Use tools like Postman for detailed API testing

## 📁 Useful Files

- `test-server.js` - Comprehensive server testing
- `test-auth.js` - Authentication testing
- `quick-start.sh` - Automated setup script
- `scripts/setupTestData.js` - Populate test data
- `scripts/checkUserData.js` - Verify user data

---

**Server Status**: ✅ Ready for testing
**Last Updated**: $(date)
