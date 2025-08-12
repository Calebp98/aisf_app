-- Test basic access to session_rsvps table
-- Run this in Supabase SQL Editor to check if we can query the table directly

-- Check if we can select from session_rsvps
SELECT * FROM session_rsvps LIMIT 5;

-- Check table permissions 
SELECT 
    schemaname,
    tablename,
    tableowner,
    hasselect,
    hasinsert,
    hasupdate,
    hasdelete
FROM pg_tables 
LEFT JOIN pg_roles ON pg_roles.rolname = tableowner
WHERE tablename = 'session_rsvps';

-- Check if anon role has access
SELECT 
    grantee,
    privilege_type
FROM information_schema.role_table_grants 
WHERE table_name = 'session_rsvps';