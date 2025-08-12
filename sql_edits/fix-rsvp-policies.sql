-- Fix RLS policies for session_rsvps with correct UUID casting
-- Run this in Supabase SQL Editor

-- Enable RLS on session_rsvps if not already enabled
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Users can view all RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Users can insert their own RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Users can update their own RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Users can delete their own RSVPs" ON session_rsvps;

-- Create new policies with correct UUID casting
CREATE POLICY "Users can view all RSVPs" ON session_rsvps FOR SELECT USING (true);

CREATE POLICY "Users can insert their own RSVPs" ON session_rsvps FOR INSERT 
WITH CHECK (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

CREATE POLICY "Users can update their own RSVPs" ON session_rsvps FOR UPDATE 
USING (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

CREATE POLICY "Users can delete their own RSVPs" ON session_rsvps FOR DELETE 
USING (auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id));

-- Also enable RLS on sessions table for viewing
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Sessions are viewable by everyone" ON sessions;
CREATE POLICY "Sessions are viewable by everyone" ON sessions FOR SELECT USING (true);