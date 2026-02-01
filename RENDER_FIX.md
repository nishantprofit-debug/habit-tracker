# Render Deployment Fix

## Issue Summary
The deployment is failing with IPv6 connectivity errors:
- First error: `network is unreachable` (IPv6 not supported)
- Second error: `no suitable address found` (no IPv4 addresses available)

**Root Cause:** Supabase's database provides only IPv6 addresses, while Render's free tier doesn't support IPv6 connections. This is a fundamental incompatibility between the two services.

## Changes Made (Attempted Fixes)

### 1. Custom TCP4 Dialer (Commit: ce2abc7)
Added a custom dialer to force TCP4 connections.

### 2. Custom DNS Resolver (Commit: 0be253e)
Implemented custom DNS resolution that filters for IPv4 addresses only:

```go
// Force IPv4 connections to work around Render's lack of IPv6 support
config.ConnConfig.DialFunc = func(ctx context.Context, network, addr string) (net.Conn, error) {
    // Force TCP4 instead of TCP to avoid IPv6
    d := &net.Dialer{
        Timeout:   30 * time.Second,
        KeepAlive: 30 * time.Second,
    }
    return d.DialContext(ctx, "tcp4", addr)
}
```

### 2. Deployment Configuration ([render.yaml](render.yaml))
Updated the Render configuration to:
- Use Docker deployment for better control
- Match service name with repository name (`habit-tracker`)
- Specify Docker build context correctly

## Deployment Status

Latest fix pushed: commit `0be253e` - Enhanced DNS resolver

**However:** If Supabase doesn't provide IPv4 addresses, these fixes won't resolve the issue. The problem is a fundamental incompatibility between:
- Render (no IPv6 support on free tier)
- Supabase (possibly IPv6-only database endpoints)

## What to Check

1. **Render Dashboard**: Monitor the deployment logs at https://dashboard.render.com
2. **Expected Success**: You should see the database connection succeed without IPv6 errors
3. **Health Check**: Once deployed, verify the health endpoint: https://habit-tracker-s7er.onrender.com/health

## Environment Variables to Verify

Make sure these are set in your Render service settings:
- `DATABASE_URL` - Your Supabase connection string
- `GEMINI_API_KEY` - Your Gemini API key
- `JWT_SECRET` - Secure JWT secret (min 32 chars)
- `FIREBASE_CREDENTIALS_JSON` - Base64 encoded Firebase credentials
- Any custom `NISHANT_*` prefixed variables

## Git Flow Summary

```bash
main branch (latest): ce2abc7 - fix: force IPv4 database connections and use Docker deployment on Render
Previous commit: a919fd3 - fix: make migrations robust to existing schemas and fix local connection
```

All changes are on the main branch and have been pushed to GitHub.

## Next Steps

### Option 1: Try Supabase Connection Pooler (Quick Try)
Supabase's connection pooler might have IPv4 support:
1. Go to Supabase Dashboard → Settings → Database
2. Look for "Connection Pooling" section
3. Copy the pooler connection string (Transaction or Session mode)
4. Update `DATABASE_URL` in Render with this new connection string
5. Redeploy

### Option 2: Migrate to Different Platform (Recommended)
If the pooler doesn't work, **migrate to Railway.app or Fly.io** which support IPv6.

See [DEPLOYMENT_OPTIONS.md](DEPLOYMENT_OPTIONS.md) for detailed alternatives and migration guides.

## Troubleshooting

If the deployment still fails:
- Verify the `DATABASE_URL` is correct in Render's environment variables
- Check that all required environment variables are set
- Review the Render deployment logs for any new errors
- Ensure the Dockerfile builds successfully locally: `docker build -t habittracker ./backend`
