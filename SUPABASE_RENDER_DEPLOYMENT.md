# Deploy Habit Tracker to Render with Supabase

This guide will help you deploy your backend to Render using Supabase as your PostgreSQL database.

## Prerequisites

- GitHub account (your code is already on GitHub)
- Supabase account (free tier available)
- Render account (free tier available)

## Part 1: Set Up Supabase Database

### 1. Create Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in:
   - **Name**: `habit-tracker`
   - **Database Password**: Generate a strong password (save this!)
   - **Region**: Choose closest to your users
4. Click "Create new project"
5. Wait 2-3 minutes for setup to complete

### 2. Get Database Connection String

1. In your Supabase project, click "Settings" (gear icon)
2. Click "Database" in the left sidebar
3. Scroll to "Connection string" section
4. Select "URI" tab
5. Copy the connection string (it looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxxxxxxxxxx.supabase.co:5432/postgres
   ```
6. Replace `[YOUR-PASSWORD]` with your actual database password

### 3. Run Database Migrations

You can run migrations in two ways:

**Option A: Using Supabase SQL Editor (Recommended)**
1. In Supabase, click "SQL Editor"
2. Open the migration files from `backend/migrations/` in your local folder
3. Copy and paste each migration SQL into the editor
4. Run them in order (001, 002, etc.)

**Option B: Using psql locally**
```bash
cd backend
psql "postgresql://postgres:[YOUR-PASSWORD]@db.xxxxxxxxxxxxx.supabase.co:5432/postgres" -f migrations/001_initial_schema.sql
# Repeat for other migration files
```

## Part 2: Deploy Backend to Render

### 1. Create Render Web Service

1. Go to [render.com](https://render.com) and sign in
2. Click "New +" → "Web Service"
3. Connect your GitHub account if not already connected
4. Select your repository: `habit-tracker`
5. Configure the service:

   **Basic Settings:**
   - **Name**: `habit-tracker-backend`
   - **Region**: Same as Supabase or closest to users
   - **Branch**: `main`
   - **Root Directory**: `backend`
   - **Runtime**: `Docker`
   - **Instance Type**: Free (or paid if needed)

### 2. Set Environment Variables

In the "Environment" section, add these variables:

```env
PORT=8080
ENV=production

# Database - Use your Supabase connection string
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxxxxxxxxxxxx.supabase.co:5432/postgres

# Redis (Optional - use Redis Cloud free tier if needed)
REDIS_URL=redis://default:[PASSWORD]@[HOST]:[PORT]

# Firebase - For authentication
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CREDENTIALS_JSON=your-base64-encoded-service-account-json

# Gemini AI - For habit insights
GEMINI_API_KEY=your-gemini-api-key

# JWT Configuration - Generate secure random strings
JWT_SECRET=generate-a-long-random-string-minimum-32-characters-here
JWT_EXPIRY=24h
REFRESH_EXPIRY=168h
```

**Important Notes:**
- Replace `[YOUR-PASSWORD]` with your actual Supabase password
- Generate a secure random string for `JWT_SECRET` (at least 32 characters)
- Get `GEMINI_API_KEY` from [Google AI Studio](https://makersuite.google.com/app/apikey)
- For Firebase credentials, see next section

### 3. Firebase Setup (For Authentication)

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or use existing one
3. Go to Project Settings → Service Accounts
4. Click "Generate New Private Key"
5. Download the JSON file
6. Convert to base64:
   ```bash
   # On Linux/Mac
   base64 -w 0 < service-account.json

   # On Windows PowerShell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("service-account.json"))
   ```
7. Copy the base64 output and use as `FIREBASE_CREDENTIALS_JSON`

### 4. Deploy

1. Click "Create Web Service"
2. Render will automatically:
   - Pull your code from GitHub
   - Build the Docker image
   - Deploy the backend
3. Wait 5-10 minutes for first deployment
4. Your backend will be live at: `https://habit-tracker-backend.onrender.com`

### 5. Update Render Service ID in GitHub Secrets

For automatic deployments from CI/CD:

1. After service is created, copy the Service ID from Render URL or settings
2. Go to your GitHub repository → Settings → Secrets and variables → Actions
3. Add or update:
   - `RENDER_SERVICE_ID`: Your service ID
   - `RENDER_API_KEY`: Get from Render Account Settings → API Keys

## Part 3: Update Flutter App

Update your Flutter app to use the Render backend:

1. Edit `app/lib/core/config/api_config.dart` (or wherever API URL is configured)
2. Change base URL to: `https://habit-tracker-backend.onrender.com`
3. Commit and push:
   ```bash
   git add app/
   git commit -m "Update API URL to Render deployment"
   git push origin main
   ```

## Part 4: Test Everything

1. Check Render logs: Go to your service → Logs tab
2. Test health endpoint: `https://habit-tracker-backend.onrender.com/health`
3. Should return: `{"status": "ok"}`
4. Test with Flutter app

## Download APK

After CI passes:
1. Go to GitHub → Actions tab
2. Click latest successful workflow run
3. Scroll to "Artifacts" section
4. Download "android-release" artifact
5. Extract ZIP to get `app-release.apk`

## Troubleshooting

### Database Connection Issues
- Verify Supabase connection string is correct
- Check that password is properly URL-encoded
- Ensure Supabase project is active (not paused)

### Render Deployment Fails
- Check Render logs for errors
- Verify all environment variables are set
- Ensure Docker builds locally: `cd backend && docker build .`

### App Can't Connect to Backend
- Verify backend is running: check health endpoint
- Check API URL in Flutter app is correct
- Check CORS settings if needed

## Free Tier Limits

**Supabase Free Tier:**
- 500 MB database
- 2 GB bandwidth
- 50,000 monthly active users

**Render Free Tier:**
- Spins down after 15 minutes of inactivity
- 750 hours/month (enough for 1 app)
- Auto-starts on first request (may take 30-60 seconds)

## Optional: Redis Setup

If you need Redis for caching:

1. Go to [Redis Cloud](https://redis.com/try-free/)
2. Create free database
3. Copy connection URL
4. Add to Render environment variables as `REDIS_URL`

## Need Help?

- Supabase Docs: https://supabase.com/docs
- Render Docs: https://render.com/docs
- Check GitHub Issues: [Your Repo Issues](https://github.com/nishantprofit-debug/habit-tracker/issues)

---

**Note:** Backend will auto-deploy on every push to `main` branch via GitHub Actions (if `RENDER_API_KEY` and `RENDER_SERVICE_ID` are set).
