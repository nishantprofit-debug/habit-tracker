# 🚀 GitHub & Render Deployment Guide

## ⚠️ GitHub Push Failed - Authentication Issue

The push failed with error:
```
remote: Permission to nishantprofit-debug/habit-tracker.git denied
fatal: unable to access 'https://github.com/nishantprofit-debug/habit-tracker.git/': 403
```

### Fix: Authenticate with GitHub

**Option 1: Use GitHub CLI (Recommended)**
```bash
# Install GitHub CLI from: https://cli.github.com/
gh auth login
# Follow prompts to authenticate

# Then push:
git push -u origin main
```

**Option 2: Use Personal Access Token**
1. Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Select scopes: `repo` (full control)
4. Copy the token
5. Push using token:
```bash
git push https://YOUR_TOKEN@github.com/nishantprofit-debug/habit-tracker.git main
```

**Option 3: Use SSH (Best for long-term)**
```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your-email@gmail.com"

# Add to GitHub: Settings → SSH and GPG keys → New SSH key
# Copy public key:
cat ~/.ssh/id_ed25519.pub

# Change remote to SSH:
git remote set-url origin git@github.com:nishantprofit-debug/habit-tracker.git
git push -u origin main
```

---

## 📦 What's Already Done:

✅ Git repository initialized
✅ All files committed (131 files, 21,683 lines)
✅ Branch renamed to `main`
✅ Remote added: `https://github.com/nishantprofit-debug/habit-tracker.git`

**Just need to authenticate and push!**

---

## 🚀 Render Deployment Configuration

### Based on Your Screenshots:

I can see you're setting up Render with these details:
- **Name:** habit-tracker
- **Language:** Elixir (should be **Go**)
- **Branch:** master (should be **main**)
- **Root Directory:** (should be **backend**)

### Correct Render Configuration:

```
Name: habittracker-api
Language: Go
Branch: main
Region: Virginia (US East) or Oregon
Root Directory: backend
Build Command: go build -o main ./cmd/server
Start Command: ./main
Instance Type: Free
```

### Environment Variables to Add:

```env
APP_ENV=production
PORT=8080
SUPABASE_URL=https://cwjcfsnpqiyzluybmwxc.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3amNmc25wcWl5emx1eWJtd3hjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk4NjEzMzAsImV4cCI6MjA4NTQzNzMzMH0.osaCK27a1ZlE6XUeEMTrKKpZH2o0uPtz2byslRCaz9s
SUPABASE_SERVICE_KEY=[Get from Supabase Settings → API → service_role key]
SUPABASE_JWT_SECRET=[Get from Supabase Settings → API → JWT Secret]
GEMINI_API_KEY=[Optional - for AI features]
```

---

## 📋 Step-by-Step: Complete Deployment

### Step 1: Push to GitHub

```bash
# Authenticate (choose one method above)
gh auth login

# Push code
git push -u origin main
```

### Step 2: Connect Render to GitHub

1. In Render dashboard, click **GitHub** button
2. Authorize Render to access your GitHub
3. Select repository: `nishantprofit-debug/habit-tracker`

### Step 3: Configure Render Service

Fill in the form:
```
Name: habittracker-api
Runtime: Go
Branch: main
Root Directory: backend
Build Command: go build -o main ./cmd/server
Start Command: ./main
```

### Step 4: Add Environment Variables

Click "Advanced" → Add environment variables (copy from above)

### Step 5: Deploy

1. Click "Create Web Service"
2. Wait 5-10 minutes for deployment
3. Check logs for errors
4. Test: `https://habittracker-api.onrender.com/health`

---

## 🎯 Quick Commands:

```bash
# Fix GitHub auth and push
gh auth login
git push -u origin main

# Or with token
git push https://YOUR_TOKEN@github.com/nishantprofit-debug/habit-tracker.git main

# Check status
git status
git log --oneline
```

---

## ✅ After Successful Push:

1. ✅ Code will be on GitHub
2. ✅ Connect Render to GitHub repo
3. ✅ Configure Render with correct settings
4. ✅ Add environment variables
5. ✅ Deploy backend
6. ✅ Test API endpoint

---

## 🔍 Verify Deployment:

**GitHub:**
- Visit: https://github.com/nishantprofit-debug/habit-tracker
- Should see all your files

**Render:**
- Check deployment logs
- Visit: `https://your-app.onrender.com/health`
- Should return: `{"status": "ok"}`

---

**First, fix GitHub authentication and push the code!** 🚀
