-- Simple authentication setup without complex triggers
-- Run this in your Supabase SQL Editor

-- First, ensure we have basic tables
CREATE TABLE IF NOT EXISTS users (
  id SERIAL PRIMARY KEY,
  auth_user_id UUID REFERENCES auth.users(id),
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  title TEXT,
  company TEXT,
  bio TEXT,
  linkedin_url TEXT,
  interests TEXT[], 
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create unique index on auth_user_id
CREATE UNIQUE INDEX IF NOT EXISTS users_auth_user_id_key ON users(auth_user_id);

-- Basic sessions table (simplified)
CREATE TABLE IF NOT EXISTS sessions (
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
  max_attendees INTEGER,
  is_official BOOLEAN DEFAULT true,
  is_private BOOLEAN DEFAULT false,
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RSVP system
CREATE TABLE IF NOT EXISTS session_rsvps (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'going',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Chat channels
CREATE TABLE IF NOT EXISTS channels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
  is_private BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Messages
CREATE TABLE IF NOT EXISTS messages (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER REFERENCES channels(id) ON DELETE CASCADE,
  sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert basic sessions (only if not exists)
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description, max_attendees, is_official) 
SELECT * FROM (VALUES 
  ('Registration & Welcome Coffee', NULL, 'Main Lobby', 'main-lobby', 'networking', 'networking', 
   '2024-03-15 08:00:00+00', '2024-03-15 09:00:00+00', '60 min', NULL, 200, true),
  ('Opening Keynote: The Future of Digital Innovation', 'Dr. Sarah Chen, CTO at InnovateFirst', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
   '2024-03-15 09:00:00+00', '2024-03-15 10:00:00+00', '60 min', 
   'Join Dr. Chen as she explores emerging technologies and their impact on business transformation in the next decade.', 500, true),
  ('AI-Powered Product Development', 'Marcus Rodriguez, Head of AI', 'Workshop Room A', 'workshop-a', 'ai-tech', 'workshop', 
   '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
   'Hands-on workshop covering machine learning integration in modern product development workflows.', 30, true)
) AS v(title, speaker, location, room, track, type, start_time, end_time, duration, description, max_attendees, is_official)
WHERE NOT EXISTS (SELECT 1 FROM sessions WHERE title = v.title);

-- Insert basic channels
INSERT INTO channels (name, display_name) 
SELECT * FROM (VALUES 
  ('general', 'General'),
  ('keynote-qa', 'Keynote Q&A'),
  ('networking', 'Networking'),
  ('tech-talks', 'Tech Talks')
) AS v(name, display_name)
WHERE NOT EXISTS (SELECT 1 FROM channels WHERE name = v.name);

-- Enable Row Level Security with simple policies
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can read all profiles" ON users;
DROP POLICY IF EXISTS "Sessions are publicly readable" ON sessions;
DROP POLICY IF EXISTS "Users can manage their own RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Channels are publicly readable" ON channels;
DROP POLICY IF EXISTS "Authenticated users can read messages" ON messages;
DROP POLICY IF EXISTS "Authenticated users can insert messages" ON messages;

-- Create simple, permissive policies for development
CREATE POLICY "Enable read access for all users" ON users FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users only" ON users FOR INSERT WITH CHECK (auth.role() = 'authenticated');
CREATE POLICY "Enable update for users based on auth_user_id" ON users FOR UPDATE USING (auth.uid() = auth_user_id);

CREATE POLICY "Enable read access for all users" ON sessions FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON session_rsvps FOR SELECT USING (true);
CREATE POLICY "Enable all for authenticated users" ON session_rsvps FOR ALL USING (auth.role() = 'authenticated');

CREATE POLICY "Enable read access for all users" ON channels FOR SELECT USING (true);
CREATE POLICY "Enable read access for all users" ON messages FOR SELECT USING (true);
CREATE POLICY "Enable insert for authenticated users" ON messages FOR INSERT WITH CHECK (auth.role() = 'authenticated');