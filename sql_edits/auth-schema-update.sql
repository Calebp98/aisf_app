-- Update schema to integrate with Supabase Auth
-- Add auth_user_id column to link with auth.users

ALTER TABLE users ADD COLUMN auth_user_id UUID REFERENCES auth.users(id);

-- Create unique index on auth_user_id
CREATE UNIQUE INDEX IF NOT EXISTS users_auth_user_id_key ON users(auth_user_id);

-- Create a function to automatically create a user profile when someone signs up
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (auth_user_id, email, name)
  VALUES (NEW.id, NEW.email, COALESCE(NEW.raw_user_meta_data->>'name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create trigger to call the function every time a user signs up
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Update RLS policies to be user-aware
DROP POLICY IF EXISTS "Users are publicly readable" ON users;
DROP POLICY IF EXISTS "Anyone can insert users" ON users;
DROP POLICY IF EXISTS "Anyone can insert RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Anyone can update RSVPs" ON session_rsvps;
DROP POLICY IF EXISTS "Anyone can insert messages" ON messages;

-- Users can read all profiles but only update their own
CREATE POLICY "Users can read all profiles" ON users FOR SELECT USING (true);
CREATE POLICY "Users can update their own profile" ON users FOR UPDATE USING (auth.uid() = auth_user_id);

-- RSVPs are user-specific
CREATE POLICY "Users can read all RSVPs" ON session_rsvps FOR SELECT USING (true);
CREATE POLICY "Users can manage their own RSVPs" ON session_rsvps 
  FOR ALL USING (
    auth.uid() = (SELECT auth_user_id FROM users WHERE id = user_id)
  );

-- Messages require authentication
CREATE POLICY "Authenticated users can read messages" ON messages FOR SELECT USING (auth.role() = 'authenticated');
CREATE POLICY "Authenticated users can insert messages" ON messages 
  FOR INSERT WITH CHECK (
    auth.role() = 'authenticated' AND 
    sender_id = (SELECT id FROM users WHERE auth_user_id = auth.uid())
  );

-- Update sample users to include auth integration info
UPDATE users SET 
  email = 'sarah@innovatefirst.com',
  name = 'Dr. Sarah Chen'
WHERE id = 1;

UPDATE users SET 
  email = 'marcus@techventures.com', 
  name = 'Marcus Rodriguez'
WHERE id = 2;

UPDATE users SET
  email = 'jessica@appcorp.com',
  name = 'Jessica Kim' 
WHERE id = 3;

UPDATE users SET
  email = 'robert@cloudtech.com',
  name = 'Robert Chen'
WHERE id = 4;

UPDATE users SET
  email = 'lisa@designlab.com',
  name = 'Lisa Park'
WHERE id = 5;