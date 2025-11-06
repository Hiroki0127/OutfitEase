# Replace [YOUR-PASSWORD] in Connection String

## Your Connection String Template
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:[YOUR-PASSWORD]@aws-1-us-east-2.pooler.supabase.com:5432/postgres
```

## Step 1: Find Your Supabase Database Password

**Option A: If you know your password**
- Use your Supabase database password (the one you set when creating the project)

**Option B: If you don't remember it**
1. Go to Supabase Dashboard → Settings → Database
2. Look for "Database password" section
3. If you see "Reset database password" or "Show password", use that
4. Or reset it to create a new password

## Step 2: Replace [YOUR-PASSWORD]

### If your password has NO special characters:
Just replace `[YOUR-PASSWORD]` with your password:

```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:YourPassword123@aws-1-us-east-2.pooler.supabase.com:5432/postgres
```

### If your password has special characters (like `!`, `@`, `#`, etc.):
You need to URL-encode them:

**Example:** If your password is `Usausa127!!`:
- `!` → `%21`
- `!!` → `%21%21`
- Encoded password: `Usausa127%21%21`

So the connection string becomes:
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:Usausa127%21%21@aws-1-us-east-2.pooler.supabase.com:5432/postgres
```

## Special Characters Encoding

- `!` → `%21`
- `@` → `%40`
- `#` → `%23`
- `$` → `%24`
- `%` → `%25`
- `&` → `%26`
- `+` → `%2B`
- `=` → `%3D`
- `/` → `%2F`
- `?` → `%3F`
- ` ` (space) → `%20`

## Step 3: Update Render

1. Go to https://dashboard.render.com
2. Click `outfitease-backend` → "Environment" tab
3. Find `DATABASE_URL` and click "Edit"
4. Paste your complete connection string (with password replaced)
5. Click "Save Changes"
6. Wait 1-2 minutes for deployment

## About Port 5432 vs 6543

I notice your connection string shows port `5432`. That's fine for Session mode pooler. Port `6543` is the dedicated pooler port, but `5432` can work too depending on Supabase's configuration.

## Quick Test

After updating Render:
1. Wait 1-2 minutes
2. Try login from your iOS app
3. Should work! ✅

## If You Need to Reset Password

1. Supabase Dashboard → Settings → Database
2. Find "Database password" section
3. Click "Reset database password" if available
4. Set a new password (remember it!)
5. Update connection string with new password
6. Update Render

## Summary

**What to do:**
1. Get your Supabase database password
2. Replace `[YOUR-PASSWORD]` in the connection string
3. URL-encode any special characters (! → %21, etc.)
4. Update Render's `DATABASE_URL`
5. Test login

**Example (if password is `Usausa127!!`):**
```
postgresql://postgres.hpzcerpgdnwrmpuiwlak:Usausa127%21%21@aws-1-us-east-2.pooler.supabase.com:5432/postgres
```

