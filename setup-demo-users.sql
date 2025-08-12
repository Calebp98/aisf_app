-- Create demo auth users via SQL
-- Note: This approach requires admin privileges and may not work in all Supabase setups
-- Alternative: Use the Supabase dashboard or create accounts via signup

-- First, let's update the auth schema to allow creating users
-- This needs to be run with admin privileges

-- Insert demo users into auth.users (this requires admin access)
-- If this doesn't work, you'll need to create these accounts through the signup flow

-- Method 1: Direct insertion (admin required)
INSERT INTO auth.users (
  instance_id,
  id,
  aud,
  role,
  email,
  encrypted_password,
  email_confirmed_at,
  created_at,
  updated_at,
  confirmation_token,
  recovery_token
) VALUES 
-- Dr. Sarah Chen
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated', 
  'sarah@innovatefirst.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  NOW(), 
  NOW(),
  '',
  ''
),
-- Marcus Rodriguez  
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(),
  'authenticated',
  'authenticated',
  'marcus@techventures.com', 
  crypt('password', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(),
  '',
  ''
),
-- Jessica Kim
(
  '00000000-0000-0000-0000-000000000000',
  gen_random_uuid(), 
  'authenticated',
  'authenticated',
  'jessica@appcorp.com',
  crypt('password', gen_salt('bf')),
  NOW(),
  NOW(),
  NOW(), 
  '',
  ''
);

-- Update our users table to link with auth users
UPDATE users SET auth_user_id = (
  SELECT id FROM auth.users WHERE email = 'sarah@innovatefirst.com' LIMIT 1
) WHERE email = 'sarah@innovatefirst.com';

UPDATE users SET auth_user_id = (
  SELECT id FROM auth.users WHERE email = 'marcus@techventures.com' LIMIT 1  
) WHERE email = 'marcus@techventures.com';

UPDATE users SET auth_user_id = (
  SELECT id FROM auth.users WHERE email = 'jessica@appcorp.com' LIMIT 1
) WHERE email = 'jessica@appcorp.com';