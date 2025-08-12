-- Comprehensive schema for conference app
-- Drop existing tables and recreate with full feature set

-- Drop tables in correct order (reverse of dependencies)
DROP TABLE IF EXISTS session_invitations CASCADE;
DROP TABLE IF EXISTS session_rsvps CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS channels CASCADE;
DROP TABLE IF EXISTS sessions CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users/Profiles table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  email TEXT UNIQUE NOT NULL,
  title TEXT,
  company TEXT,
  bio TEXT,
  linkedin_url TEXT,
  interests TEXT[], -- Array of interests like ['AI', 'Mobile', 'Cloud', 'UX', 'Startup', 'Networking']
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced sessions table
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  speaker TEXT,
  location TEXT NOT NULL,
  room TEXT NOT NULL,
  track TEXT NOT NULL,
  type TEXT NOT NULL, -- 'keynote', 'workshop', 'talk', 'panel', 'presentation', 'networking'
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration TEXT,
  description TEXT,
  max_attendees INTEGER,
  is_official BOOLEAN DEFAULT true, -- false for community-created sessions
  is_private BOOLEAN DEFAULT false, -- true for private sessions requiring invitations
  created_by INTEGER REFERENCES users(id),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RSVP system
CREATE TABLE session_rsvps (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'going', -- 'going', 'maybe', 'not_going'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(session_id, user_id)
);

-- Private session invitations
CREATE TABLE session_invitations (
  id SERIAL PRIMARY KEY,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE,
  invited_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  invited_by_user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'declined'
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  responded_at TIMESTAMP WITH TIME ZONE,
  UNIQUE(session_id, invited_user_id)
);

-- Enhanced channels table
CREATE TABLE channels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  session_id INTEGER REFERENCES sessions(id) ON DELETE CASCADE, -- null for general channels
  is_private BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enhanced messages table
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER REFERENCES channels(id) ON DELETE CASCADE,
  sender_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  sender_name TEXT NOT NULL, -- Denormalized for performance
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample users
INSERT INTO users (name, email, title, company, bio, linkedin_url, interests) VALUES 
('Dr. Sarah Chen', 'sarah@innovatefirst.com', 'CTO', 'InnovateFirst', 
 'Leading digital transformation initiatives with a focus on AI and cloud technologies. 15+ years experience building scalable systems.',
 'https://linkedin.com/in/sarahchen', 
 ARRAY['AI', 'Cloud']),

('Marcus Rodriguez', 'marcus@techventures.com', 'Head of AI', 'TechVentures',
 'AI researcher turned entrepreneur. Building the next generation of intelligent applications. Always interested in connecting with fellow AI enthusiasts.',
 'https://linkedin.com/in/marcusrodriguez',
 ARRAY['AI', 'Startup']),

('Jessica Kim', 'jessica@appcorp.com', 'Senior Mobile Engineer', 'AppCorp',
 'Mobile development expert specializing in cross-platform solutions. Passionate about creating beautiful, user-friendly mobile experiences.',
 'https://linkedin.com/in/jessicakim',
 ARRAY['Mobile', 'UX']),

('Robert Chen', 'robert@cloudtech.com', 'Cloud Solutions Architect', 'CloudTech',
 'Cloud infrastructure specialist helping companies scale from startup to enterprise. Expert in AWS, Azure, and Google Cloud platforms.',
 'https://linkedin.com/in/robertchen',
 ARRAY['Cloud', 'Networking']),

('Lisa Park', 'lisa@designlab.com', 'Principal UX Designer', 'DesignLab',
 'UX design leader with a passion for human-centered design. Helping startups and enterprises create intuitive digital experiences.',
 'https://linkedin.com/in/lisapark',
 ARRAY['UX', 'Startup', 'Networking']);

-- Insert existing sessions with enhanced data
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description, max_attendees, is_official) VALUES 

