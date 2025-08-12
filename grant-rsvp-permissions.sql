-- Grant permissions to anon and authenticated roles for session_rsvps
-- Run this in Supabase SQL Editor

-- Grant all permissions to anon role (for API access)
GRANT ALL ON session_rsvps TO anon;
GRANT ALL ON session_rsvps TO authenticated;

-- Grant usage on the sequence (needed for inserts)
GRANT USAGE ON session_rsvps_id_seq TO anon;
GRANT USAGE ON session_rsvps_id_seq TO authenticated;

-- Also grant permissions on sessions table
GRANT SELECT ON sessions TO anon;
GRANT SELECT ON sessions TO authenticated;

-- Grant permissions on users table for the joins
GRANT SELECT ON users TO anon;
GRANT SELECT ON users TO authenticated;