# Render Deployment Checklist

Use this checklist to ensure a smooth deployment to Render.

## Pre-Deployment

- [ ] Code is pushed to GitHub
- [ ] All sensitive data is in `.env` (not committed to git)
- [ ] `render.yaml` is in the repository root
- [ ] Database schema file (`backend/schema.sql`) is ready

## API Keys Ready

- [ ] Cloudinary Cloud Name
- [ ] Cloudinary API Key
- [ ] Cloudinary API Secret
- [ ] OpenWeatherMap API Key

## Render Setup

- [ ] Created Render account
- [ ] Connected GitHub repository
- [ ] Created Blueprint from `render.yaml` (or manually created services)

## Environment Variables

- [ ] `CLOUDINARY_CLOUD_NAME` - Added
- [ ] `CLOUDINARY_API_KEY` - Added
- [ ] `CLOUDINARY_API_SECRET` - Added
- [ ] `OPENWEATHER_API_KEY` - Added
- [ ] `JWT_SECRET` - Auto-generated (or manually set)
- [ ] `DATABASE_URL` - Auto-provided by Render

## Database Setup

- [ ] PostgreSQL database created
- [ ] Database schema applied (`psql $DATABASE_URL -f backend/schema.sql`)
- [ ] Database connection tested

## Service Verification

- [ ] Web service deployed successfully
- [ ] Service is running (check logs)
- [ ] Health check passing (`GET /` returns "Welcome to the OutfitEase API!")
- [ ] Service URL copied

## Post-Deployment

- [ ] Updated iOS app `baseURL` in `Constants.swift` with actual Render service URL
- [ ] Tested API endpoints from iOS app
- [ ] Verified authentication works
- [ ] Tested image uploads (Cloudinary)
- [ ] Tested weather API integration
- [ ] Verified database operations

## Testing Checklist

- [ ] User registration
- [ ] User login
- [ ] Create clothing item
- [ ] Create outfit
- [ ] Upload image
- [ ] Get weather data
- [ ] Create post
- [ ] Like post
- [ ] Add comment
- [ ] Save outfit

## Monitoring Setup

- [ ] Logs are accessible
- [ ] Error tracking configured (optional)
- [ ] Alerts set up for downtime (optional)

## Documentation

- [ ] Updated README with deployment info
- [ ] Team members notified of new URL
- [ ] API documentation updated (if applicable)

---

**Next Steps After Deployment:**

1. Share Render URL with team
2. Update any external documentation
3. Set up custom domain (optional)
4. Configure SSL (automatic with Render)
5. Consider upgrading from free tier for production

