-- Function to create a public.profiles entry for new auth.users
-- This function runs with SECURITY DEFINER, meaning it executes with the privileges
-- of the user who defined it (typically the database owner), bypassing RLS for this specific insert.
-- (You confirmed this function exists, so you might not need to re-run this part if it's already there)
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name, email, total_score, quizzes_completed, accuracy)
  VALUES (NEW.id, NEW.email, NEW.email, 0, 0, 0.00); -- Use NEW.email as default name and email
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to call the function after a new user is inserted into auth.users
-- THIS IS THE CRUCIAL PART THAT WAS MISSING
CREATE OR REPLACE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
