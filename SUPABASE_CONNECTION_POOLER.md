# Use Supabase Connection Pooler (Recommended Fix)

## The Problem
Render is trying to connect to Supabase using IPv6, which causes `ENETUNREACH` errors.

## Solution: Use Supabase Connection Pooler

Supabase provides a **connection pooler** that's specifically designed for serverless/cloud environments like Render. It handles IPv4/IPv6 issues automatically.

## Steps

### 1. Get Connection Pooler URL

1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click **Settings** → **Database**
4. Scroll down to **"Connection pooling"**
5. Select **"Session" mode** (recommended for Render)
6. Copy the **"Connection string"** (URI format)

It will look like:
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

**Note**: Port is `6543` (pooler) instead of `5432` (direct)

### 2. Update Render Environment Variable

1. Go to https://dashboard.render.com
2. Click your `outfitease-backend` service
3. Click **"Environment"** tab
4. Find `DATABASE_URL` and click **"Edit"**
5. Replace with the **pooler connection string** from Step 1
6. Click **"Save Changes"**
7. Render will automatically redeploy (1-2 minutes)

### 3. Benefits of Connection Pooler

- ✅ Handles IPv4/IPv6 automatically
- ✅ Better connection management for serverless
- ✅ Prevents connection exhaustion
- ✅ Optimized for cloud environments
- ✅ No code changes needed!

## Alternative: Direct Connection (Current Approach)

If you want to keep using direct connection (port 5432), the current code fixes should work, but you may need to wait for Render to fully redeploy.

The connection pooler is **strongly recommended** for Render's free tier.

