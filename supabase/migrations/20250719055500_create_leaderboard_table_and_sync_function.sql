-- Create the leaderboard_entries table
CREATE TABLE public.leaderboard_entries (
    user_id uuid NOT NULL,
    total_score integer DEFAULT 0 NOT NULL,
    quizzes_completed integer DEFAULT 0 NOT NULL,
    accuracy double precision DEFAULT 0.0 NOT NULL,
    last_updated timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT leaderboard_entries_pkey PRIMARY KEY (user_id),
    CONSTRAINT leaderboard_entries_user_id_fkey FOREIGN KEY (user_id) REFERENCES profiles(id) ON DELETE CASCADE
);

ALTER TABLE public.leaderboard_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow read access for all users" ON public.leaderboard_entries FOR SELECT USING (true);
CREATE POLICY "Allow insert for authenticated users" ON public.leaderboard_entries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Allow update for authenticated users" ON public.leaderboard_entries FOR UPDATE USING (auth.uid() = user_id);

-- Create the function to sync leaderboard from profiles
CREATE OR REPLACE FUNCTION public.sync_leaderboard_from_profiles()
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  INSERT INTO public.leaderboard_entries (user_id, total_score, quizzes_completed, accuracy, last_updated)
  SELECT
    p.id,
    p.total_score,
    p.quizzes_completed,
    p.accuracy,
    now()
  FROM
    public.profiles p
  ON CONFLICT (user_id) DO UPDATE SET
    total_score = EXCLUDED.total_score,
    quizzes_completed = EXCLUDED.quizzes_completed,
    accuracy = EXCLUDED.accuracy,
    last_updated = EXCLUDED.last_updated;
END;
$function$;
