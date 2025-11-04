# Keep Render Server Awake (Free Solution)

## Problem
Render's free tier spins down after 15 minutes of inactivity, causing 50-second delays when recruiters try to use your app.

## Solution: UptimeRobot (Free Keep-Alive Service)

### Step 1: Sign Up for UptimeRobot
1. Go to [uptimerobot.com](https://uptimerobot.com)
2. Click "Sign Up" (it's free)
3. Create account with email

### Step 2: Add Monitor
1. After login, click "Add New Monitor"
2. Configure:
   - **Monitor Type**: HTTP(s)
   - **Friendly Name**: OutfitEase Backend
   - **URL**: `https://outfitease.onrender.com`
   - **Monitoring Interval**: 5 minutes
   - **Alert Contacts**: (optional - add your email if you want notifications)
3. Click "Create Monitor"

### Step 3: Done!
- UptimeRobot will ping your server every 5 minutes
- This keeps it awake (no spin-down)
- **No more 50-second delays!**

### Alternative: Use cron-job.org (Another Free Option)

1. Go to [cron-job.org](https://cron-job.org)
2. Sign up (free)
3. Create cron job:
   - URL: `https://outfitease.onrender.com`
   - Schedule: Every 5 minutes
   - Save

Both are free and work great!

---

## Test Your Setup

After setting up, test:
```bash
curl https://outfitease.onrender.com
```

Should respond instantly (no 50-second delay)!

---

## Cost
- **Render**: Free (you already have this)
- **UptimeRobot/cron-job.org**: Free
- **Total**: $0/month

---

## Result
✅ Server stays awake 24/7
✅ No more spin-down delays
✅ Recruiters get instant responses
✅ Professional demo experience

