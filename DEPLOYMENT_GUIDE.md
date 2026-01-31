# 🚀 Complete Deployment Guide - Industry Standard

## Part 1: Supabase Setup (Database + Authentication)

### Step 1: Create Supabase Project ✅ (You've already done this!)

Based on your screenshot, you have:
- ✅ Created a Supabase project
- ✅ Opened the Table Editor
- ✅ Ready to create tables

---

### Step 2: Create Database Tables

#### 2.1 Create Tables Using SQL Editor

**Follow these steps:**

1. **Go to SQL Editor:**
   - In Supabase dashboard, click **SQL Editor** (left sidebar)
   - Click **+ New query**

2. **Copy and paste this complete schema:**

```sql
-- ============================================
-- HABIT TRACKER DATABASE SCHEMA
-- ============================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- TABLE 1: HABITS
-- ============================================
CREATE TABLE public.habits (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  category TEXT NOT NULL CHECK (category IN ('health', 'learning', 'productivity', 'personal', 'other')),
  frequency TEXT NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'custom')),
  is_active BOOLEAN DEFAULT true,
  is_learning_habit BOOLEAN DEFAULT false,
  color TEXT DEFAULT '#000000',
  icon TEXT DEFAULT 'check_circle',
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  reminder_time TIME,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLE 2: DAILY LOGS
-- ============================================
CREATE TABLE public.daily_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  habit_id UUID REFERENCES public.habits(id) ON DELETE CASCADE,
  completed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  notes TEXT,
  xp_earned INTEGER DEFAULT 10,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(habit_id, DATE(completed_at))
);

-- ============================================
-- TABLE 3: USER STATS (Gamification)
-- ============================================
CREATE TABLE public.user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  badges JSONB DEFAULT '[]'::jsonb,
  total_habits_completed INTEGER DEFAULT 0,
  longest_overall_streak INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- TABLE 4: AI REPORTS
-- ============================================
CREATE TABLE public.reports (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  report_type TEXT NOT NULL CHECK (report_type IN ('weekly', 'monthly', 'custom')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  content TEXT NOT NULL,
  insights JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- INDEXES (Performance Optimization)
-- ============================================
CREATE INDEX idx_habits_user_id ON public.habits(user_id);
CREATE INDEX idx_habits_is_active ON public.habits(is_active);
CREATE INDEX idx_daily_logs_user_id ON public.daily_logs(user_id);
CREATE INDEX idx_daily_logs_habit_id ON public.daily_logs(habit_id);
CREATE INDEX idx_daily_logs_completed_at ON public.daily_logs(completed_at);
CREATE INDEX idx_reports_user_id ON public.reports(user_id);

-- ============================================
-- ROW LEVEL SECURITY (RLS) - CRITICAL!
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Habits policies
CREATE POLICY "Users can view own habits" ON public.habits
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own habits" ON public.habits
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own habits" ON public.habits
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own habits" ON public.habits
  FOR DELETE USING (auth.uid() = user_id);

-- Daily logs policies
CREATE POLICY "Users can view own logs" ON public.daily_logs
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own logs" ON public.daily_logs
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own logs" ON public.daily_logs
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own logs" ON public.daily_logs
  FOR DELETE USING (auth.uid() = user_id);

-- User stats policies
CREATE POLICY "Users can view own stats" ON public.user_stats
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own stats" ON public.user_stats
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own stats" ON public.user_stats
  FOR UPDATE USING (auth.uid() = user_id);

-- Reports policies
CREATE POLICY "Users can view own reports" ON public.reports
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own reports" ON public.reports
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for habits table
CREATE TRIGGER update_habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Trigger for user_stats table
CREATE TRIGGER update_user_stats_updated_at
  BEFORE UPDATE ON public.user_stats
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Function to create user stats on signup
CREATE OR REPLACE FUNCTION create_user_stats()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.user_stats (user_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to create user stats when user signs up
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION create_user_stats();

-- Function to update XP and level
CREATE OR REPLACE FUNCTION update_user_xp(
  p_user_id UUID,
  p_xp_earned INTEGER
)
RETURNS void AS $$
DECLARE
  v_new_xp INTEGER;
  v_new_level INTEGER;
BEGIN
  UPDATE public.user_stats
  SET total_xp = total_xp + p_xp_earned,
      total_habits_completed = total_habits_completed + 1
  WHERE user_id = p_user_id
  RETURNING total_xp INTO v_new_xp;
  
  v_new_level := FLOOR(v_new_xp / 100) + 1;
  
  UPDATE public.user_stats
  SET level = v_new_level
  WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;
```

3. **Click "Run" button** (bottom right)
4. **Verify success:** You should see "Success. No rows returned"

---

### Step 3: Configure Authentication

Based on your screenshot, I can see you're in the OAuth Server settings. Here's what to do:

#### 3.1 Enable Email Authentication

1. **Go to Authentication → Providers**
2. **Enable Email provider:**
   - Toggle ON "Enable Email provider"
   - ✅ Enable email confirmations
   - ✅ Secure email change
   - Save

#### 3.2 Configure Google OAuth (For Google Sign-In)

**You need to do this in Google Cloud Console first:**

1. **Go to Google Cloud Console:**
   - Visit: https://console.cloud.google.com
   - Create new project or select existing

2. **Enable Google+ API:**
   - APIs & Services → Library
   - Search "Google+ API"
   - Click Enable

3. **Create OAuth 2.0 Credentials:**
   - APIs & Services → Credentials
   - Click "+ CREATE CREDENTIALS" → OAuth client ID
   - Application type: **Web application**
   - Name: `Habit Tracker`
   - Authorized redirect URIs:
     ```
     https://YOUR_SUPABASE_PROJECT_ID.supabase.co/auth/v1/callback
     ```
   - Click Create
   - **Copy Client ID and Client Secret**

