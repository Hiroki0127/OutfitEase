# OutfitEase

OutfitEase is a SwiftUI iOS application backed by a Node.js/Express API. Users manage their wardrobe, build outfits, plan looks on a calendar, and share posts with the community. The backend runs on Render using Supabase PostgreSQL (session pooler) and Cloudinary for image uploads.

## Quick Links

- **Live backend**: https://outfitease.onrender.com  
- **iOS project**: `outfiteaseFrontend/outfiteaseFrontend.xcodeproj`  
- **Backend**: `backend/`  
- **Demo video**: _add link_

## Features

- Email/password authentication with JWT sessions.
- Wardrobe management (clothing items with photos, details like brand, price, season, and occasion).
- Outfit creation by combining clothing items with style tags and metadata.
- Calendar planning for scheduling outfits on specific dates.
- Community feed with posts, likes, and comments.
- Public profile pages with follower/following counts and post history.
- Follow/unfollow other users (with sample relationships seeded).
- Cloudinary-backed image uploads for clothing items and outfits.

## Architecture Overview

| Layer      | Technology                          | Highlights                                              |
|------------|-------------------------------------|---------------------------------------------------------|
| iOS app    | SwiftUI, MVVM, async/await          | Custom API client, pull-to-refresh, token persistence   |
| API        | Node.js, Express, pg                | Structured controllers/models, JWT auth, retry logic    |
| Database   | Supabase PostgreSQL (session pooler)| SSL enforced, array fields for tags, follow join table  |
| Hosting    | Render web service                  | Free tier, 50–60 s spin-up handled by client retries    |
| Media      | Cloudinary                          | Direct base64 uploads, secure URLs                      |

High level flow:

1. iOS client calls `https://outfitease.onrender.com` using `APIService`.
2. Express routes authenticate requests, hit controllers, and query Supabase.
3. Responses are normalized for Swift models (arrays, UUID strings, ISO dates).
4. Client caches tokens and refreshes data with pull-to-refresh or on appear.

## Getting Started

### Prerequisites

- Node.js 18+
- npm 9+
- Xcode 15+
- Supabase project (PostgreSQL) with session pooler enabled
- Cloudinary account
- OpenWeather API key if you want weather features active

### 1. Configure environment variables

Create `backend/.env` (never commit this file):

```
DATABASE_URL=postgresql://...aws-1-us-east-2.pooler.supabase.com:5432/postgres?pgbouncer=true&sslmode=require
JWT_SECRET=generate-a-32-char-random-string
CLOUDINARY_CLOUD_NAME=...
CLOUDINARY_API_KEY=...
CLOUDINARY_API_SECRET=...
OPENWEATHER_API_KEY=...
PORT=10000
NODE_ENV=production
```

For local scripts you can also export `DATABASE_URL` inline:

```
DATABASE_URL='postgresql://...' node backend/scripts/populateFollowRelationships.js
```

### 2. Provision the database

1. Open the Supabase SQL editor.
2. Paste the contents of `backend/schema.sql` and run once.
3. Seed accounts and content:
   ```bash
   cd backend
   node scripts/populateCommunityPosts.js
   DATABASE_URL='postgresql://...' node scripts/populateFollowRelationships.js
   ```
   These scripts create sample users, clothing, outfits, posts, and follow links (including `hiro@example.com` and `kitty@gmail.com`).

### 3. Deploy / run the backend

**Local**
```bash
cd backend
npm install
npm run dev
```

**Render (production)**
1. Create a Render Web Service pointing to this repo.
2. Build command: `cd backend && npm install`
3. Start command: `cd backend && npm start`
4. Set the environment variables listed above.
5. Deploy. Render may take 50–60 seconds to wake on the free tier; the iOS client uses longer timeouts and a warm-up ping to handle this.

### 4. Configure the iOS app

1. Open `outfiteaseFrontend/outfiteaseFrontend.xcodeproj` in Xcode.
2. Update `Constants.baseURL` if your backend runs on a different domain.
3. Run on an iOS 15+ simulator.

Sample credentials (if seeds were run):

| Email             | Password     | Notes       |
|-------------------|--------------|-------------|
| hiro@example.com  | password123  | Follows several users |
| kitty@gmail.com   | password1234 | Has posts and followers |
| sarah@example.com | password123  | Community sample user |

Use the profile tab to view your stats (clothes, outfits, posts, followers, following), manage your content, or sign out.

## Testing

### Backend
```bash
cd backend
npm test
```

### iOS
```bash
cd outfiteaseFrontend
xcodebuild test \
  -project outfiteaseFrontend.xcodeproj \
  -scheme outfiteaseFrontend \
  -destination 'platform=iOS Simulator,name=iPhone 16'
```

## Troubleshooting

- **API returns 500 self-signed certificate**: Ensure the Supabase connection string includes `sslmode=require` and that `db.js` sets `rejectUnauthorized` to false (already handled).
- **Render logs show ENETUNREACH**: Use Supabase session pooler (port 6543) to stay on IPv4.
- **Render free tier timeouts**: First request can take 50–60 seconds; the app shows a warm-up spinner.
- **Scripts complain about closed pool**: Harmless. `db.js` runs a delayed connection test while scripts close the pool. Ignore or remove the test when running maintenance scripts.

## Maintenance Scripts

| Script | Purpose |
|--------|---------|
| `backend/scripts/populateCommunityPosts.js` | Create sample users, clothing items, outfits, and posts. |
| `backend/scripts/populateFollowRelationships.js` | Seed realistic follower/following connections between sample users. |
| `backend/scripts/listAllUsers.js` | Print all users with counts for debugging. |

Run scripts with `DATABASE_URL` exported if you are not on Render.

## License

MIT. See `LICENSE` for details.

## Credits

- Render for hosting.
- Supabase for managed PostgreSQL and pooling.
- Cloudinary for media storage.
- OpenWeather for optional weather data.
