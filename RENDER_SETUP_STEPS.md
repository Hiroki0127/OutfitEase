# Render Setup Steps for outfitEase Environment

## Step 1: Create Blueprint from GitHub Repository

1. **Go to Render Dashboard**
   - Navigate to [dashboard.render.com](https://dashboard.render.com)
   - Make sure you're in the "outfitEase" environment (top dropdown)

2. **Create New Blueprint**
   - Click "New" → "Blueprint"
   - Click "Connect GitHub account" if not already connected
   - Select your repository: `Hiroki0127/OutfitEase`
   - Click "Apply"

3. **Review Configuration**
   - Render will automatically detect the `render.yaml` file
   - You should see:
     - **Web Service**: `outfitease-backend`
     - **PostgreSQL Database**: `outfitease-db`
   - Click "Apply" to create both services

## Step 2: Configure Environment Variables

After the services are created, you need to add your API keys:

1. **Go to Web Service Settings**
   - Click on the `outfitease-backend` service
   - Navigate to "Environment" tab

2. **Add Required Variables**
   Click "Add Environment Variable" for each:
   
   - **CLOUDINARY_CLOUD_NAME**
     - Value: `dloz83z8m` (or your Cloudinary cloud name)
   
   - **CLOUDINARY_API_KEY**
     - Value: Your Cloudinary API key
   
   - **CLOUDINARY_API_SECRET**
     - Value: Your Cloudinary API secret
   
   - **OPENWEATHER_API_KEY**
     - Value: Your OpenWeatherMap API key

3. **Verify Auto-Generated Variables**
   These should already be set automatically:
   - `DATABASE_URL` (from the database service)
   - `JWT_SECRET` (auto-generated)
   - `NODE_ENV` (set to `production`)
   - `PORT` (set to `10000`)

## Step 3: Initialize Database

Once both services are deployed:

1. **Get Database Connection Info**
   - Go to the `outfitease-db` database service
   - Click "Connect" → Note the connection details

2. **Run Schema Migration**
   
   **Option A: Using Render Shell**
   - Go to `outfitease-backend` service
   - Click "Shell" tab
   - Run:
     ```bash
     psql $DATABASE_URL -f backend/schema.sql
     ```
   
   **Option B: Using PostgreSQL Console**
   - Go to `outfitease-db` database service
   - Click "Connect" → "psql"
   - Copy and paste the contents of `backend/schema.sql`
   - Execute the SQL

## Step 4: Get Your Service URL

1. **Find Your Service URL**
   - Go to `outfitease-backend` service
   - Copy the URL (e.g., `https://outfitease-backend.onrender.com`)
   - This may take a few minutes to appear after deployment starts

2. **Update iOS App**
   - Open `outfiteaseFrontend/outfiteaseFrontend/Utils/Constants.swift`
   - Update:
     ```swift
     static let baseURL = "https://your-actual-render-url.onrender.com"
     ```

## Step 5: Verify Deployment

1. **Check Service Status**
   - Wait for deployment to complete (green status)
   - Check logs for any errors

2. **Test API**
   ```bash
   curl https://your-service-url.onrender.com/
   ```
   Should return: "Welcome to the OutfitEase API!"

3. **Test from iOS App**
   - Build and run the iOS app
   - Try logging in or registering
   - Verify API calls work

## Troubleshooting

### Build Fails
- Check build logs for errors
- Ensure `package.json` is in the `backend/` directory
- Verify Node.js version compatibility

### Service Won't Start
- Check environment variables are all set
- Review logs for startup errors
- Verify `PORT` is set to `10000`

### Database Connection Errors
- Ensure `DATABASE_URL` environment variable is set
- Verify database service is running
- Check that you're using Internal Database URL (not external)

### API Calls Fail from iOS
- Verify `baseURL` in `Constants.swift` matches your Render URL
- Check that service is not sleeping (free tier limitation)
- Review CORS settings in backend (should already be enabled)

---

**Next Steps After Deployment:**
- ✅ Test all API endpoints
- ✅ Verify database operations
- ✅ Test image uploads to Cloudinary
- ✅ Test weather API integration
- ✅ Update iOS app with production URL

