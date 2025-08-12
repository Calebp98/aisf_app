-- Temporarily disable RLS to test RSVP functionality
-- Run this in Supabase SQL Editor

-- Disable RLS on session_rsvps temporarily for testing
ALTER TABLE session_rsvps DISABLE ROW LEVEL SECURITY;

-- Also make sure sessions can be read
ALTER TABLE sessions DISABLE ROW LEVEL SECURITY;

-- This will allow all operations for testing
-- Once it works, we can re-enable RLS with proper policies