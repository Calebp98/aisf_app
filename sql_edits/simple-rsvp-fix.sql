-- Create just the session_rsvps table
-- Run this in Supabase SQL Editor

-- Create session_rsvps table
CREATE TABLE IF NOT EXISTS session_rsvps (
    id SERIAL PRIMARY KEY,
    session_id INTEGER,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'going',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc', now()),
    UNIQUE(session_id, user_id)
);

-- Enable RLS
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;

-- Create policies for session_rsvps (users can manage their own RSVPs)
DROP POLICY IF EXISTS "Users can view all RSVPs" ON session_rsvps;
CREATE POLICY "Users can view all RSVPs" ON session_rsvps FOR SELECT USING (true);

DROP POLICY IF EXISTS "Users can insert their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can insert their own RSVPs" ON session_rsvps FOR INSERT WITH CHECK (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));

DROP POLICY IF EXISTS "Users can update their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can update their own RSVPs" ON session_rsvps FOR UPDATE USING (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));

DROP POLICY IF EXISTS "Users can delete their own RSVPs" ON session_rsvps;
CREATE POLICY "Users can delete their own RSVPs" ON session_rsvps FOR DELETE USING (auth.uid()::text = (SELECT auth_user_id FROM users WHERE id = user_id));