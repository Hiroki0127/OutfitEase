# OutfitEase Backend

A Node.js/Express backend API for the OutfitEase fashion application, providing comprehensive endpoints for user management, clothing items, outfits, community features, and weather integration.

## Features

### Authentication & User Management
- JWT-based authentication
- User registration and login
- Role-based access control
- Secure password hashing

### Clothing Management
- CRUD operations for clothing items
- Image upload via Cloudinary
- Categorization by type, color, style, brand, season, and occasion
- Search and filtering capabilities

### Outfit Management
- Create and manage outfits
- Associate clothing items with outfits
- Outfit planning and scheduling
- Save and unsave outfits

### Community Features
- Post creation and management
- Like and unlike posts
- Comment system
- User interaction tracking

### Weather Integration
- Real-time weather data
- Weather-based outfit suggestions
- Location-based recommendations

## Architecture

- **Framework**: Express.js
- **Database**: PostgreSQL with pg library
- **Authentication**: JWT tokens
- **File Storage**: Cloudinary
- **Weather API**: OpenWeatherMap
- **Architecture Pattern**: MVC (Model-View-Controller)

## Project Structure

```
backend/
├── app.js                 # Main application entry point
├── db.js                  # Database connection
├── config/               # Configuration files
│   └── cloudinary.js     # Cloudinary configuration
├── controllers/          # Route controllers
│   ├── authController.js
│   ├── clothesController.js
│   ├── commentsController.js
│   ├── likesController.js
│   ├── outfitPlanningController.js
│   ├── outfitsController.js
│   ├── postController.js
│   ├── savedOutfitsController.js
│   ├── uploadController.js
│   └── weatherController.js
├── middleware/           # Custom middleware
│   ├── authMiddleware.js
│   └── roleMiddleware.js
├── models/              # Database models
│   ├── clothesModel.js
│   ├── commentsModel.js
│   ├── likesModel.js
│   ├── outfitsModel.js
│   ├── planningModel.js
│   ├── postModel.js
│   └── savedOutfitsModel.js
├── routes/              # API routes
│   ├── auth.js
│   ├── clothes.js
│   ├── comments.js
│   ├── likes.js
│   ├── outfitPlanning.js
│   ├── outfits.js
│   ├── posts.js
│   ├── savedOutfits.js
│   ├── upload.js
│   └── weather.js
├── scripts/             # Utility scripts
│   ├── addMockPosts.js
│   ├── checkUserData.js
│   ├── cleanupOutfits.js
│   ├── cloudinaryTest.js
│   ├── resetHiroPassword.js
│   ├── setupTestData.js
│   ├── testCloudinary.js
│   ├── testCloudinarySimple.js
│   └── verifyCleanup.js
├── tests/               # Test files
│   └── comments.test.js
├── uploads/             # Temporary upload directory
├── schema.sql           # Database schema
├── package.json         # Dependencies and scripts
└── quick-start.sh       # Quick setup script
```

## Setup Instructions

### Prerequisites
- Node.js (v16 or higher)
- PostgreSQL (v12 or higher)
- Cloudinary account
- OpenWeatherMap API key

### Installation

1. **Clone the repository and navigate to backend**
   ```bash
   cd backend
   ```

2. **Install dependencies**
   ```bash
   npm install
   ```

3. **Set up environment variables**
   Create a `.env` file with the following variables:
   ```bash
   DATABASE_URL=postgresql://username:password@localhost:5432/outfitease
   JWT_SECRET=your_jwt_secret_here
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   OPENWEATHER_API_KEY=your_openweather_api_key
   PORT=3000
   NODE_ENV=development
   ```

4. **Set up the database**
   ```bash
   psql -U your_username -d your_database -f schema.sql
   ```

5. **Start the server**
   ```bash
   npm start
   ```

