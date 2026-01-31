-- ============================================
-- Habit Tracker - FINAL Production Migration
-- All Issues Fixed - Ready to Deploy
-- ============================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================
-- TABLE 1: HABITS
-- ============================================
CREATE TABLE IF NOT EXISTS public.habits (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
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
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE 2: DAILY LOGS (with completed_date)
-- ============================================
CREATE TABLE IF NOT EXISTS public.daily_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  habit_id UUID NOT NULL REFERENCES public.habits(id) ON DELETE CASCADE,
  completed_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_date DATE, -- Will be auto-populated by trigger
  notes TEXT,
  xp_earned INTEGER DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE 3: USER STATS (Gamification)
-- ============================================
CREATE TABLE IF NOT EXISTS public.user_stats (
  user_id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  total_xp INTEGER DEFAULT 0,
  level INTEGER DEFAULT 1,
  badges JSONB DEFAULT '[]'::jsonb,
  total_habits_completed INTEGER DEFAULT 0,
  longest_overall_streak INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE 4: AI REPORTS
-- ============================================
CREATE TABLE IF NOT EXISTS public.reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  report_type TEXT NOT NULL CHECK (report_type IN ('weekly', 'monthly', 'custom')),
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  content TEXT NOT NULL,
  insights JSONB,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TRIGGER: Auto-populate completed_date
-- ============================================
CREATE OR REPLACE FUNCTION public.set_completed_date()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  NEW.completed_date := (NEW.completed_at AT TIME ZONE 'UTC')::date;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_set_completed_date ON public.daily_logs;
CREATE TRIGGER trg_set_completed_date
  BEFORE INSERT OR UPDATE ON public.daily_logs
  FOR EACH ROW
  EXECUTE FUNCTION public.set_completed_date();

-- Backfill existing rows (if any)
UPDATE public.daily_logs 
SET completed_date = (completed_at AT TIME ZONE 'UTC')::date 
WHERE completed_date IS NULL;

-- ============================================
-- INDEXES (Performance Optimization)
-- ============================================

-- Habits indexes
CREATE INDEX IF NOT EXISTS idx_habits_user_id ON public.habits(user_id);
CREATE INDEX IF NOT EXISTS idx_habits_user_active ON public.habits(user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_habits_category ON public.habits(category) WHERE is_active = true;

-- Daily logs indexes
CREATE INDEX IF NOT EXISTS idx_daily_logs_user_id ON public.daily_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_logs_habit_id ON public.daily_logs(habit_id);
CREATE INDEX IF NOT EXISTS idx_daily_logs_completed_at ON public.daily_logs(completed_at);
CREATE INDEX IF NOT EXISTS idx_daily_logs_user_date ON public.daily_logs(user_id, completed_date);

-- FIXED: Unique constraint using stored date column (no immutability issues)
CREATE UNIQUE INDEX IF NOT EXISTS idx_daily_logs_habit_date 
  ON public.daily_logs(habit_id, completed_date);

-- Reports indexes
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON public.reports(user_id);
CREATE INDEX IF NOT EXISTS idx_reports_dates ON public.reports(start_date, end_date);

-- ============================================
-- ROW LEVEL SECURITY (RLS)
-- ============================================

-- Enable RLS on all tables
ALTER TABLE public.habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.daily_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;

-- Drop existing policies (idempotent)
DROP POLICY IF EXISTS "Users can view own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can insert own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can update own habits" ON public.habits;
DROP POLICY IF EXISTS "Users can delete own habits" ON public.habits;

DROP POLICY IF EXISTS "Users can view own logs" ON public.daily_logs;
DROP POLICY IF EXISTS "Users can insert own logs" ON public.daily_logs;
DROP POLICY IF EXISTS "Users can update own logs" ON public.daily_logs;
DROP POLICY IF EXISTS "Users can delete own logs" ON public.daily_logs;

DROP POLICY IF EXISTS "Users can view own stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can insert own stats" ON public.user_stats;
DROP POLICY IF EXISTS "Users can update own stats" ON public.user_stats;

DROP POLICY IF EXISTS "Users can view own reports" ON public.reports;
DROP POLICY IF EXISTS "Users can insert own reports" ON public.reports;

-- FIXED: Habits policies with proper UUID casting
CREATE POLICY "Users can view own habits" ON public.habits
  FOR SELECT USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can insert own habits" ON public.habits
  FOR INSERT WITH CHECK ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can update own habits" ON public.habits
  FOR UPDATE USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can delete own habits" ON public.habits
  FOR DELETE USING ((SELECT auth.uid())::uuid = user_id);

-- FIXED: Daily logs policies with proper UUID casting
CREATE POLICY "Users can view own logs" ON public.daily_logs
  FOR SELECT USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can insert own logs" ON public.daily_logs
  FOR INSERT WITH CHECK ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can update own logs" ON public.daily_logs
  FOR UPDATE USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can delete own logs" ON public.daily_logs
  FOR DELETE USING ((SELECT auth.uid())::uuid = user_id);

-- FIXED: User stats policies with proper UUID casting
CREATE POLICY "Users can view own stats" ON public.user_stats
  FOR SELECT USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can insert own stats" ON public.user_stats
  FOR INSERT WITH CHECK ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can update own stats" ON public.user_stats
  FOR UPDATE USING ((SELECT auth.uid())::uuid = user_id);

-- FIXED: Reports policies with proper UUID casting
CREATE POLICY "Users can view own reports" ON public.reports
  FOR SELECT USING ((SELECT auth.uid())::uuid = user_id);

CREATE POLICY "Users can insert own reports" ON public.reports
  FOR INSERT WITH CHECK ((SELECT auth.uid())::uuid = user_id);

-- ============================================
-- FUNCTIONS & TRIGGERS
-- ============================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER 
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$;

-- Trigger for habits table
DROP TRIGGER IF EXISTS update_habits_updated_at ON public.habits;
CREATE TRIGGER update_habits_updated_at
  BEFORE UPDATE ON public.habits
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Trigger for user_stats table
DROP TRIGGER IF EXISTS update_user_stats_updated_at ON public.user_stats;
CREATE TRIGGER update_user_stats_updated_at
  BEFORE UPDATE ON public.user_stats
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

-- Function to create user stats on signup
CREATE OR REPLACE FUNCTION public.create_user_stats()
RETURNS TRIGGER
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  INSERT INTO public.user_stats (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;
  RETURN NEW;
END;
$$;

-- Trigger to create user stats when user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION public.create_user_stats();

-- FIXED: Function to update XP and level with proper type casting and integer arithmetic
CREATE OR REPLACE FUNCTION public.update_user_xp(
  p_user_id UUID,
  p_xp_earned INTEGER
)
RETURNS void
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_new_xp INTEGER;
  v_new_level INTEGER;
BEGIN
  -- FIXED: Verify caller owns this user_id with proper UUID casting
  IF (SELECT auth.uid())::uuid != p_user_id THEN
    RAISE EXCEPTION 'Unauthorized: Cannot update XP for other users';
  END IF;

  -- Update total XP
  UPDATE public.user_stats
  SET total_xp = total_xp + p_xp_earned,
      total_habits_completed = total_habits_completed + 1
  WHERE user_id = p_user_id
  RETURNING total_xp INTO v_new_xp;
  
  -- FIXED: Calculate new level using integer arithmetic (100 XP per level)
  v_new_level := (v_new_xp / 100) + 1;
  
  -- Update level if changed
  UPDATE public.user_stats
  SET level = v_new_level
  WHERE user_id = p_user_id;
END;
$$;

-- ============================================
-- SECURITY: Revoke unnecessary permissions
-- ============================================

REVOKE EXECUTE ON FUNCTION public.create_user_stats() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.update_updated_at_column() FROM anon, authenticated;
REVOKE EXECUTE ON FUNCTION public.set_completed_date() FROM anon, authenticated;

-- Grant execute on update_user_xp to authenticated users only
GRANT EXECUTE ON FUNCTION public.update_user_xp(UUID, INTEGER) TO authenticated;

-- ============================================
-- COMMENTS & DOCUMENTATION
-- ============================================

COMMENT ON TABLE public.habits IS 'User habits with tracking metadata';
COMMENT ON TABLE public.daily_logs IS 'Daily habit completion logs with auto-populated date';
COMMENT ON TABLE public.user_stats IS 'User gamification stats (XP, level, badges)';
COMMENT ON TABLE public.reports IS 'AI-generated habit reports';

COMMENT ON COLUMN public.daily_logs.completed_date IS 'Auto-populated date (UTC) for indexing - DO NOT SET MANUALLY';

COMMENT ON FUNCTION public.create_user_stats() IS 'Auto-creates user_stats row when new user signs up';
COMMENT ON FUNCTION public.update_user_xp(UUID, INTEGER) IS 'Updates user XP and level with security checks';
COMMENT ON FUNCTION public.update_updated_at_column() IS 'Auto-updates updated_at timestamp on row changes';
COMMENT ON FUNCTION public.set_completed_date() IS 'Auto-populates completed_date from completed_at (UTC)';

-- ============================================
-- SUCCESS! Schema is ready!
-- ============================================
-- Run verification queries:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
-- SELECT tablename, rowsecurity FROM pg_tables WHERE schemaname = 'public';
-- SELECT tablename, policyname FROM pg_policies WHERE schemaname = 'public';
