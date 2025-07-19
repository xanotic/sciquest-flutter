CREATE OR REPLACE FUNCTION public.sync_leaderboard_from_profiles()
RETURNS void AS $$
BEGIN
  INSERT INTO public.leaderboard_entries (user_id, total_score, quizzes_completed, accuracy)
  SELECT
      p.id,
      p.total_score,
      p.quizzes_completed,
      p.accuracy
  FROM public.profiles p
  ON CONFLICT (user_id) DO UPDATE SET
      total_score = EXCLUDED.total_score,
      quizzes_completed = EXCLUDED.quizzes_completed,
      accuracy = EXCLUDED.accuracy,
      last_updated = NOW();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
