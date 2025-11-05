# Setup Users in Supabase

## Step 1: Run Schema in Supabase

**CRITICAL**: You must run the schema first to create the tables!

1. Go to https://supabase.com/dashboard
2. Select your `outfitease` project
3. Click **"SQL Editor"** in the left sidebar
4. Click **"New query"**
5. Open `backend/schema.sql` from your project
6. Copy the **entire contents**
7. Paste into Supabase SQL Editor
8. Click **"Run"** (or press Cmd/Ctrl + Enter)
9. ✅ Should see "Success. No rows returned" or similar

## Step 2: Create Test User

### Option A: Using Script (Recommended)

1. **Make sure your local `.env` points to Supabase:**
   ```bash
   cd backend
   # Check DATABASE_URL
   grep DATABASE_URL .env
   ```
   
   Should be: `postgresql://postgres:YOUR_PASSWORD@db.hpzcerpgdnwrmpuiwlak.supabase.co:5432/postgres`

2. **Run the setup script:**
   ```bash
   cd backend
   node scripts/setupSupabaseUser.js
   ```

3. **Should see:**
   ```
   ✅ Test user ready!
   📧 Login Credentials:
      Email: hiro@example.com
      Password: password123
   ```

### Option B: Manual SQL (Alternative)

Run this in Supabase SQL Editor:

```sql
-- Create test user (password: password123)
INSERT INTO users (email, username, password_hash, role)
VALUES (
  'hiro@example.com',
  'hiro',
  '$2a$10$rKf8K5J8Q5J8Q5J8Q5J8QOe5J8Q5J8Q5J8Q5J8Q5J8Q5J8Q5J8Q5J8Q', -- This is bcrypt hash for 'password123'
  'user'
);
```

**Note**: The hash above is just an example. Better to use the script which generates the correct hash.

## Step 3: Verify User Created

1. Go to Supabase Dashboard → **"Table Editor"**
2. Click **"users"** table
3. Should see your user with email `hiro@example.com`

## Step 4: Test Login

Now you can test login from your iOS app:
- **Email**: `hiro@example.com`
- **Password**: `password123`

Or test from command line:
```bash
cd backend
node test-render.js
```

## Migrating Local Users (Optional)

If you had users in your local database and want to migrate them:

1. **Export from local database:**
   ```bash
   psql postgresql://hiroki:Usausa127%21@localhost:5432/outfitease -c "SELECT email, username, password_hash, role FROM users;" > users_backup.txt
   ```

2. **Import to Supabase:**
   - Go to Supabase SQL Editor
   - Run INSERT statements for each user

**Note**: You can't migrate passwords directly - users will need to reset them, or you can create new users with known passwords.

---

## Summary

**What you need to do:**
1. ✅ Run `backend/schema.sql` in Supabase SQL Editor
2. ✅ Create test user (use script or manual SQL)
3. ✅ Test login from app

**After this:**
- Users will be stored in Supabase
- Render will connect to Supabase
- No more local database needed!

