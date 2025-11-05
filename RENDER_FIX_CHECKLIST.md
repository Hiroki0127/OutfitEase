# Render Fix Checklist

## Current Problem
❌ **Error**: `ENETUNREACH` - IPv6 connection issue when Render tries to connect to Supabase

## What Needs to Be Done

### ✅ Step 1: Verify DATABASE_URL in Render
1. Go to https://dashboard.render.com
2. Click your `outfitease-backend` service
3. Click "Environment" tab
4. Check `DATABASE_URL`:
   - Should be: `postgresql://postgres:YOUR_PASSWORD@db.hpzcerpgdnwrmpuiwlak.supabase.co:5432/postgres`
   - Make sure `YOUR_PASSWORD` is replaced with actual Supabase password
   - If it still has `[YOUR_PASSWORD]` or Render's database URL → Update it!

### ✅ Step 2: Deploy IPv4 Fix
The code fix is ready. Deploy it:

```bash
cd /Users/hiro/OutfitEase
git add backend/db.js backend/controllers/authController.js
git commit -m "Fix Supabase IPv6 connection issue"
git push origin main
```

Wait 1-2 minutes for Render to deploy.

### ✅ Step 3: Verify Supabase Schema
1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click "Table Editor"
4. Should see tables like: `users`, `clothing_items`, `outfits`, etc.
5. If missing → Run `backend/schema.sql` in Supabase SQL Editor

### ✅ Step 4: Test Login
After deployment:
1. Try logging in from iOS app
2. Should work without timeouts!

## Quick Status Check

After deploying, check Render logs:
1. Go to Render Dashboard → `outfitease-backend` → "Logs" tab
2. Look for:
   - ✅ `Database connection test successful` → Good!
   - ❌ `Database connection test failed` → Check DATABASE_URL
   - ❌ `ENETUNREACH` → IPv4 fix not deployed yet

## Summary

**Main issue**: IPv6 connection error to Supabase
**Fix**: Updated `db.js` to force IPv4 connections
**Status**: Code ready, needs deployment

