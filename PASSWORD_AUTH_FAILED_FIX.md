# Fix: "password authentication failed for user postgres"

## Error
```
"password authentication failed for user \"postgres\"", code: "28P01"
```

This means the password in your `DATABASE_URL` is **wrong**.

## Solution: Get Correct Connection String from Supabase

### Step 1: Get Connection String from Supabase

1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click **Settings** → **Database**
4. Scroll to **"Connection pooling"**
5. Make sure **"Session" mode** is selected
6. Click **"Copy"** on the connection string (URI format)
   - This will have the **correct password already encoded**!

### Step 2: Update Render

1. Go to https://dashboard.render.com
2. Click `outfitease-backend` → **"Environment"** tab
3. Find `DATABASE_URL` and click **"Edit"**
4. **Delete the old value completely**
5. **Paste the connection string from Supabase** (don't modify it)
6. Click **"Save Changes"**
7. Wait 1-2 minutes for deployment

### Step 3: Verify Password Encoding

If you're manually entering the password, make sure special characters are URL-encoded:
- `!` → `%21`
- `!!` → `%21%21`
- `@` → `%40`
- `#` → `%23`
- etc.

**But:** It's safer to just copy from Supabase!

## Why This Happens

The error `28P01` means:
- ✅ Connection to database works
- ✅ Username `postgres` is correct
- ❌ Password doesn't match

Common causes:
1. Password not URL-encoded properly
2. Wrong password entered
3. Password changed in Supabase but not updated in Render

## About the iOS Warning

The `nw_connection_copy_protocol_metadata_internal` message is just an iOS networking warning - **safe to ignore**. It's not causing your login to fail.

## Quick Check

After updating Render:
1. Wait 1-2 minutes for deployment
2. Try login again
3. Should work! ✅

## If Still Not Working

1. **Reset Supabase password:**
   - Supabase Dashboard → Settings → Database
   - Click "Reset database password"
   - Get new connection string with new password
   - Update Render again

2. **Verify connection string format:**
   ```
   postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-us-east-2.pooler.supabase.com:6543/postgres
   ```
   Should have:
   - `pooler.supabase.com` (not `db.*.supabase.co`)
   - Port `6543` (not `5432`)
   - Password properly encoded

## Summary

**The fix:** Copy the connection string directly from Supabase (don't type it manually) and paste into Render. This ensures the password is correct and properly encoded.

