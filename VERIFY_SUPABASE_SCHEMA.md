# How to Verify Schema is in Supabase

## Step 1: Check if Tables Exist

1. **Go to Supabase Dashboard**: https://supabase.com/dashboard
2. **Select your `outfitease` project**
3. **Click "Table Editor"** in the left sidebar
4. **Look for these tables**:
   - ✅ `users`
   - ✅ `clothing_items`
   - ✅ `outfits`
   - ✅ `outfit_items`
   - ✅ `outfit_planning`
   - ✅ `posts`
   - ✅ `post_likes`
   - ✅ `post_comments`
   - ✅ `saved_outfits`
   - ✅ `weather_data`
   - ✅ `generated_outfits`
   - ✅ `user_preferences`
   - ✅ `trends`

**If you see all these tables** → ✅ Schema is already set up!

**If you DON'T see these tables** → You need to run the schema (see Step 2)

---

## Step 2: Run Schema if Not Already Done

1. **Go to SQL Editor** (in Supabase dashboard)
2. **Click "New query"**
3. **Open** `backend/schema.sql` from your project
4. **Copy the ENTIRE file** (all 194 lines)
5. **Paste into SQL Editor**
6. **Click "Run"** (or press Cmd/Ctrl + Enter)
7. **You should see**: 
   - "Success. No rows returned" 
   - OR "Success. X rows returned"
   - OR just no errors

---

## Step 3: Verify with a Test Query

1. **In SQL Editor**, run this query:
   ```sql
   SELECT table_name 
   FROM information_schema.tables 
   WHERE table_schema = 'public' 
   ORDER BY table_name;
   ```
2. **Should show** all the tables listed above

---

## Quick Check: Try to Insert a User

1. **In SQL Editor**, run:
   ```sql
   SELECT COUNT(*) FROM users;
   ```
2. **Should return**: `0` (if no users yet) or a number (if users exist)
3. **If you get an error**: Table doesn't exist → need to run schema

---

## Alternative: Check via Table Editor

1. **Go to Table Editor** in Supabase
2. **Click on `users` table** (if it exists)
3. **Should see** columns like:
   - `id` (UUID)
   - `email` (text)
   - `username` (text)
   - `password_hash` (text)
   - `avatar_url` (text)
   - `created_at` (timestamp)
   - `role` (text)

**If you see this** → ✅ Schema is set up correctly!

---

## If Schema is Missing

If tables don't exist, follow **Step 2** above to run `backend/schema.sql` in Supabase SQL Editor.

