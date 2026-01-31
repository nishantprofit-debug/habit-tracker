# ✅ Deployment Checklist - Follow This Order

## 📋 Part 1: Supabase Setup (15 minutes)

### Step 1: Create Database Tables
- [ ] Open Supabase Dashboard
- [ ] Click **SQL Editor** (left sidebar)
- [ ] Click **+ New query**
- [ ] Copy entire SQL from `supabase_schema.sql`
- [ ] Paste in SQL Editor
- [ ] Click **RUN** button
- [ ] Verify: "Success. No rows returned"
- [ ] Go to **Table Editor** → Should see 4 tables:
  - ✅ habits
  - ✅ daily_logs
  - ✅ user_stats
  - ✅ reports

### Step 2: Enable Email Authentication
- [ ] Go to **Authentication** → **Providers**
- [ ] Find **Email** provider
- [ ] Toggle **ON** "Enable Email provider"
- [ ] ✅ Check "Enable email confirmations"
- [ ] ✅ Check "Secure email change"
- [ ] Click **Save**

### Step 3: Configure Google Sign-In

**Part A: Google Cloud Console**
- [ ] Go to https://console.cloud.google.com
- [ ] Create new project: "Habit Tracker"
- [ ] Enable **Google+ API**:
  - APIs & Services → Library
  - Search "Google+ API"
  - Click Enable
- [ ] Create OAuth credentials:
  - APIs & Services → Credentials
  - + CREATE CREDENTIALS → OAuth client ID
  - Type: **Web application**
  - Name: "Habit Tracker Web"
  - Authorized redirect URIs:
    ```
    https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback
    ```
  - Click **Create**
  - **COPY** Client ID
  - **COPY** Client Secret

**Part B: Supabase Configuration**
- [ ] Back to Supabase Dashboard
- [ ] Authentication → Providers → **Google**
- [ ] Toggle **ON** "Enable Google provider"
- [ ] Paste **Client ID** from Google
- [ ] Paste **Client Secret** from Google
- [ ] ✅ Check "Skip nonce check" (for iOS)
- [ ] Click **Save**

### Step 4: Configure Site URL
- [ ] Authentication → **URL Configuration**
- [ ] Site URL: `http://localhost:3000` (for development)
- [ ] Additional Redirect URLs: (leave empty for now)
- [ ] Click **Save**

### Step 5: Get API Keys
- [ ] Go to **Settings** → **API**
- [ ] **COPY and SAVE** these values:
  ```
  Project URL: https://____________.supabase.co
  anon/public key: eyJ___________________________
  service_role key: eyJ___________________________ (KEEP SECRET!)
  ```
- [ ] Go to **Settings** → **API** → **JWT Settings**
- [ ] **COPY** JWT Secret: `_______________________`

---

## 📋 Part 2: Render Setup (10 minutes)

### Step 1: Create Web Service
- [ ] Go to https://dashboard.render.com
- [ ] Click **+ New** → **Web Service**
- [ ] Choose deployment method:
  - Option A: Connect GitHub repository
  - Option B: Public Git repository URL

### Step 2: Configure Service
Fill in these details:
```
Name: habittracker-api
Region: Oregon (or closest)
Branch: main
Root Directory: backend
Runtime: Go
Build Command: go build -o main ./cmd/server
Start Command: ./main
Instance Type: Free
```

### Step 3: Environment Variables
Click **Advanced** → Add these environment variables:

```env
APP_ENV=production
PORT=8080
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your_anon_key_from_supabase
SUPABASE_SERVICE_KEY=your_service_role_key
SUPABASE_JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_key (optional - for AI features)
```

- [ ] Add all environment variables
- [ ] Double-check all values are correct
- [ ] Click **Create Web Service**

### Step 4: Wait for Deployment
- [ ] Watch deployment logs
- [ ] Wait 5-10 minutes for first deploy
- [ ] Check for "Live" status
- [ ] Copy your app URL: `https://habittracker-api.onrender.com`

### Step 5: Test Backend
- [ ] Open browser
- [ ] Visit: `https://habittracker-api.onrender.com/health`
- [ ] Should see: `{"status": "ok"}` or similar
- [ ] ✅ Backend is working!

