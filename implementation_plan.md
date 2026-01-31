# Implementation Plan: Habit Tracker App Release

## Goal
Release a production-ready Habit Tracker app with complete authentication (Google Sign-In, OTP, Password), deployed backend, and distributable APK.

## User Review Required

> [!IMPORTANT]
> **Deployment Decision Required**
> - **Option A (Recommended)**: Supabase (Database + Auth) + Render (Go Backend for AI features)
>   - Pros: Keep existing Go code, full control over AI logic
>   - Cons: Need to maintain two services
> 
> - **Option B (Simpler)**: Supabase Only (Database + Auth + Edge Functions)
>   - Pros: Single platform, fully serverless, easier maintenance
>   - Cons: Need to rewrite Go AI logic in TypeScript
>
> **Recommendation**: Start with Option A, can migrate to Option B later if needed.

> [!WARNING]
> **Google Play Store**
> - Requires $25 one-time developer fee
> - Alternative: Distribute APK directly via GitHub releases or website
> - Which distribution method do you prefer?

---

## Proposed Changes

### Component 1: Supabase Setup & Database Schema

See [RELEASE_PLAN.md](file:///C:/Users/admin/Desktop/habittracker/RELEASE_PLAN.md) for complete Supabase setup instructions and SQL schema.

---

### Component 2: Flutter App - Authentication Implementation

#### [MODIFY] [auth_provider.dart](file:///c:/Users/admin/Desktop/habittracker/app/lib/presentation/providers/auth_provider.dart)
Implement Supabase authentication with Google Sign-In, Email/Password, and OTP.

#### [MODIFY] [login_screen.dart](file:///c:/Users/admin/Desktop/habittracker/app/lib/presentation/screens/auth/login_screen.dart)
Add complete login UI with all authentication methods.

#### [MODIFY] [register_screen.dart](file:///c:/Users/admin/Desktop/habittracker/app/lib/presentation/screens/auth/register_screen.dart)
Add registration UI with email verification.

---

### Component 3: Backend Integration

#### [MODIFY] [habit_provider.dart](file:///c:/Users/admin/Desktop/habittracker/app/lib/presentation/providers/habit_provider.dart)
Replace mock data with Supabase API calls.

#### [NEW] [supabase_repository.dart](file:///c:/Users/admin/Desktop/habittracker/app/lib/data/remote/supabase_repository.dart)
Create repository for all Supabase operations.

---

### Component 4: APK Build

#### [NEW] [build-apk.bat](file:///C:/Users/admin/Desktop/habittracker/build-apk.bat)
Windows batch script to build release APK.

---

## Verification Plan

### Manual Testing
1. Test all authentication methods (Google, Email/Password, OTP)
2. Test habit CRUD operations
3. Test offline functionality
4. Install and test APK on Android device

### Performance
- App startup < 3 seconds
- API response < 500ms
- APK size < 50MB

See [RELEASE_PLAN.md](file:///C:/Users/admin/Desktop/habittracker/RELEASE_PLAN.md) for complete verification steps.
