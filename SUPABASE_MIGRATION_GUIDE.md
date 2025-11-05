# Migrate from Render PostgreSQL to Supabase

## Why Migrate?
- ✅ Render PostgreSQL free tier spins down (causes timeouts)
- ✅ Supabase doesn't spin down (always available)
- ✅ Better performance and reliability
- ✅ 500 MB free storage (plenty for portfolio projects)
- ✅ Easy setup (10 minutes)

## Step 1: Create Supabase Project

1. **Go to Supabase**: https://supabase.com
2. **Sign up** (free) or log in
3. **Click "New Project"**
4. **Fill in details**:
   - **Name**: `outfitease`
   - **Database Password**: Create a strong password (save this!)
   - **Region**: Choose closest to you (e.g., `US East` for US)
   - **Pricing Plan**: Free
5. **Click "Create new project"**
6. **Wait 2-3 minutes** for project to be created

## Step 2: Get Connection String

1. **Go to Settings** → **Database** (in your Supabase project)
2. **Scroll to "Connection string"** section
3. **Select "URI" tab**
4. **Copy the connection string** (looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxx.supabase.co:5432/postgres
   ```
5. **Replace `[YOUR-PASSWORD]`** with the password you created in Step 1
   - Example: If password is `MyPass123!`, the URL becomes:
   ```
   postgresql://postgres:MyPass123!@db.xxxxx.supabase.co:5432/postgres
   ```
   - **Important**: If password has special characters, URL-encode them:
     - `@` → `%40`
     - `#` → `%23`
     - `!` → `%21`
     - `&` → `%26`

## Step 3: Initialize Database Schema

1. **Go to SQL Editor** in Supabase dashboard
2. **Click "New query"**
3. **Open** `backend/schema.sql` from your project
4. **Copy entire contents** and paste into SQL Editor
5. **Click "Run"** (or press Cmd/Ctrl + Enter)
6. **Should see**: "Success. No rows returned" or similar

## Step 4: Update Render Environment Variable

1. **Go to Render Dashboard**: https://dashboard.render.com
2. **Click your `outfitease-backend` service**
3. **Click "Environment" tab**
4. **Find `DATABASE_URL`**:
   - Click "Edit" (or "Add" if it doesn't exist)
5. **Update value**:
   - **Key**: `DATABASE_URL`
   - **Value**: (Paste your Supabase connection string from Step 2)
6. **Click "Save Changes"**
7. **Render will automatically redeploy** (takes 1-2 minutes)

## Step 5: Migrate Existing Data (Optional)

If you have existing data in Render database that you want to keep:

1. **Export from Render**:
   - Use Render Shell or psql to export data
   - Or use pg_dump if you have access

2. **Import to Supabase**:
   - Use Supabase SQL Editor
   - Or use psql command line

**Note**: For a portfolio project, you might just want to start fresh with test data.

## Step 6: Verify It Works

1. **Wait for Render deployment to complete** (green status)
2. **Try logging in from your iOS app**
3. **Should work instantly!** (no more timeouts)

## Troubleshooting

### Connection String Issues
- **Password has special characters**: URL-encode them
- **Connection refused**: Check if password is correct
- **SSL error**: Supabase requires SSL, but our code handles it automatically

### Still Getting Timeouts?
- Check Supabase dashboard → Database → Connection Pooling
- Make sure you're using the "URI" connection string (not "Session" mode)
- Verify DATABASE_URL is set correctly in Render

## Benefits After Migration

✅ **No more connection timeouts**
✅ **Fast responses** (always-on database)
✅ **Better for recruiters** (instant login)
✅ **500 MB free storage** (plenty for portfolio)
✅ **Auto-backups** included

## Next Steps

After migration:
1. Test login - should be instant!
2. Test other features (creating outfits, posts, etc.)
3. Your app is now production-ready for demos!

---

**Estimated Time**: 10-15 minutes
**Cost**: $0 (both Supabase and Render free tiers)

