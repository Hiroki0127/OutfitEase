# Fix Your Pooler Connection String

## Your Current String
```
postgres://postgres:Usausa127!!@aws-0-us-east-2.pooler.supabase.com:5432/postgres
```

## Issues to Fix

### 1. Password Encoding ⚠️
Your password has `!!` which needs to be URL-encoded:
- `!` becomes `%21`
- So `!!` becomes `%21%21`

### 2. Port Number ⚠️
You're using port `5432`, but for Session pooler it's better to use `6543`:
- Port `5432` = Direct connection (may still have IPv6 issues)
- Port `6543` = Pooler connection (handles IPv4/IPv6 properly) ✅

### 3. Protocol ✅
`postgres://` works, but `postgresql://` is more standard (both work though)

## Corrected Connection String

### Option 1: Use Pooler Port (Recommended)
```
postgresql://postgres:Usausa127%21%21@aws-0-us-east-2.pooler.supabase.com:6543/postgres
```

### Option 2: If you prefer port 5432
```
postgresql://postgres:Usausa127%21%21@aws-0-us-east-2.pooler.supabase.com:5432/postgres
```

## Quick Fix: URL Encode Your Password

Your password: `Usausa127!!`
- Encode `!` → `%21`
- Encoded password: `Usausa127%21%21`

## Steps to Use It

1. **Copy the corrected string:**
   ```
   postgresql://postgres:Usausa127%21%21@aws-0-us-east-2.pooler.supabase.com:6543/postgres
   ```

2. **Update Render:**
   - Go to https://dashboard.render.com
   - Click `outfitease-backend` → "Environment" tab
   - Edit `DATABASE_URL`
   - Paste the corrected string
   - Save (auto-deploys)

3. **Test:**
   - Wait 1-2 minutes for deployment
   - Try login from iOS app
   - Should work! ✅

## Why Port 6543?

- Port `6543` = PgBouncer pooler protocol (handles IPv4/IPv6)
- Port `5432` = Direct PostgreSQL (may still try IPv6 first)

**Recommendation:** Use port `6543` for best compatibility with Render's IPv4 network.

