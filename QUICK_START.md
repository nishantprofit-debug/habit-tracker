# 🚀 Quick Start Guide - Habit Tracker Release

## तुरंत शुरू करें (Get Started Immediately)

### Step 1: Supabase Setup (5 minutes)

1. **Supabase account बनाएं:**
   - जाएं: https://supabase.com
   - Sign up with Google/GitHub
   - Create new project
   - Project name: `habittracker`
   - Database password: (strong password बनाएं)
   - Region: Choose closest to you

2. **Database Schema setup करें:**
   - Supabase dashboard में जाएं
   - SQL Editor खोलें
   - `supabase_schema.sql` file की content copy करें
   - SQL Editor में paste करें और Run करें

3. **Authentication enable करें:**
   - Settings → Authentication → Providers
   - Enable करें:
     - ✅ Email (with email confirmation)
     - ✅ Google (requires Google Cloud Console setup)
   - Email Templates customize करें (optional)

4. **API Keys copy करें:**
   - Settings → API
   - Copy करें:
     - `Project URL`
     - `anon/public key`
   - ये keys Flutter app में use होंगी

---

### Step 2: Flutter App Configuration (10 minutes)

1. **Supabase credentials add करें:**
   ```dart
   // app/lib/main.dart में update करें
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_PROJECT_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

2. **Dependencies install करें:**
   ```bash
   cd app
   flutter pub get
   ```

3. **Test run करें:**
   ```bash
   flutter run
   ```

---

### Step 3: APK Build करें (5 minutes)

**Option A: Batch Script (Windows)**
```bash
# Project root folder में
build-apk.bat
```

**Option B: Manual Command**
```bash
cd app
flutter clean
flutter pub get
flutter build apk --release
```

**APK location:**
```
app/build/app/outputs/flutter-apk/app-release.apk
```

---

### Step 4: Backend Deployment (Optional - 15 minutes)

**Render पर deploy करें:**

1. **Render account बनाएं:**
   - जाएं: https://render.com
   - Sign up with GitHub

2. **New Web Service create करें:**
   - Connect your GitHub repository
   - या manually deploy करें

3. **Environment variables set करें:**
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_SERVICE_KEY=your_service_key
   SUPABASE_JWT_SECRET=your_jwt_secret
   GEMINI_API_KEY=your_gemini_key (optional)
   ```

4. **Deploy करें:**
   - Render automatically build और deploy करेगा
   - Health check: `https://your-app.onrender.com/health`

---

## 📱 Features Checklist

### Must Implement (Priority 1)
- [ ] Supabase authentication (Google + Email/Password + OTP)
- [ ] Habit CRUD operations with Supabase
- [ ] Daily completion tracking
- [ ] Streak calculation
- [ ] Basic stats display
- [ ] Offline support (SQLite cache)

### Nice to Have (Priority 2)
- [ ] Push notifications
- [ ] AI reports (requires backend)
- [ ] Gamification (XP, levels, badges)
- [ ] Calendar heatmap
- [ ] Dark mode

---

## 🔑 Important Files

| File | Purpose |
|------|---------|
| `RELEASE_PLAN.md` | Complete release strategy |
| `implementation_plan.md` | Detailed implementation steps |
| `supabase_schema.sql` | Database schema for Supabase |
| `build-apk.bat` | APK build script |
| `render.yaml` | Backend deployment config |

---

## 🆘 Troubleshooting

### Flutter build fails
```bash
flutter clean
flutter pub get
flutter doctor
```

### Supabase connection error
- Check Project URL and anon key
- Verify RLS policies are enabled
- Check internet connection

### APK won't install
- Enable "Install from unknown sources" on Android
- Check Android version (minimum SDK 21)

---

## 📞 Next Steps

1. **Immediate:**
   - Set up Supabase project
   - Update Flutter app with credentials
   - Build and test APK

2. **This Week:**
   - Implement authentication screens
   - Connect habit CRUD to Supabase
   - Test offline functionality

3. **This Month:**
   - Deploy backend to Render
   - Add push notifications
   - Release v1.0!

---

## 💡 Pro Tips

- **Free Hosting:** Supabase (50K users) + Render (750 hrs/month) = Completely FREE
- **APK Distribution:** Use GitHub Releases for easy distribution
- **Testing:** Test on multiple Android devices before release
- **Backup:** Always backup Supabase database before schema changes

---

**Ready to start? Follow Step 1 above! 🚀**
