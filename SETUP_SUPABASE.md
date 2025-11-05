# Supabase Setup for OutfitEase

## Connection String
You have: `postgresql://postgres:[YOUR_PASSWORD]@db.hpzcerpgdnwrmpuiwlak.supabase.co:5432/postgres`

## Steps to Complete Setup

### 1. Replace [YOUR_PASSWORD]
Replace `[YOUR_PASSWORD]` in the connection string with your actual Supabase database password.

**Important**: If your password has special characters, URL-encode them:
- `@` → `%40`
- `#` → `%23`
- `!` → `%21`
- `&` → `%26`
- `%` → `%25`
- `+` → `%2B`
- `=` → `%3D`

### 2. Update Render Environment Variable

1. Go to https://dashboard.render.com
2. Click your `outfitease-backend` service
3. Click "Environment" tab
4. Find `DATABASE_URL` and click "Edit"
5. Replace the value with your Supabase connection string (with password filled in)
6. Click "Save Changes"
7. Render will automatically redeploy (1-2 minutes)

### 3. Initialize Database Schema

1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click "SQL Editor" in the left sidebar
4. Click "New query"
5. Copy the entire contents of `backend/schema.sql`
6. Paste into the SQL Editor
7. Click "Run" (or press Cmd/Ctrl + Enter)
8. You should see "Success. No rows returned" or similar

### 4. Test Connection

After Render redeploys:
1. Try logging in from your iOS app
2. Should work instantly! No more timeouts!

---

## Your Supabase Details
- **Host**: `db.hpzcerpgdnwrmpuiwlak.supabase.co`
- **Database**: `postgres`
- **User**: `postgres`
- **Port**: `5432`

Make sure to replace `[YOUR_PASSWORD]` with your actual password!

