# Supabase Setup Guide for OutfitEase

## Step 1: Create a New Project

1. **Go to Supabase Dashboard**
   - Navigate to [app.supabase.com](https://app.supabase.com)
   - Log in to your account

2. **Create New Project**
   - Click "New Project" button
   - Fill in the details:
     - **Name**: `outfitease` (or any name you prefer)
     - **Database Password**: Create a strong password (save this!)
       - You'll need this password for the connection string
     - **Region**: Choose closest to you (affects latency)
     - **Pricing Plan**: Free (should be selected by default)
   - Click "Create new project"
   - ⏳ Wait 2-3 minutes for the project to be created

## Step 2: Get Your Database Connection String

1. **Go to Project Settings**
   - Once project is created, click on your project
   - Click "Settings" (gear icon) in the left sidebar
   - Click "Database" in the settings menu

2. **Get Connection String**
   - Scroll down to "Connection string" section
   - Select "URI" tab
   - You'll see a connection string like:
     ```
     postgresql://postgres:[https://yrohhdllyfvxqncnnrre.supabase.co]@db.xxxxx.supabase.co:5432/postgres
     ```
   - Click the "Copy" button to copy the full connection string
   - Replace `[YOUR-PASSWORD]` with the password you created in Step 1
   - **Important**: Make sure to replace `[YOUR-PASSWORD]` with your actual password!
   
   Example (after replacing password):
   ```
   postgresql://postgres:MyPassword123!@db.abcdefghijk.supabase.co:5432/postgres
   ```

3. **Save This Connection String**
   - You'll need it for Render environment variables

## Step 3: Initialize Database Schema

1. **Open SQL Editor**
   - In Supabase dashboard, click "SQL Editor" in the left sidebar
   - Click "New query"

2. **Run Schema Script**
   - Open `backend/schema.sql` from your project
   - Copy the entire contents
   - Paste into the Supabase SQL Editor
   - Click "Run" (or press Cmd/Ctrl + Enter)
   - ✅ You should see "Success. No rows returned" or similar

## Step 4: Update Render with Database URL

1. **Go to Render Dashboard**
   - Navigate to your `outfitease-backend` web service
   - Click on the service name

2. **Add/Update Environment Variable**
   - Click "Environment" tab
   - Find `DATABASE_URL` variable:
     - If it exists: Click "Edit" and update the value
     - If it doesn't exist: Click "Add Environment Variable"
   - Add/Update:
     - **Key**: `DATABASE_URL`
     - **Value**: (paste your Supabase connection string from Step 2)
   - Click "Save Changes"
   - Render will automatically redeploy your service

3. **Verify Deployment**
   - Wait for the service to redeploy (green status)
   - Check logs to ensure no connection errors

## Step 5: Test Database Connection

1. **Test from Render Shell** (Optional)
   - Go to your web service → "Shell" tab
   - Run:
     ```bash
     psql $DATABASE_URL -c "SELECT version();"
     ```
   - Should return PostgreSQL version info

2. **Test from Your App**
   - Once Render service is running
   - Try making an API call from your iOS app
   - Or test registration/login endpoint

## Troubleshooting

### Connection String Issues
- **Password has special characters**: Make sure to URL-encode them
  - `@` becomes `%40`
  - `#` becomes `%23`
  - `!` becomes `%21`
  - Or use Supabase's connection pooler (see below)

### Alternative: Use Connection Pooler
Supabase also provides a connection pooler which is better for serverless:
1. Go to Settings → Database
2. Use "Connection pooling" → "Session" mode
3. Connection string will have `pooler` in the URL
4. This is better for Render's free tier (handles connection limits)

### Can't Connect from Render
- Verify `DATABASE_URL` is set correctly
- Check that password doesn't have unencoded special characters
- Ensure Supabase project is fully created (not still provisioning)
- Try the connection pooler instead of direct connection

### Schema Not Applying
- Make sure you copied the entire `schema.sql` file
- Check for errors in SQL Editor
- Verify tables were created: Go to "Table Editor" in Supabase

## Quick Verification Checklist

- [ ] Supabase project created and ready
- [ ] Connection string copied (with actual password)
- [ ] Database schema applied (tables created)
- [ ] `DATABASE_URL` updated in Render
- [ ] Render service redeployed successfully
- [ ] Can connect to database (test via Shell or API)

---

**Next Steps:**
After setup, your Render service will connect to Supabase automatically. Test your API endpoints to ensure everything works!