### Quick Start
Use the provided quick-start script:
```bash
chmod +x quick-start.sh
./quick-start.sh
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register a new user
- `POST /auth/login` - User login
- `GET /auth/profile` - Get user profile

### Clothing Items
- `GET /clothes` - Get user's clothing items
- `POST /clothes` - Create new clothing item
- `GET /clothes/:id` - Get specific clothing item
- `PUT /clothes/:id` - Update clothing item
- `DELETE /clothes/:id` - Delete clothing item

### Outfits
- `GET /outfits` - Get user's outfits
- `POST /outfits` - Create new outfit
- `GET /outfits/:id` - Get specific outfit
- `PUT /outfits/:id` - Update outfit
- `DELETE /outfits/:id` - Delete outfit
- `POST /outfits/bulk-delete` - Delete multiple outfits

### Saved Outfits
- `GET /saved-outfits` - Get user's saved outfits
- `POST /saved-outfits/:outfitId` - Save an outfit
- `DELETE /saved-outfits/:outfitId` - Unsave an outfit
- `GET /saved-outfits/check/:outfitId` - Check if outfit is saved

### Community Posts
- `GET /posts` - Get community posts
- `POST /posts` - Create new post
- `GET /posts/:id` - Get specific post
- `PUT /posts/:id` - Update post
- `DELETE /posts/:id` - Delete post

### Comments
- `GET /comments/:postId` - Get comments for a post
- `POST /comments` - Add comment to post
- `PUT /comments/:id` - Update comment
- `DELETE /comments/:id` - Delete comment

### Likes
- `POST /likes/:postId` - Like a post
- `DELETE /likes/:postId` - Unlike a post

### Outfit Planning
- `GET /planning` - Get user's outfit plans
- `POST /planning` - Create outfit plan
- `GET /planning/:date` - Get plans for specific date
- `PUT /planning/:id` - Update outfit plan
- `DELETE /planning/:id` - Delete outfit plan

### Weather
- `GET /weather/current` - Get current weather
- `GET /weather/forecast` - Get weather forecast
- `POST /weather/recommendations` - Get weather-based recommendations

### File Upload
- `POST /upload/image` - Upload image to Cloudinary

## Database Schema

The application uses PostgreSQL with the following main tables:

- **users**: User accounts and profiles
- **clothing_items**: Individual clothing pieces
- **outfits**: Complete outfit combinations
- **outfit_items**: Junction table for outfit-clothing relationships
- **outfit_planning**: Calendar-based outfit scheduling
- **posts**: Community shared outfits
- **comments**: Post comments
- **post_likes**: Post likes
- **saved_outfits**: User-saved outfits
- **weather_data**: Weather information for recommendations

## Testing

### Current Tests
- **Test Location**: `tests/`
- **Test File**: `comments.test.js` - Tests for comments functionality

### Running Tests
```bash
# From the backend directory
npm test
```

### Test Coverage
The backend includes basic test coverage for the comments functionality. Future enhancements will include:
- Comprehensive API endpoint testing
- Database model testing
- Authentication testing
- Error handling testing

## Scripts

The backend includes several utility scripts in the `scripts/` directory:

- **addMockPosts.js**: Add mock posts for testing
- **checkUserData.js**: Check user data in database
- **cleanupOutfits.js**: Clean up incorrectly created outfits
- **cloudinaryTest.js**: Test Cloudinary integration
- **resetHiroPassword.js**: Reset user password
- **setupTestData.js**: Set up test data
- **testCloudinary.js**: Test Cloudinary functionality
- **verifyCleanup.js**: Verify cleanup operations

## Error Handling

The application includes comprehensive error handling:
- HTTP status codes for different error types
- Detailed error messages for debugging
- Database constraint error handling
- File upload error handling
- Authentication error handling

## Security Features

- JWT token-based authentication
- Password hashing with bcrypt
- CORS configuration
- Input validation and sanitization
- SQL injection prevention
- File upload security

## Performance Optimizations

- Database connection pooling
- Efficient SQL queries with proper indexing
- Image optimization via Cloudinary
- Caching strategies for weather data
- Pagination for large datasets

## Development

### Development Mode
```bash
npm run dev  # Uses nodemon for auto-restart
```

### Production Mode
```bash
npm start
```

### Logging
The application logs to `server.log` and console output for debugging and monitoring.

## Deployment

### Environment Variables
Ensure all required environment variables are set in production:
- Database connection string
- JWT secret
- Cloudinary credentials
- Weather API key
- Port configuration

### Database Migration
Run the schema.sql file on your production database:
```bash
psql -U username -d database -f schema.sql
```

## Contributing

1. Follow the existing code style
2. Add tests for new features
3. Update documentation
4. Ensure all tests pass
5. Follow security best practices

## License

This project is licensed under the MIT License.