---

## 📋 Part 3: Update Flutter App (5 minutes)

### Step 1: Update Supabase Credentials

**File:** `app/lib/main.dart`

Find this code (around line 17):
```dart
await Supabase.initialize(
  url: 'https://cwjcfsnpqiyzluybmwxc.supabase.co',
  anonKey: 'sb_publishable_AHi_CjxdglLTNni1AyFQYA_EvA6Vaoc',
);
```

Replace with YOUR values:
```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_PROJECT_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

- [ ] Update `url`
- [ ] Update `anonKey`
- [ ] Save file

### Step 2: Create API Constants File

**File:** `app/lib/core/constants/api_endpoints.dart`

Check if this file exists. If not, create it with:

```dart
class ApiEndpoints {
  // Supabase
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  
  // Render Backend
  static const String backendUrl = 'https://habittracker-api.onrender.com';
  
  // Supabase REST endpoints
  static const String habits = '/rest/v1/habits';
  static const String dailyLogs = '/rest/v1/daily_logs';
  static const String userStats = '/rest/v1/user_stats';
  static const String reports = '/rest/v1/reports';
}
```

- [ ] Create/update file
- [ ] Replace with your values
- [ ] Save file

---

## 📋 Part 4: Test Everything (10 minutes)

### Test 1: Database Tables
- [ ] Supabase → **Table Editor**
- [ ] Click on **habits** table
- [ ] Should see empty table with columns
- [ ] Repeat for other 3 tables
- [ ] ✅ All tables exist

### Test 2: Run Flutter App
```bash
cd app
flutter pub get
flutter run
```

- [ ] App starts without errors
- [ ] No Supabase connection errors in console
- [ ] ✅ App running

### Test 3: Test Authentication (Manual)
- [ ] Open app
- [ ] Try to register with email
- [ ] Check email for verification link
- [ ] Click verification link
- [ ] Try to login
- [ ] Check Supabase → Authentication → Users
- [ ] Should see your user
- [ ] ✅ Authentication working

### Test 4: Backend Health Check
- [ ] Open browser
- [ ] Visit: `https://your-app.onrender.com/health`
- [ ] Should return success response
- [ ] ✅ Backend deployed

---

## 📋 Part 5: Build APK (5 minutes)

### Option A: Using Build Script
```bash
# In project root folder
build-apk.bat
```

### Option B: Manual Build
```bash
cd app
flutter clean
flutter pub get
flutter build apk --release
```

- [ ] Build completes without errors
- [ ] APK created at: `app/build/app/outputs/flutter-apk/app-release.apk`
- [ ] APK size < 50MB
- [ ] ✅ APK ready

### Test APK
- [ ] Transfer APK to Android phone
- [ ] Enable "Install from unknown sources"
- [ ] Install APK
- [ ] Open app
- [ ] Test basic features
- [ ] ✅ APK works on device

---

## 🎯 Success Criteria

You're done when ALL of these are ✅:

- [ ] Supabase database has 4 tables
- [ ] RLS policies are enabled
- [ ] Email authentication works
- [ ] Google Sign-In configured (optional)
- [ ] Render backend is deployed and live
- [ ] Flutter app connects to Supabase
- [ ] APK builds successfully
- [ ] APK installs and runs on Android device

---

## 📞 Need Help?

### Common Issues:

**"RLS policy violation"**
- Check if user is logged in
- Verify RLS policies were created
- Run SQL schema again

**"Connection refused"**
- Check Supabase URL is correct
- Verify anon key is valid
- Check internet connection

**"Build failed" on Render**
- Check environment variables are set
- Verify Go version compatibility
- Check build command is correct

**APK won't install**
- Enable "Unknown sources" in Android settings
- Check minimum Android version (SDK 21+)
- Try uninstalling old version first

---

## 🚀 What's Next?

After completing this checklist:

1. **Implement Authentication UI** - I'll help you create login/register screens
2. **Connect Habit CRUD** - Link habit operations to Supabase
3. **Add Offline Support** - Implement local caching
4. **Polish UI** - Add animations and improve UX
5. **Release!** - Distribute your APK

---

**Start with Part 1, Step 1 and work your way down! ✅**
