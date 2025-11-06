# OutfitEase - AI-Powered Fashion Assistant

OutfitEase is a comprehensive mobile application that simplifies and enhances the outfit selection process for users. The app combines AI-powered outfit generation, weather-based recommendations, and community features to create a unique fashion experience.

## Key Features

### AI-Powered Outfit Generation
- **Smart Filtering**: Generate outfits based on event type, colors, style preferences, and budget
- **Weather Integration**: Get weather-appropriate outfit suggestions
- **Personalized Recommendations**: AI algorithms consider user preferences and owned clothing
- **Budget Control**: Set spending limits and get affordable outfit suggestions

### Weather-Based Recommendations
- **Real-time Weather**: Integrates with weather APIs for current conditions
- **Seasonal Suggestions**: Automatic recommendations based on temperature and conditions
- **Location Services**: Uses GPS for local weather data
- **Forecast Planning**: Plan outfits for upcoming weather

### Outfit Planning
- **Calendar Integration**: Schedule outfits for specific dates
- **Event Planning**: Plan outfits for upcoming events
- **Weather Integration**: Consider weather forecasts in planning
- **Reminder System**: Get notifications for planned outfits

### Community Features
- **Outfit Sharing**: Share your favorite outfits with the community
- **Inspiration Feed**: Browse outfits shared by other users
- **Like & Comment**: Interact with community posts
- **Trend Discovery**: Discover current fashion trends

### Personal Wardrobe Management
- **Virtual Wardrobe**: Organize and categorize your clothing items
- **Search & Filter**: Find items by type, color, brand, season, and occasion
- **Cost Tracking**: Monitor spending on clothing items
- **Outfit History**: Track which outfits you've worn

## Architecture

### Backend (Node.js/Express)
- **RESTful API**: Clean, scalable API design
- **PostgreSQL Database**: Supabase (hosted PostgreSQL with connection pooling)
- **Deployment**: Render (serverless hosting)
- **JWT Authentication**: Secure user authentication
- **File Upload**: Cloudinary integration for image storage
- **Weather API**: OpenWeatherMap integration

### iOS Frontend (SwiftUI)
- **MVVM Architecture**: Clean separation of concerns
- **Async/Await**: Modern concurrency for API calls
- **Core Location**: Location services for weather data
- **UserDefaults**: Local data persistence

## 🧪 Testing

### iOS Unit Tests
The iOS app includes comprehensive unit tests with excellent coverage:

- **Test Coverage**: 97.76% for unit tests, 100% for UI tests
- **Test Location**: `outfiteaseFrontend/outfiteaseFrontendTests/outfiteaseFrontendTests.swift`
- **Test Categories**:
  - Constants configuration validation
  - HTTP method enumeration
  - UserDefaults constants
  - Weather and outfit generation constants
  - UUID generation and validation
  - Data type operations
  - Array and string operations
  - Optional handling
  - Number formatting

#### Running iOS Tests
```bash
# From the outfiteaseFrontend directory
xcodebuild test -project outfiteaseFrontend.xcodeproj -scheme outfiteaseFrontend -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report [path-to-test-results]
```

### Backend Tests
The backend includes test files for API endpoints:

- **Test Location**: `backend/tests/`
- **Current Tests**: Comments functionality (`comments.test.js`)

#### Running Backend Tests
```bash
# From the backend directory
npm test
```

## 📱 Target Users

### Fashion Enthusiasts
- Users looking for outfit inspiration
- People who enjoy experimenting with different styles
- Fashion-conscious individuals seeking trends

### Busy Professionals
- Users who need quick outfit decisions
- People with limited time for fashion planning
- Professionals requiring appropriate attire

### Budget-Conscious Users
- Users seeking affordable clothing options
- People who want to maximize their wardrobe
- Cost-conscious fashion lovers

### Style Beginners
- Users new to fashion and styling
- People seeking guidance on outfit coordination
- Users wanting to develop their personal style

## Getting Started

