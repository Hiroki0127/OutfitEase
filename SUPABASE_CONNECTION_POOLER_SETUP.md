# Supabase Connection Pooler Setup (IPv4 Fix)

## The Issue
Supabase shows: "Not IPv4 compatible - Use Session Pooler if on a IPv4 network"

## Solution: Use Session Mode Pooler

Render uses IPv4, so you need to use **Session mode** pooler.

## Step-by-Step Setup

### 1. Get Session Pooler Connection String

1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click **Settings** → **Database**
4. Scroll down to **"Connection pooling"**
5. **Important**: Make sure you're in **"Session" mode** (not Transaction mode)
6. Copy the **"Connection string"** (URI format)

**Session mode connection string looks like:**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres?pgbouncer=true
```

**Key differences:**
- Port: `6543` (pooler) instead of `5432` (direct)
- Host: `pooler.supabase.com` instead of `db.*.supabase.co`
- May include `?pgbouncer=true` parameter

### 2. Update Render Environment Variable

1. Go to https://dashboard.render.com
2. Click your `outfitease-backend` service
3. Click **"Environment"** tab
4. Find `DATABASE_URL` and click **"Edit"**
5. **Replace entire value** with the Session pooler connection string
6. Click **"Save Changes"**
7. Render will automatically redeploy (1-2 minutes)

### 3. Verify in Render Logs

After deployment, check Render logs:
1. Go to Render Dashboard → `outfitease-backend` → "Logs" tab
2. Look for:
   - ✅ `✅ Database connection test successful` → Working!
   - ❌ `ENETUNREACH` → Still using wrong connection string

### 4. Test Login

After deployment completes:
- Try logging in from your iOS app
- Should work without IPv6 errors!

## Why Session Mode?

- ✅ **IPv4 compatible** (works with Render)
- ✅ **Full PostgreSQL features** (prepared statements, transactions, etc.)
- ✅ **Connection pooling** (handles many concurrent connections)
- ✅ **No code changes needed**

## Transaction Mode vs Session Mode

- **Transaction Mode**: Faster, but limited features (not IPv4 compatible on free tier)
- **Session Mode**: Full features, IPv4 compatible ✅ (use this!)

## Troubleshooting

**Still getting IPv6 errors?**
- Make sure you're using **Session mode**, not Transaction mode
- Verify the connection string has `pooler.supabase.com` in the host
- Check that port is `6543` (not `5432`)

**Connection string format:**
```
postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-[REGION].pooler.supabase.com:6543/postgres
```

The `[PROJECT-REF]` should match your project reference (like `hpzcerpgdnwrmpuiwlak`).

---

## Summary

**What to do:**
1. ✅ Get Session mode pooler connection string from Supabase
2. ✅ Update `DATABASE_URL` in Render with pooler string
3. ✅ Wait for deployment
4. ✅ Test login

**No code changes needed!** The pooler handles IPv4/IPv6 automatically.

