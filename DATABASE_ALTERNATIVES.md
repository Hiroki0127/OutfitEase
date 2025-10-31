# Free PostgreSQL Database Alternatives

Since Render's free tier only allows one database, here are free PostgreSQL options you can use with your Render web service:

## Option 1: Supabase (Recommended) ⭐

**Best for**: Easy setup, generous free tier, great documentation

**Setup Steps:**
1. Sign up at [supabase.com](https://supabase.com)
2. Create a new project
3. Get your connection string from Settings → Database → Connection string
   - Use the "URI" format (starts with `postgresql://...`)
4. Copy the connection string

**Free Tier Limits:**
- 500 MB database size
- 2 GB bandwidth/month
- Unlimited API requests
- Auto-backups

**Update Render:**
- Add `DATABASE_URL` environment variable to your Render web service
- Use the Supabase connection string

**Pros:**
- ✅ Very easy setup
- ✅ Great free tier
- ✅ Auto-scaling
- ✅ Built-in dashboard
- ✅ PostgREST API included (bonus)

**Cons:**
- None for free tier usage

---

## Option 2: Neon

**Best for**: Modern PostgreSQL with branching features

**Setup Steps:**
1. Sign up at [neon.tech](https://neon.tech)
2. Create a new project
3. Copy the connection string from the dashboard

**Free Tier Limits:**
- 0.5 GB storage
- Unlimited projects
- Branching features (dev/test branches)

**Pros:**
- ✅ Modern platform
- ✅ Branching (like Git for databases)
- ✅ Easy to scale

**Cons:**
- Smaller storage than Supabase

---

## Option 3: Railway

**Best for**: Simple, all-in-one platform

**Setup Steps:**
1. Sign up at [railway.app](https://railway.app)
2. Create a new project
3. Add PostgreSQL service
4. Get connection string from Variables tab

**Free Tier Limits:**
- $5 credit/month
- PostgreSQL included

**Pros:**
- ✅ Can host both web service AND database
- ✅ Simple pricing
- ✅ Easy deployment

**Cons:**
- Credit-based (may run out if heavy usage)

---

## Option 4: ElephantSQL

**Best for**: Simple PostgreSQL hosting

**Setup Steps:**
1. Sign up at [elephantsql.com](https://www.elephantsql.com)
2. Create a new instance
3. Copy connection string

**Free Tier Limits:**
- 20 MB database
- 5 concurrent connections

**Pros:**
- ✅ Very simple
- ✅ Dedicated PostgreSQL

**Cons:**
- ⚠️ Very small free tier (20 MB)

---

## Recommendation: Use Supabase

**Why Supabase?**
1. ✅ Generous free tier (500 MB)
2. ✅ Easy to use
3. ✅ Great documentation
4. ✅ Works perfectly with Node.js/Express
5. ✅ No credit limits

---

## Quick Setup Guide (Supabase)

### 1. Create Supabase Project
1. Go to [supabase.com](https://supabase.com)
2. Sign up / Log in
3. Click "New Project"
4. Fill in:
   - Name: `outfitease`
   - Database Password: (create a strong password)
   - Region: Choose closest to you
5. Wait ~2 minutes for project to be created

### 2. Get Connection String
1. Go to Settings → Database
2. Scroll to "Connection string"
3. Select "URI" tab
4. Copy the connection string (looks like: `postgresql://postgres:[PASSWORD]@[HOST]:5432/postgres`)

### 3. Update Render Web Service
1. Go to your `outfitease-backend` service on Render
2. Navigate to "Environment" tab
3. Add/Update `DATABASE_URL`:
   - Key: `DATABASE_URL`
   - Value: (paste Supabase connection string)
4. Save changes
5. Service will automatically redeploy

### 4. Initialize Database Schema
1. Use Supabase SQL Editor:
   - Go to SQL Editor in Supabase dashboard
   - Copy contents of `backend/schema.sql`
   - Paste and run

OR

2. Use Render Shell:
   ```bash
   psql $DATABASE_URL -f backend/schema.sql
   ```

---

## Alternative: Migrate Everything to Railway

If you want everything in one place:

### Setup on Railway:
1. Sign up at [railway.app](https://railway.app)
2. Create new project
3. Add PostgreSQL service
4. Deploy your backend:
   - Connect GitHub repo
   - Railway auto-detects Node.js
   - Set environment variables
   - Deploy

**Benefits:**
- Everything in one platform
- Simple deployment
- $5 credit/month covers both services

---

## Comparison Table

| Service | Free Storage | Best For | Difficulty |
|---------|-------------|----------|------------|
| **Supabase** | 500 MB | Best overall | ⭐ Easy |
| **Neon** | 0.5 GB | Modern features | ⭐⭐ Medium |
| **Railway** | $5 credit | All-in-one | ⭐ Easy |
| **ElephantSQL** | 20 MB | Simple setup | ⭐ Easy |

---

**Recommendation**: Use **Supabase** for database + **Render** for web service (best of both worlds)