('Registration & Welcome Coffee', NULL, 'Main Lobby', 'main-lobby', 'networking', 'networking', 
 '2024-03-15 08:00:00+00', '2024-03-15 09:00:00+00', '60 min', NULL, 200, true),

('Opening Keynote: The Future of Digital Innovation', 'Dr. Sarah Chen, CTO at InnovateFirst', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 09:00:00+00', '2024-03-15 10:00:00+00', '60 min', 
 'Join Dr. Chen as she explores emerging technologies and their impact on business transformation in the next decade.', 500, true),

('AI-Powered Product Development', 'Marcus Rodriguez, Head of AI', 'Workshop Room A', 'workshop-a', 'ai-tech', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Hands-on workshop covering machine learning integration in modern product development workflows.', 30, true),

('Building Scalable Mobile Apps', 'Jessica Kim, Senior Mobile Engineer', 'Conference Room B', 'conference-b', 'mobile-dev', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Best practices for creating mobile applications that can handle millions of users.', 25, true),

('Panel: The Evolution of Remote Work', 'Various Industry Leaders', 'Main Auditorium', 'main-auditorium', 'keynote', 'panel', 
 '2024-03-15 11:30:00+00', '2024-03-15 12:30:00+00', '60 min', 
 'A discussion on how remote work has changed business operations and team dynamics.', 500, true),

('Networking Lunch', NULL, 'Garden Terrace', 'garden-terrace', 'networking', 'networking', 
 '2024-03-15 12:30:00+00', '2024-03-15 13:30:00+00', '60 min', NULL, 200, true),

('Sustainable Technology: Building for Tomorrow', 'Dr. Ahmed Hassan, Environmental Tech Researcher', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 13:30:00+00', '2024-03-15 14:30:00+00', '60 min', 
 'Exploring how technology companies can reduce their environmental impact while scaling innovation.', 500, true),

('Advanced Cloud Architecture Patterns', 'Robert Chen, Cloud Solutions Architect', 'Workshop Room A', 'workshop-a', 'cloud-arch', 'workshop', 
 '2024-03-15 14:45:00+00', '2024-03-15 15:45:00+00', '60 min', 
 'Deep dive into modern cloud design patterns for high-availability systems.', 30, true),

('UX Design in the Age of AI', 'Lisa Park, Principal UX Designer', 'Conference Room B', 'conference-b', 'ux-design', 'talk', 
 '2024-03-15 14:45:00+00', '2024-03-15 15:45:00+00', '60 min', 
 'How artificial intelligence is reshaping user experience design principles and practices.', 40, true),

('Startup Pitch Session', '5 Selected Startups', 'Main Auditorium', 'main-auditorium', 'keynote', 'presentation', 
 '2024-03-15 16:00:00+00', '2024-03-15 17:00:00+00', '60 min', 
 'Watch promising startups present their innovative solutions to a panel of investors.', 500, true),

('Closing Reception & Awards', NULL, 'Rooftop Terrace', 'rooftop-terrace', 'networking', 'networking', 
 '2024-03-15 17:15:00+00', '2024-03-15 18:30:00+00', '75 min', NULL, 300, true);

-- Add some sample community sessions
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description, max_attendees, is_official, created_by) VALUES 
('Mobile Coffee Chat', 'Jessica Kim', 'Coffee Corner', 'main-lobby', 'mobile-dev', 'networking',
 '2024-03-15 10:00:00+00', '2024-03-15 10:15:00+00', '15 min',
 'Quick coffee break discussion about mobile development trends and challenges.', 8, false, 3),

('AI Startup Founders Meetup', 'Marcus Rodriguez', 'Side Room', 'conference-b', 'ai-tech', 'networking',
 '2024-03-15 17:00:00+00', '2024-03-15 17:30:00+00', '30 min',
 'Connect with other AI startup founders and discuss challenges, funding, and collaboration opportunities.', 12, false, 2);

-- Insert chat channels (general + session-specific)
INSERT INTO channels (name, display_name) VALUES 
('general', 'General'),
('keynote-qa', 'Keynote Q&A'),
('networking', 'Networking'),
('tech-talks', 'Tech Talks');

-- Insert session-specific channels for community sessions
INSERT INTO channels (name, display_name, session_id) VALUES 
('mobile-coffee-chat', 'Mobile Coffee Chat', (SELECT id FROM sessions WHERE title = 'Mobile Coffee Chat')),
('ai-founders-meetup', 'AI Founders Meetup', (SELECT id FROM sessions WHERE title = 'AI Startup Founders Meetup'));

-- Insert sample messages
INSERT INTO messages (channel_id, sender_id, sender_name, content, created_at) VALUES 
(1, 1, 'sarah_chen', 'Welcome everyone! Looking forward to a great day of talks and networking 🎉', '2024-03-15 08:15:00+00'),
(1, 2, 'marcus_dev', 'Excited for the AI workshop this morning! Anyone else attending?', '2024-03-15 08:22:00+00'),
(1, 3, 'jessica_mobile', '@marcus_dev yes! I''ll be there. Looking forward to the hands-on part', '2024-03-15 08:24:00+00'),
(1, 5, 'alex_startup', 'Coffee in the lobby is excellent btw 👌', '2024-03-15 08:28:00+00'),
(1, 4, 'lisa_design', 'Where''s the best place to sit for the keynote? First time here', '2024-03-15 08:35:00+00'),
(1, 5, 'robert_cloud', '@lisa_design middle section has the best acoustics and screen visibility', '2024-03-15 08:37:00+00'),
(1, 1, 'ahmed_research', 'Quick reminder: lunch networking starts at 12:30 on the garden terrace!', '2024-03-15 08:45:00+00'),
(1, 2, 'you', 'Thanks for the tips everyone! This is my first tech conference', '2024-03-15 08:52:00+00');

-- Add some sample RSVPs
INSERT INTO session_rsvps (session_id, user_id, status) VALUES
-- Sarah going to her own keynote and AI workshop
(2, 1, 'going'), (3, 1, 'going'),
-- Marcus going to AI workshop and mobile session
(3, 2, 'going'), (4, 2, 'going'),
-- Jessica going to mobile workshop and UX talk
(4, 3, 'going'), (9, 3, 'going'),
-- Robert going to cloud workshop and networking
(8, 4, 'going'), (6, 4, 'going'),
-- Lisa going to UX talk and startup pitch
(9, 5, 'going'), (10, 5, 'going');

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_rsvps ENABLE ROW LEVEL SECURITY;
ALTER TABLE session_invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create policies for read access (public read for most tables)
CREATE POLICY "Users are publicly readable" ON users FOR SELECT USING (true);
CREATE POLICY "Sessions are publicly readable" ON sessions FOR SELECT USING (true);
CREATE POLICY "Session RSVPs are publicly readable" ON session_rsvps FOR SELECT USING (true);
CREATE POLICY "Session invitations are publicly readable" ON session_invitations FOR SELECT USING (true);
CREATE POLICY "Channels are publicly readable" ON channels FOR SELECT USING (true);
CREATE POLICY "Messages are publicly readable" ON messages FOR SELECT USING (true);

-- Create policies for inserting (anyone can create for demo purposes)
CREATE POLICY "Anyone can insert users" ON users FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can insert sessions" ON sessions FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can insert RSVPs" ON session_rsvps FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can insert invitations" ON session_invitations FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can insert channels" ON channels FOR INSERT WITH CHECK (true);
CREATE POLICY "Anyone can insert messages" ON messages FOR INSERT WITH CHECK (true);

-- Create policies for updating
CREATE POLICY "Anyone can update RSVPs" ON session_rsvps FOR UPDATE USING (true);
CREATE POLICY "Anyone can update invitations" ON session_invitations FOR UPDATE USING (true);
CREATE POLICY "Anyone can update sessions" ON sessions FOR UPDATE USING (true);