4. **Back to Supabase:**
   - Authentication → Providers → Google
   - Toggle ON "Enable Google provider"
   - Paste **Client ID**
   - Paste **Client Secret**
   - ✅ Skip nonce check (for iOS)
   - Save

#### 3.3 Configure Site URL (Important!)

In your screenshot, I see "Site URL" field. Set this to:

```
http://localhost:3000
```

For production, change to your actual domain.

**Authorization Path:** `/oauth/consent` (already correct in your screenshot)

---

### Step 4: Get API Keys

1. **Go to Settings → API**
2. **Copy these values:**
   - **Project URL:** `https://YOUR_PROJECT_ID.supabase.co`
   - **anon/public key:** (long string starting with `eyJ...`)
   - **service_role key:** (keep this SECRET!)

**Save these in a secure place!**

---

## Part 2: Render Setup (Backend Deployment)

Based on your first screenshot showing Render dashboard:

### Step 1: Create Web Service

1. **Click "+ New" → Web Service**

2. **Connect Repository:**
   - Option A: Connect your GitHub repo
   - Option B: Deploy from Git URL

3. **Configure Service:**
   ```
   Name: habittracker-api
   Region: Oregon (or closest to you)
   Branch: main
   Root Directory: backend
   Runtime: Go
   Build Command: go build -o main ./cmd/server
   Start Command: ./main
   ```

4. **Select Plan:**
   - Choose **Free** plan
   - 750 hours/month free

### Step 2: Set Environment Variables

Click "Advanced" → Add Environment Variables:

```env
APP_ENV=production
PORT=8080
SUPABASE_URL=https://YOUR_PROJECT_ID.supabase.co
SUPABASE_ANON_KEY=your_anon_key_from_step_4
SUPABASE_SERVICE_KEY=your_service_role_key
SUPABASE_JWT_SECRET=your_jwt_secret
GEMINI_API_KEY=your_gemini_key (optional)
```

**How to get JWT Secret:**
- Supabase Dashboard → Settings → API → JWT Settings → JWT Secret

### Step 3: Deploy

1. Click **Create Web Service**
2. Wait for deployment (5-10 minutes)
3. Check logs for errors
4. Test health endpoint: `https://your-app.onrender.com/health`

---

## Part 3: Update Flutter App

### Step 1: Update Supabase Credentials

**File:** `app/lib/main.dart`

```dart
await Supabase.initialize(
  url: 'https://YOUR_PROJECT_ID.supabase.co',
  anonKey: 'YOUR_ANON_KEY_HERE',
);
```

### Step 2: Update API Endpoints

**File:** `app/lib/core/constants/api_endpoints.dart`

```dart
class ApiEndpoints {
  // Supabase
  static const String supabaseUrl = 'https://YOUR_PROJECT_ID.supabase.co';
  static const String supabaseAnonKey = 'YOUR_ANON_KEY';
  
  // Render Backend (for AI features)
  static const String backendUrl = 'https://habittracker-api.onrender.com';
  
  // API endpoints
  static const String habits = '/rest/v1/habits';
  static const String dailyLogs = '/rest/v1/daily_logs';
  static const String userStats = '/rest/v1/user_stats';
}
```

---

## Part 4: Test Everything

### Test 1: Database Connection

Run this in Supabase SQL Editor:

```sql
SELECT * FROM public.habits LIMIT 5;
```

Should return empty result (no errors).

### Test 2: Authentication

1. Run Flutter app: `flutter run`
2. Try to sign up with email
3. Check Supabase → Authentication → Users
4. Should see new user

### Test 3: Backend Health

Visit in browser:
```
https://habittracker-api.onrender.com/health
```

Should return: `{"status": "ok"}`

---

## Part 5: Build APK

Once everything is tested:

```bash
# Run the build script
build-apk.bat
```

Or manually:
```bash
cd app
flutter build apk --release
```

APK location: `app/build/app/outputs/flutter-apk/app-release.apk`

---

## 🔒 Security Checklist

- [ ] RLS policies enabled on all tables
- [ ] API keys stored in environment variables (not in code)
- [ ] HTTPS enabled (automatic with Supabase/Render)
- [ ] Email verification enabled
- [ ] JWT secret kept secure
- [ ] Service role key NEVER exposed to frontend

---

## 📊 Monitoring

### Supabase
- Dashboard → Database → Monitor queries
- Check storage usage (500MB free tier)
- Monitor active users (50K free tier)

### Render
- Check deployment logs
- Monitor instance hours (750/month free)
- Set up health checks

---

## 🆘 Troubleshooting

### "Row Level Security" Error
- Make sure RLS policies are created
- Check user is authenticated
- Verify `auth.uid()` matches `user_id`

### "Connection refused" Error
- Check Supabase URL is correct
- Verify API keys are valid
- Check internet connection

### Render "Build failed"
- Check Go version compatibility
- Verify build command is correct
- Check environment variables are set

---

## ✅ Final Checklist

- [ ] Supabase project created
- [ ] Database schema created (4 tables)
- [ ] RLS policies enabled
- [ ] Authentication providers configured (Email + Google)
- [ ] API keys copied
- [ ] Render service created
- [ ] Environment variables set
- [ ] Backend deployed successfully
- [ ] Flutter app updated with credentials
- [ ] App tested locally
- [ ] APK built and tested

---

**Next:** Once you complete these steps, let me know and I'll help you implement the authentication screens in Flutter!
