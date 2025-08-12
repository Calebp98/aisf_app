-- Minimal fix for auth issues
-- Run this in Supabase SQL Editor

-- 1. First, disable RLS temporarily to allow user creation
ALTER TABLE IF EXISTS users DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS sessions DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS session_rsvps DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS channels DISABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS messages DISABLE ROW LEVEL SECURITY;

-- 2. Drop any problematic triggers
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

-- 3. Create tables with minimal constraints
DROP TABLE IF EXISTS session_rsvps CASCADE;
DROP TABLE IF EXISTS messages CASCADE;  
DROP TABLE IF EXISTS channels CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table (no foreign key to auth.users to avoid issues)
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  auth_user_id UUID,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  title TEXT,
  company TEXT,
  bio TEXT,
  linkedin_url TEXT,
  interests TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Sessions table
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  speaker TEXT,
  location TEXT NOT NULL,
  room TEXT NOT NULL,
  track TEXT NOT NULL,
  type TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration TEXT,
  description TEXT,
  max_attendees INTEGER DEFAULT 50,
  is_official BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RSVPs table
CREATE TABLE session_rsvps (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'going',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Channels table
CREATE TABLE channels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages table
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER REFERENCES channels(id) ON DELETE CASCADE,
  sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample data
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description) VALUES 
('Registration & Welcome Coffee', NULL, 'Main Lobby', 'main-lobby', 'networking', 'networking', 
 '2024-03-15 08:00:00+00', '2024-03-15 09:00:00+00', '60 min', NULL),
('Opening Keynote: The Future of Digital Innovation', 'Dr. Sarah Chen', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 09:00:00+00', '2024-03-15 10:00:00+00', '60 min', 
 'Join Dr. Chen as she explores emerging technologies and their impact on business transformation.'),
('AI Workshop', 'Marcus Rodriguez', 'Workshop Room A', 'workshop-a', 'ai-tech', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Hands-on AI development workshop.'),
('Mobile Development', 'Jessica Kim', 'Conference Room B', 'conference-b', 'mobile-dev', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Building scalable mobile applications.');

INSERT INTO channels (name, display_name) VALUES 
('general', 'General'),
('tech-talks', 'Tech Talks');

-- Simple, permissive policies (for development only)
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Allow everything for now
CREATE POLICY "allow_all" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON sessions FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON session_rsvps FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON channels FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "allow_all" ON messages FOR ALL USING (true) WITH CHECK (true);