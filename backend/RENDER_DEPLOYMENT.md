# Render Deployment Guide

This guide will help you deploy the OutfitEase backend to Render.

## Prerequisites

1. **Render Account**: Sign up at [render.com](https://render.com)
2. **GitHub Repository**: Your code should be pushed to GitHub
3. **API Keys**: Have your Cloudinary and OpenWeatherMap API keys ready

## Step-by-Step Deployment

### Option 1: Using render.yaml (Recommended)

1. **Push your code to GitHub**
   ```bash
   git add .
   git commit -m "Add Render deployment configuration"
   git push origin main
   ```

2. **Connect Repository to Render**
   - Go to [Render Dashboard](https://dashboard.render.com)
   - Click "New" → "Blueprint"
   - Connect your GitHub repository
   - Render will automatically detect the `render.yaml` file

3. **Configure Environment Variables**
   - Go to your web service settings
   - Navigate to "Environment" tab
   - Add the following environment variables:
     - `CLOUDINARY_CLOUD_NAME`: Your Cloudinary cloud name
     - `CLOUDINARY_API_KEY`: Your Cloudinary API key
     - `CLOUDINARY_API_SECRET`: Your Cloudinary API secret
     - `OPENWEATHER_API_KEY`: Your OpenWeatherMap API key
     - `JWT_SECRET`: A strong secret key (Render will auto-generate if using render.yaml)

4. **Initialize Database**
   - The PostgreSQL database will be automatically created
   - Once deployed, SSH into your service or use Render's shell
   - Run the schema migration:
     ```bash
     psql $DATABASE_URL -f schema.sql
     ```
   - Or use Render's PostgreSQL console:
     - Go to your database dashboard
     - Click "Connect" → "psql"
     - Run: `\i schema.sql` (if you upload the file)

### Option 2: Manual Setup (Alternative)

If you prefer to set up manually without render.yaml:

1. **Create PostgreSQL Database**
   - Go to Render Dashboard
   - Click "New" → "PostgreSQL"
   - Name: `outfitease-db`
   - Plan: Free (or paid for production)
   - Click "Create Database"
   - Copy the Internal Database URL

2. **Create Web Service**
   - Click "New" → "Web Service"
   - Connect your GitHub repository
   - Settings:
     - **Name**: `outfitease-backend`
     - **Environment**: `Node`
     - **Build Command**: `cd backend && npm install`
     - **Start Command**: `cd backend && npm start`
     - **Plan**: Free (or paid for production)

3. **Configure Environment Variables**
   Add these in the "Environment" section:
   ```
   NODE_ENV=production
   PORT=10000
   DATABASE_URL=<Your PostgreSQL Internal Database URL from step 1>
   JWT_SECRET=<Generate a strong secret key>
   CLOUDINARY_CLOUD_NAME=<Your Cloudinary cloud name>
   CLOUDINARY_API_KEY=<Your Cloudinary API key>
   CLOUDINARY_API_SECRET=<Your Cloudinary API secret>
   OPENWEATHER_API_KEY=<Your OpenWeatherMap API key>
   ```

4. **Deploy**
   - Click "Create Web Service"
   - Render will automatically build and deploy your service
   - Wait for the build to complete (usually 2-5 minutes)

5. **Initialize Database Schema**
   - Once deployed, you need to run the database schema
   - Option A: Use Render Shell
     - Go to your web service → "Shell"
     - Run: `psql $DATABASE_URL -f backend/schema.sql`
   - Option B: Use Render PostgreSQL Console
     - Go to your database → "Connect" → "psql"
     - Copy and paste the contents of `backend/schema.sql`

## Post-Deployment Setup

### 1. Get Your Service URL
- After deployment, Render will provide a URL like: `https://outfitease-backend.onrender.com`
- Copy this URL

### 2. Update iOS App Configuration
Update the base URL in your iOS app:

**File**: `outfiteaseFrontend/outfiteaseFrontend/Utils/Constants.swift`

Update the `baseURL` with your actual Render service URL:

```swift
// Update this with your Render service URL:
static let baseURL = "https://your-actual-render-url.onrender.com"
```

### 3. Test Your Deployment
```bash
# Test the root endpoint
curl https://your-service-url.onrender.com/

# Test health check
curl https://your-service-url.onrender.com/
```

### 4. Set Up Custom Domain (Optional)
- Go to your service settings
- Click "Custom Domains"
- Add your domain and follow DNS configuration instructions

## Environment Variables Reference

| Variable | Description | Example |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `production` |
| `PORT` | Server port | `10000` |
| `DATABASE_URL` | PostgreSQL connection string | Auto-provided by Render |
| `JWT_SECRET` | Secret for JWT tokens | Auto-generated or custom |
| `CLOUDINARY_CLOUD_NAME` | Cloudinary cloud name | `dloz83z8m` |
| `CLOUDINARY_API_KEY` | Cloudinary API key | Your key |
| `CLOUDINARY_API_SECRET` | Cloudinary API secret | Your secret |
| `OPENWEATHER_API_KEY` | OpenWeatherMap API key | Your key |

## Troubleshooting

### Build Fails
- **Issue**: Build command fails
- **Solution**: Check that all dependencies are listed in `package.json` and the build command is correct

### Database Connection Errors
- **Issue**: Cannot connect to database
- **Solution**: 
  - Verify `DATABASE_URL` is correctly set
  - Ensure you're using the **Internal Database URL** (not external)
  - Check that database service is running

### Service Won't Start
- **Issue**: Service crashes on startup
- **Solution**:
  - Check logs in Render dashboard
  - Verify all environment variables are set
  - Ensure `PORT` is set to `10000` (Render's default)

### CORS Issues
- **Issue**: iOS app can't connect to API
- **Solution**: 
  - Verify `baseURL` in iOS app matches your Render URL
  - Check that CORS is enabled in `app.js` (should be already enabled)

### Database Schema Not Applied
- **Issue**: Tables don't exist
- **Solution**: 
  - Use Render Shell to run `psql $DATABASE_URL -f backend/schema.sql`
  - Or use PostgreSQL console to manually run the SQL

## Free Tier Limitations

⚠️ **Important Notes for Free Tier**:
- Services spin down after 15 minutes of inactivity
- First request after spin-down may take 30-60 seconds
- Database has 90-day data retention
- Limited to 750 hours/month per service

**Recommendation**: For production, consider upgrading to paid plans.

## Monitoring

### View Logs
- Go to your service dashboard
- Click "Logs" tab to see real-time logs

### Health Checks
- Render automatically monitors your service
- Health check endpoint: `GET /` (should return "Welcome to the OutfitEase API!")

## Next Steps

1. ✅ Deploy backend to Render
2. ✅ Update iOS app baseURL
3. ✅ Test all API endpoints
4. ✅ Set up monitoring and alerts
5. ⬜ Consider setting up a custom domain
6. ⬜ Set up automated backups for database

## Support

- Render Documentation: [https://render.com/docs](https://render.com/docs)
- Render Support: [https://community.render.com](https://community.render.com)

---

**Deployment Status**: Ready for deployment
**Last Updated**: 2025-01-28

