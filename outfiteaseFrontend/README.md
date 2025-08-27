# OutfitEase iOS App

A SwiftUI-based iOS application for managing clothing items, creating outfits, and sharing with the community.

## Features

### Authentication
- User registration and login
- Secure token-based authentication
- Persistent login state

### Clothing Management
- Add, edit, and delete clothing items
- Categorize items by type, color, style, brand, season, and occasion
- Search and filter clothing items
- Detailed clothing item views

### Outfit Creation
- Create outfits by selecting clothing items
- Add descriptions, styles, colors, and occasions
- Edit and manage existing outfits
- Outfit detail views with comprehensive information

### Community Features
- Share outfits as posts
- View community feed
- Like and comment on posts
- User profiles and settings

### Planning
- Calendar-based outfit planning
- Schedule outfits for specific dates
- View planned outfits

## Architecture

The app follows the MVVM (Model-View-ViewModel) architecture pattern:

- **Models**: Data structures that match the backend API
- **Views**: SwiftUI views for the user interface
- **ViewModels**: Business logic and state management
- **Services**: API communication layer

## Project Structure

```
outfiteaseFrontend/
├── Models/           # Data models
├── Views/            # SwiftUI views
│   ├── Auth/        # Authentication views
│   ├── Clothes/     # Clothing management views
│   ├── Outfits/     # Outfit creation and management
│   ├── Community/   # Social features
│   ├── Planning/    # Calendar and planning
│   └── Profile/     # User profile and settings
├── ViewModels/      # Business logic
├── Services/        # API communication
└── Utils/          # Utilities and constants
```

## Backend Integration

The app connects to a Node.js/Express backend with PostgreSQL database. The backend provides RESTful APIs for:

- User authentication
- Clothing item management
- Outfit creation and management
- Social features (posts, likes, comments)
- Outfit planning

## Setup Instructions

1. Ensure the backend server is running on `localhost:3000`
2. Open the project in Xcode
3. Build and run the app on a simulator or device
4. Register a new account or login with existing credentials

## API Endpoints

The app uses the following API endpoints:

- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `GET /clothes` - Get user's clothing items
- `POST /clothes` - Create new clothing item
- `GET /outfits` - Get user's outfits
- `POST /outfits` - Create new outfit
- `GET /posts` - Get community posts
- `POST /posts` - Create new post
- `GET /comments` - Get post comments
- `POST /comments` - Add comment to post
- `GET /planning` - Get outfit plans
- `POST /planning` - Create outfit plan

## Dependencies

- SwiftUI (iOS 15.0+)
- Foundation framework
- No external dependencies required

## Development Notes

- The app uses async/await for API calls
- Authentication tokens are stored in UserDefaults
- All API calls include proper error handling
- The UI is designed to be responsive and user-friendly
- Placeholder images are used for clothing and outfit previews

## Future Enhancements

- Image upload and management
- Push notifications
- Advanced filtering and search
- Outfit recommendations
- Social features (following, direct messages)
- Dark mode support
- Offline functionality 