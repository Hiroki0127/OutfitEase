# Xcode Simulator Troubleshooting

## Issue: Seeing "item at [time]" instead of app interface

### Step 1: Make Sure You're Running the App (Not Preview)

1. **Stop Preview (if running)**
   - If you see a preview canvas, close it
   - Press `Cmd + Option + P` to pause preview

2. **Run the Actual App**
   - Press `Cmd + R` to build and run
   - OR click the Play button (▶️) in Xcode toolbar
   - Make sure you select an iPhone simulator (e.g., iPhone 15, iPhone 16)

### Step 2: Check Firebase Configuration

The app requires Firebase to be configured:

1. **Verify GoogleService-Info.plist exists**
   - Should be in `outfiteaseFrontend/` directory
   - Check if it's added to the Xcode project

2. **If missing, you'll need to:**
   - Add Firebase to your project
   - Download GoogleService-Info.plist from Firebase Console
   - Add it to the Xcode project

### Step 3: Check Console for Errors

1. **Open Console in Xcode**
   - Bottom panel → Console tab
   - Look for error messages

2. **Common Errors:**
   - `FirebaseApp.configure()` failing
   - Missing GoogleService-Info.plist
   - Network errors (can't connect to backend)

### Step 4: Clean Build

1. **Clean Build Folder**
   - `Product` → `Clean Build Folder` (or `Cmd + Shift + K`)

2. **Delete Derived Data** (if needed)
   - `Xcode` → `Settings` → `Locations`
   - Click arrow next to Derived Data path
   - Delete `outfiteaseFrontend-...` folder

3. **Rebuild**
   - `Product` → `Build` (or `Cmd + B`)
   - Then `Product` → `Run` (or `Cmd + R`)

### Step 5: Verify Simulator is Running

1. **Check Simulator Status**
   - Should see iPhone simulator window open
   - Home screen should be visible

2. **Reset Simulator** (if needed)
   - `Device` → `Erase All Content and Settings...`

### Step 6: Check What Should Appear

The app should show:
- **If not logged in**: LoginView with "OutfitEase" title and login form
- **If logged in**: HomeView with tab bar (Home, Clothes, Outfits, Planning, More)

### Quick Fix Commands

In Xcode:
1. `Cmd + Shift + K` - Clean build
2. `Cmd + B` - Build
3. `Cmd + R` - Run

### If Still Not Working

Check these files:
- ✅ `outfiteaseFrontendApp.swift` exists and has `@main`
- ✅ `GoogleService-Info.plist` exists and is added to project
- ✅ Simulator is selected (not a device)
- ✅ No build errors in Issue Navigator

