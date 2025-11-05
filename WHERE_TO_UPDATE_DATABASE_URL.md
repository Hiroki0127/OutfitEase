# Where to Update DATABASE_URL

## Summary
✅ **Yes, use the pooler connection string in BOTH places:**
1. **Render Environment Variable** (production)
2. **Local `.env` file** (for local testing)

## Connection String to Use Everywhere

```
postgresql://postgres:Usausa127%21%21@aws-0-us-east-2.pooler.supabase.com:6543/postgres
```

## 1. Render Environment Variable (Production) ✅

**Location:** Render Dashboard → `outfitease-backend` → Environment tab

**Why:** 
- Render uses IPv4 network
- Pooler handles IPv4/IPv6 automatically
- Fixes the `ENETUNREACH` error

**Steps:**
1. Go to https://dashboard.render.com
2. Click `outfitease-backend` service
3. Click "Environment" tab
4. Find `DATABASE_URL`
5. Click "Edit"
6. Paste the pooler connection string
7. Save (auto-deploys)

## 2. Local `.env` File (Development) ✅

**Location:** `backend/.env`

**Why:**
- Consistency with production
- Same connection = same behavior
- Easier testing
- No need to switch between different connection strings

**Steps:**
1. Open `backend/.env` file
2. Find `DATABASE_URL=` line
3. Replace with the pooler connection string:
   ```
   DATABASE_URL=postgresql://postgres:Usausa127%21%21@aws-0-us-east-2.pooler.supabase.com:6543/postgres
   ```
4. Save file
5. Restart local server if running

## Alternative: Use Direct Connection Locally (Optional)

If you want to use direct connection (port 5432) locally, you can:

```
DATABASE_URL=postgresql://postgres:Usausa127%21%21@db.hpzcerpgdnwrmpuiwlak.supabase.co:5432/postgres
```

**But:** Using pooler everywhere is **recommended** for consistency.

## Benefits of Using Pooler Everywhere

- ✅ Same connection = same behavior
- ✅ No confusion about which connection to use
- ✅ Easier debugging (same errors in local and production)
- ✅ Pooler is optimized for cloud environments
- ✅ Handles connection limits better

## Summary

**Use the same pooler connection string in both:**
- Render `DATABASE_URL` environment variable
- Local `backend/.env` file

This ensures your local and production environments match exactly! 🎯

