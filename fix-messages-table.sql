-- Fix messages table to allow NULL sender_id
-- Run this in Supabase SQL Editor

-- Make sender_id nullable to handle cases where profile creation failed
ALTER TABLE messages ALTER COLUMN sender_id DROP NOT NULL;

-- Update the foreign key constraint to allow NULL
ALTER TABLE messages DROP CONSTRAINT IF EXISTS messages_sender_id_fkey;
ALTER TABLE messages ADD CONSTRAINT messages_sender_id_fkey 
  FOREIGN KEY (sender_id) REFERENCES users(id) ON DELETE SET NULL;

-- Make sure we have the basic channels
INSERT INTO channels (name, display_name) VALUES 
('general', 'General'),
('keynote-qa', 'Keynote Q&A'),
('networking', 'Networking'),
('tech-talks', 'Tech Talks')
ON CONFLICT (name) DO NOTHING;