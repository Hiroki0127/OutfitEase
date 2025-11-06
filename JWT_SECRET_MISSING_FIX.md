# Fix: JWT_SECRET Missing in Render

## ✅ Good News!
The database connection is working now! The password authentication error is gone.

## ⚠️ Current Issue
```
"Server configuration error"
```

This means `JWT_SECRET` is not set in Render's environment variables.

## 🔧 Fix: Add JWT_SECRET to Render

### Step 1: Generate a JWT Secret
You can use any random string. Here are options:

**Option A: Use a random string generator**
- Go to: https://randomkeygen.com/
- Copy a "CodeIgniter Encryption Keys" value (64 characters)
- Or use any long random string

**Option B: Use a simple command (if you have Node.js locally)**
```bash
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"
```

### Step 2: Add to Render
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click on your service: **OutfitEase** (or `outfitease-backend`)
3. Go to **Environment** tab
4. Click **Add Environment Variable**
5. Set:
   - **Key**: `JWT_SECRET`
   - **Value**: Paste your generated secret (the long random string)
6. Click **Save**

### Step 3: Wait for Auto-Deploy
- Render will automatically redeploy after saving
- Wait 1-2 minutes for deployment to complete

### Step 4: Test Again
Try registering a new user in the iOS app. It should work now! 🎉

## 📋 Example JWT_SECRET Value

You can use something like:
```
your-super-secret-jwt-key-1234567890abcdefghijklmnopqrstuvwxyz
```

Or generate a random one:
```
a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0u1v2w3x4y5z6
```

**Important**: 
- Make it long (at least 32 characters)
- Don't share it publicly
- It's used to sign JWT tokens for authentication

## ✅ After Adding JWT_SECRET

1. Wait for Render to redeploy (check Logs tab)
2. Try registration/login again
3. Should work! 🎉

## Summary

The database connection is fixed! You just need to add `JWT_SECRET` to Render's environment variables.

