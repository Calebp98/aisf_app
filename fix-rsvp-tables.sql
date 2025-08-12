-- Create missing RSVP tables and sample sessions
-- Run this in Supabase SQL Editor

-- Create session_rsvps table if it doesn't exist
CREATE TABLE IF NOT EXISTS session_rsvps (
    id SERIAL PRIMARY KEY,
    session_id INTEGER,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'going',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    UNIQUE(session_id, user_id)
);

-- Add some sample session IDs (these match the hardcoded sessions in your HTML)
-- We'll just create simple session records with IDs that match your app
DO $$
BEGIN
    -- Create a simple sessions table if it doesn't exist
    CREATE TABLE IF NOT EXISTS sessions (
        id INTEGER PRIMARY KEY,
        title TEXT,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now())
    );
    
    -- Insert basic session records
    INSERT INTO sessions (id, title) VALUES 
    (1, 'AI Workshop'),
    (2, 'Mobile Development'),
    (3, 'Cloud Architecture'),
    (4, 'UX Research'),
    (5, 'Startup Tech Stack'),
    (6, 'Security Best Practices'),
    (7, 'Data Science'),
    (8, 'DevOps Pipeline')
    ON CONFLICT (id) DO NOTHING;
END $$;

-- Enable RLS on both tables
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;

-- Create policies for sessions (public read)
DROP POLICY IF EXISTS "Sessions are viewable by everyone" ON sessions;
CREATE POLICY "Sessions are viewable by everyone" ON sessions FOR SELECT USING (true);

-- Create policies for session_rsvps (users can manage their own RSVPs)
DROP POLICY IF EXISTS "Users can view all RSVPs" ON session_rsvps;
CREATE POLICY "Users can view all RSVPs" ON session_rsvps FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can insert their own RSVPs" ON session_rsvps FOR INSERT WITH CHECK (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));

DROP POLICY IF EXISTS "Users can update their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can update their own RSVPs" ON session_rsvps FOR UPDATE USING (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));

DROP POLICY IF EXISTS "Users can delete their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can delete their own RSVPs" ON session_rsvps FOR DELETE USING (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));