### Prerequisites
- Node.js (v16 or higher)
- Xcode (v14 or higher)
- iOS 15.0+ for mobile app
- Supabase account (for database hosting)
- Render account (for backend hosting)
- OpenWeatherMap API key (for weather features)
- Cloudinary account (for image storage)

### Backend Setup

The backend is deployed on **Render** with **Supabase** as the database. See the [Deployment](#-deployment) section below for setup instructions.

### iOS App Setup
1. Open the iOS project in Xcode
2. Install dependencies (if using Swift Package Manager)
3. Ensure backend is deployed on Render
4. Update `baseURL` in `Constants.swift` with your Render service URL
5. Build and run the app

## 🚀 Deployment

### Production Setup: Render + Supabase

The app is deployed with:
- **Backend**: Render (serverless Node.js hosting)
- **Database**: Supabase (PostgreSQL with connection pooling)
- **Production URL**: `https://outfitease.onrender.com`

#### Step 1: Set Up Supabase Database

1. **Create Supabase Project**
   - Go to [Supabase Dashboard](https://supabase.com/dashboard)
   - Create a new project
   - Wait for database to initialize

2. **Initialize Database Schema**
   - Go to SQL Editor in Supabase
   - Copy and paste the contents of `backend/schema.sql`
   - Run the SQL script

3. **Get Connection String**
   - Go to Settings → Database → Connection pooling
   - Select **Session** mode
   - Copy the connection string (should include `:6543` port)
   - Example: `postgresql://postgres.xxx:PASSWORD@xxx.pooler.supabase.com:6543/postgres`

#### Step 2: Deploy Backend to Render

1. **Push code to GitHub**
   ```bash
   git push origin main
   ```

2. **Create Web Service on Render**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Settings:
     - **Build Command**: `cd backend && npm install`
     - **Start Command**: `cd backend && npm start`
     - **Plan**: Free (or paid for production)

3. **Set Environment Variables in Render**
   - Go to your service → Environment tab
   - Add these variables:
     - `DATABASE_URL` - Paste your Supabase connection string (Session pooler, port 6543)
     - `JWT_SECRET` - Generate a secure random string (32+ characters)
     - `CLOUDINARY_CLOUD_NAME` - Your Cloudinary cloud name
     - `CLOUDINARY_API_KEY` - Your Cloudinary API key
     - `CLOUDINARY_API_SECRET` - Your Cloudinary API secret
     - `OPENWEATHER_API_KEY` - Your OpenWeatherMap API key
     - `PORT` - Set to `10000` (Render's default)
     - `NODE_ENV` - Set to `production`

4. **Deploy**
   - Render will auto-deploy after saving environment variables
   - Wait for deployment to complete (usually 2-5 minutes)

#### Step 3: Configure iOS App

1. **Update API URL**
   - Open `outfiteaseFrontend/outfiteaseFrontend/Utils/Constants.swift`
   - Update `baseURL` with your Render service URL:
     ```swift
     static let baseURL = "https://outfitease.onrender.com"
     ```

2. **Build and Run**
   - Open the project in Xcode
   - Build and run on simulator or device

#### Important Notes

- **Supabase Connection Pooler**: Always use **Session mode** (port 6543) for better reliability
- **Render Free Tier**: Services spin down after 15 minutes of inactivity (first request may take 50-60 seconds)
- **Database Schema**: Must be run in Supabase SQL Editor before the app can work
- **Environment Variables**: Never commit `.env` files to git

#### Configuration Files
- **`backend/schema.sql`**: Database schema to run in Supabase
- **`backend/RENDER_DEPLOYMENT.md`**: Additional deployment details
- **`SETUP_SUPABASE.md`**: Supabase setup guide

## Configuration

### Environment Variables

Configure these in your Render dashboard (Environment tab):

| Variable | Description | Source |
|----------|-------------|--------|
| `DATABASE_URL` | Supabase connection string (Session pooler, port 6543) | Supabase Dashboard → Settings → Database → Connection pooling |
| `JWT_SECRET` | Secret key for JWT token signing (32+ characters) | Generate: `node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"` |
| `CLOUDINARY_CLOUD_NAME` | Your Cloudinary cloud name | Cloudinary Dashboard |
| `CLOUDINARY_API_KEY` | Your Cloudinary API key | Cloudinary Dashboard |
| `CLOUDINARY_API_SECRET` | Your Cloudinary API secret | Cloudinary Dashboard |
| `OPENWEATHER_API_KEY` | Your OpenWeatherMap API key | OpenWeatherMap API |
| `PORT` | Server port (set to 10000) | Render default |
| `NODE_ENV` | Environment (set to production) | `production` |

**Important**: The `DATABASE_URL` must use Supabase's Session pooler (port 6543) for reliable connections.

### iOS Configuration
- Add location usage description in `Info.plist`
- Set up proper app permissions

## Database Schema

The application uses a comprehensive PostgreSQL schema with the following main tables:

- **users**: User accounts and profiles
- **clothing_items**: Individual clothing pieces
- **outfits**: Complete outfit combinations
- **outfit_items**: Junction table for outfit-clothing relationships
- **outfit_planning**: Calendar-based outfit scheduling
- **posts**: Community shared outfits
- **weather_data**: Weather information for recommendations
- **generated_outfits**: AI-generated outfit suggestions
- **user_preferences**: User styling preferences
- **trends**: Current fashion trends

## API Endpoints

### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login

### Clothing Management
- `GET /clothes` - Get user's clothing items
- `POST /clothes` - Add new clothing item
- `PUT /clothes/:id` - Update clothing item
- `DELETE /clothes/:id` - Delete clothing item

### Outfit Management
- `GET /outfits` - Get user's outfits
- `POST /outfits` - Create new outfit
- `PUT /outfits/:id` - Update outfit
- `DELETE /outfits/:id` - Delete outfit

### AI Outfit Generation
- `POST /outfit-generation/generate` - Generate outfits with filters
- `POST /outfit-generation/weather-based` - Weather-based generation
- `GET /outfit-generation/event/:eventType` - Event-specific suggestions

### Weather Integration
- `GET /weather/current` - Get current weather
- `GET /weather/forecast` - Get weather forecast
- `POST /weather/recommendations` - Get weather-based recommendations

### Community Features
- `GET /posts` - Get community posts
- `POST /posts` - Create new post
- `GET /comments` - Get post comments
- `POST /comments` - Add comment to post

## UI/UX Features

### Modern Design
- Clean, intuitive interface
- Consistent design language
- Accessibility support
- Dark mode compatibility

### Interactive Elements
- Smooth animations and transitions
- Haptic feedback
- Gesture recognition

### Personalization
- Customizable themes
- Personalized recommendations
- User preference learning
- Adaptive interface

## Future Enhancements

### Planned Features
- **Augmented Reality**: Virtual try-on capabilities
- **Voice Commands**: Control app with voice
- **Social Features**: Follow other users
- **Shopping Integration**: Direct purchase links
- **Advanced Analytics**: Detailed style insights
- **Offline Mode**: Basic functionality without internet
- **Multi-language Support**: Internationalization
- **Apple Watch Integration**: Quick outfit access
- **Machine Learning**: Improved recommendations

### Technical Improvements
- **Real-time Updates**: WebSocket integration
- **Push Notifications**: Outfit reminders
- **Performance Optimization**: Faster loading times
- **Security Enhancements**: Advanced authentication

## Contributing

We welcome contributions! Please see our contributing guidelines for details on:
- Code style and standards
- Testing requirements
- Pull request process
- Issue reporting

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- **Render** - Backend hosting platform
- **Supabase** - PostgreSQL database hosting with connection pooling
- **OpenWeatherMap** - Weather data API
- **Cloudinary** - Image storage and CDN
- The fashion community for inspiration

## Support

For support, please contact:
- Email: support@outfitease.com
- GitHub Issues: [Create an issue](https://github.com/outfitease/app/issues)
- Documentation: [Read the docs](https://docs.outfitease.com)

---

**OutfitEase** - Making fashion personal, one outfit at a time. 
