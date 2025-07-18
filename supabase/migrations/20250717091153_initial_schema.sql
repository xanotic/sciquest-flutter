-- This is a placeholder filename. The actual filename will have a timestamp.
-- Example: supabase/migrations/20231027123456_initial_schema.sql

-- Enable the "uuid-ossp" extension for generating UUIDs
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 1. Create the 'profiles' table
-- This table stores additional user data linked to Supabase's auth.users table.
-- The 'id' column is a UUID and references the 'id' from auth.users.
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE, -- ADD THIS LINE
    avatar VARCHAR(255) DEFAULT NULL,
    total_score INT DEFAULT 0,
    quizzes_completed INT DEFAULT 0,
    accuracy DECIMAL(5,2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Set up Row Level Security (RLS) for the profiles table
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own profile
CREATE POLICY "Users can view their own profile." ON public.profiles
FOR SELECT USING (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update their own profile." ON public.profiles
FOR UPDATE USING (auth.uid() = id);

-- Allow new users to create a profile entry upon registration
CREATE POLICY "Users can create their own profile." ON public.profiles
FOR INSERT WITH CHECK (auth.uid() = id);

-- 2. Create the 'questions' table
CREATE TABLE public.questions (
    id SERIAL PRIMARY KEY,
    question TEXT NOT NULL,
    options JSONB NOT NULL, -- Use JSONB for better performance with JSON data
    correct_answer INT NOT NULL,
    category VARCHAR(255) NOT NULL,
    subcategory VARCHAR(255),
    difficulty VARCHAR(50) NOT NULL,
    explanation TEXT
);

-- 3. Create the 'quiz_results' table
CREATE TABLE public.quiz_results (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE, -- Link to auth.users
    score INT NOT NULL,
    total_questions INT NOT NULL,
    accuracy DECIMAL(5,2) NOT NULL,
    category VARCHAR(255) NOT NULL,
    game_mode VARCHAR(255) NOT NULL,
    time_spent INT NOT NULL,
    completed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    question_ids JSONB NOT NULL, -- Store array of question IDs as JSONB
    user_answers JSONB NOT NULL -- Store array of user answers as JSONB
);

-- Set up Row Level Security (RLS) for the quiz_results table
ALTER TABLE public.quiz_results ENABLE ROW LEVEL SECURITY;

-- Allow users to view their own quiz results
CREATE POLICY "Users can view their own quiz results." ON public.quiz_results
FOR SELECT USING (auth.uid() = user_id);

-- Allow users to insert their own quiz results
CREATE POLICY "Users can insert their own quiz results." ON public.quiz_results
FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Optional: Insert some dummy question data (run this after the tables are created)
INSERT INTO public.questions (question, options, correct_answer, category, subcategory, difficulty, explanation) VALUES
(
    'What is the chemical symbol for gold?',
    '["Go", "Gd", "Au", "Ag"]',
    2,
    'Chemistry',
    'Periodic Table',
    'easy',
    'Au comes from the Latin word "aurum" meaning gold.'
),
(
    'Which planet is known as the Red Planet?',
    '["Venus", "Mars", "Jupiter", "Saturn"]',
    1,
    'Physics',
    'Astronomy',
    'easy',
    'Mars appears red due to iron oxide (rust) on its surface.'
),
(
    'What is the derivative of x² + 3x + 2?',
    '["2x + 3", "x + 3", "2x + 2", "x² + 3"]',
    0,
    'Mathematics',
    'Calculus',
    'medium',
    'The derivative of x² is 2x, derivative of 3x is 3, and derivative of constant 2 is 0.'
),
(
    'What is the largest bone in the human body?',
    '["Humerus", "Tibia", "Femur", "Fibula"]',
    2,
    'Biology',
    'Anatomy',
'easy',
    'The femur (thigh bone) is the longest and strongest bone in the human body.'
),
(
    'What is the time complexity of binary search?',
    '["O(n)", "O(log n)", "O(n²)", "O(1)"]',
    1,
    'Computer Science',
    'Algorithms',
    'medium',
    'Binary search has O(log n) time complexity as it eliminates half the search space in each iteration.'
);
