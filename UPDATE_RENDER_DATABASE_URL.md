# How to Update DATABASE_URL in Render

## ⚠️ Current Error
```
"password authentication failed for user \"postgres\"", code: "28P01"
```

This means the `DATABASE_URL` in Render has the wrong password.

## ✅ Step-by-Step Fix

### 1. Get the Correct Connection String from Supabase

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project (`hpzcerpgdnwrmpuiwlak`)
3. Go to **Settings** → **Database**
4. Scroll to **Connection pooling**
5. Select **Session** mode (important!)
6. Click **Copy** on the connection string (URI format)

It should look like:
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:[YOUR-PASSWORD]@aws-1-us-east-2.pooler.supabase.com:6543/postgres
```

**Important**: Use port **6543** (Session pooler port) not 5432.

### 2. Update Render Environment Variable

1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your service: **OutfitEase** (or `outfitease-backend`)
3. Go to **Environment** tab
4. Find `DATABASE_URL` in the list
5. Click **Edit** (or the pencil icon)
6. **Delete the entire old value**
7. **Paste the connection string from Supabase** (step 1)
8. Make sure the password is included (not `[YOUR-PASSWORD]`)
9. Click **Save**

### 3. Wait for Auto-Deploy

- Render will automatically redeploy after saving
- Wait 1-2 minutes for deployment to complete
- Check the **Logs** tab to see if it's deploying

### 4. Verify Connection

Check the logs in Render:
- Go to **Logs** tab
- Look for: `✅ Database connection test successful`
- If you see: `❌ Database connection test failed`, the password is still wrong

### 5. Test Registration/Login

Try registering a new user in the iOS app. It should work now!

## 🔍 Troubleshooting

### Still Getting Password Error?

**Check the password in the connection string:**
- The password should be URL-encoded automatically by Supabase
- If you see `%21`, that's `!` (exclamation mark)
- If you see `%40`, that's `@` (at symbol)

**Verify in Supabase:**
1. Go to Supabase Dashboard → Settings → Database
2. Check the **Connection string** section
3. Make sure you're copying from **Session** mode, not **Transaction** mode
4. The password should be visible in the connection string (not hidden)

### Wrong Port?

If you're using port `5432`, try port `6543`:
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:YOUR-PASSWORD@aws-1-us-east-2.pooler.supabase.com:6543/postgres
```

### Connection String Format

Your connection string should be:
```
postgresql://postgres.PROJECT_REF:PASSWORD@REGION.pooler.supabase.com:6543/postgres
```

**Example:**
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:Usausa127%21%21@aws-1-us-east-2.pooler.supabase.com:6543/postgres
```

Where:
- `postgres.hpzcerpgdnwrmpuiwlak` = username (includes project ref)
- `Usausa127%21%21` = password (URL-encoded `Usausa127!!`)
- `aws-1-us-east-2.pooler.supabase.com` = host
- `6543` = port (Session pooler)
- `postgres` = database name

## ✅ Your Corrected Connection String

Based on your info, try this:

```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:Usausa127%21%21@aws-1-us-east-2.pooler.supabase.com:6543/postgres
```

**Changes:**
- Port changed from `5432` to `6543` (Session pooler port)
- Password should be `Usausa127!!` (decoded from `Usausa127%21%21`)

**If this still doesn't work:**
1. Go to Supabase Dashboard
2. Copy the connection string directly (don't type it)
3. Make sure the password matches your actual Supabase database password

