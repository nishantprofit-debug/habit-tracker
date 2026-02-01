# Deployment Options & Solutions

## Current Issue
Supabase's PostgreSQL database only provides IPv6 addresses, but Render's free tier doesn't support IPv6 connectivity. This creates an incompatibility that causes "no suitable address found" errors.

## Solution 1: Try Supabase Connection Pooler (Recommended First Try)

Supabase provides a connection pooler (Supavisor) that may have better IPv4 support.

### Steps:
1. Go to your Supabase project settings
2. Navigate to Database → Connection Pooling
3. Look for the **Transaction** or **Session** pooler connection string
4. It should look like: `postgres://postgres.[project-ref]:[password]@aws-0-[region].pooler.supabase.com:6543/postgres`
5. Update the `DATABASE_URL` in Render with this pooler connection string

### Why this might work:
- Pooler endpoints often have dual-stack (IPv4 + IPv6) support
- AWS-hosted poolers typically provide IPv4 addresses

---

## Solution 2: Use Alternative Hosting Platforms

If Render continues to fail, here are better alternatives that support IPv6:

### Option A: Railway.app (Recommended)
**Pros:**
- Full IPv6 support
- Easy GitHub integration
- Free tier: $5 credit/month
- Better performance than Render free tier
- Automatic deployments

**Steps:**
1. Sign up at https://railway.app
2. Create new project from GitHub repo
3. Select your `habit-tracker` repository
4. Set environment variables
5. Deploy automatically

**Cost:** ~$5-10/month after free credits

### Option B: Fly.io
**Pros:**
- Excellent IPv6 support
- Global edge deployment
- Free tier: 3 shared-cpu VMs
- Great for Docker deployments

**Steps:**
1. Install Fly CLI: `powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"`
2. Run `fly auth login`
3. Run `fly launch` in your backend directory
4. Set secrets: `fly secrets set DATABASE_URL="..." GEMINI_API_KEY="..."`
5. Deploy: `fly deploy`

**Cost:** Free for small apps, ~$5-15/month if scaling

### Option C: Vercel + Serverless Functions
**Note:** Requires refactoring to serverless architecture

### Option D: DigitalOcean App Platform
**Pros:**
- Full IPv6 support
- $5/month starter tier
- Very reliable

---

## Solution 3: Use Different Database Provider

If you want to stick with Render, consider switching database providers:

### Option A: Railway PostgreSQL
- Create PostgreSQL database on Railway
- Get connection string (IPv4 compatible)
- Migrate your data from Supabase

### Option B: Neon Database
- Serverless PostgreSQL
- Free tier available
- Excellent IPv4/IPv6 support
- Connection string: https://neon.tech

### Option C: Render PostgreSQL
- Use Render's own PostgreSQL
- Free tier available (expires after 90 days)
- Add to render.yaml:
```yaml
- type: pserv
  name: habit-tracker-db
  plan: free
  ipAllowList: []
```

---

## Solution 4: VPN/Proxy Workaround (Advanced)

Set up a proxy service that:
1. Accepts IPv4 connections from Render
2. Forwards to Supabase via IPv6

**Not recommended** - adds complexity and latency.

---

## My Recommendations

### Immediate Action:
1. **Try Supabase Connection Pooler** (easiest, might solve it immediately)
2. If that fails, **migrate to Railway** (best long-term solution)

### Long-term Best Solution:
**Railway.app** because:
- Modern infrastructure with IPv6 support
- Better than Render's free tier
- Easy migration (just point to your GitHub repo)
- Active development and great support
- Only ~$5-10/month for your use case

### Budget-Conscious:
**Fly.io** - More complex setup but robust free tier

---

## Migration Checklist (for Railway)

1. [ ] Sign up for Railway account
2. [ ] Connect GitHub repository
3. [ ] Create new project from repo
4. [ ] Configure environment variables:
   - DATABASE_URL
   - GEMINI_API_KEY
   - JWT_SECRET
   - FIREBASE_CREDENTIALS_JSON
   - FIREBASE_PROJECT_ID
5. [ ] Set build command: `cd backend && go build -o main ./cmd/server`
6. [ ] Set start command: `cd backend && ./main`
7. [ ] Deploy and test
8. [ ] Update Flutter app's API URL to Railway URL

---

## Current Status

I've pushed an enhanced fix (commit `0be253e`) that implements custom DNS resolution to filter for IPv4 addresses only. However, if Supabase doesn't provide any IPv4 addresses, this still won't work.

**Next Steps:**
1. Wait for Render deployment to complete and check logs
2. If it still fails with "no IPv4 addresses found", proceed with Solution 1 (Pooler)
3. If pooler doesn't work, I recommend migrating to Railway

Would you like me to help you set up any of these alternatives?
