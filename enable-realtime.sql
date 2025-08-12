-- Enable real-time for messages table
-- Run this in Supabase SQL Editor

-- Enable real-time replication for messages table
ALTER PUBLICATION supabase_realtime ADD TABLE messages;

-- Also make sure messages table has proper permissions for real-time
GRANT SELECT ON messages TO anon;
GRANT SELECT ON messages TO authenticated;

-- Grant permissions on channels table too
GRANT SELECT ON channels TO anon;
GRANT SELECT ON channels TO authenticated;