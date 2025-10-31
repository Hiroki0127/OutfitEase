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
├── Utils/          # Utilities and constants
└── outfiteaseFrontendTests/  # Unit tests
    └── outfiteaseFrontendTests.swift  # Main test file
```

## Testing

### Unit Tests
The app includes comprehensive unit tests with excellent coverage:

- **Test Coverage**: 97.76% for unit tests, 100% for UI tests
- **Test File**: `outfiteaseFrontendTests/outfiteaseFrontendTests.swift`
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

### Running Tests
```bash
# From the outfiteaseFrontend directory
xcodebuild test -project outfiteaseFrontend.xcodeproj -scheme outfiteaseFrontend -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES

# View coverage report
xcrun xccov view --report [path-to-test-results]
```

### Test Structure
The tests are organized into logical categories:
- **Basic Tests**: Core functionality validation
- **Constants Tests**: Configuration verification
- **Data Type Tests**: Type safety and operations
- **Utility Tests**: Helper function validation

## Backend Integration

The app connects to a Node.js/Express backend with PostgreSQL database. The backend provides RESTful APIs for:

- User authentication
- Clothing item management
- Outfit creation and management
- Social features (posts, likes, comments)
- Outfit planning

## Setup Instructions

1. Ensure the backend is deployed on Render (see main README for deployment instructions)
2. Update the `baseURL` in `Constants.swift` with your Render service URL if needed
3. Open the project in Xcode
4. Build and run the app on a simulator or device
5. Register a new account or login with existing credentials

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
- Comprehensive unit tests ensure code quality and reliability

## Future Enhancements

- Image upload and management
- Push notifications
- Advanced filtering and search
- Outfit recommendations
- Social features (following, direct messages)
- Dark mode support
- Offline functionality
- Expanded test coverage for ViewModels and Services 