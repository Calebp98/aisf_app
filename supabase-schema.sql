-- Create sessions table
CREATE TABLE sessions (
  id SERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  speaker TEXT,
  location TEXT NOT NULL,
  room TEXT NOT NULL,
  track TEXT NOT NULL,
  type TEXT NOT NULL,
  start_time TIMESTAMP WITH TIME ZONE NOT NULL,
  end_time TIMESTAMP WITH TIME ZONE NOT NULL,
  duration TEXT,
  description TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create channels table for chat
CREATE TABLE channels (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create messages table for chat
CREATE TABLE messages (
  id SERIAL PRIMARY KEY,
  channel_id INTEGER REFERENCES channels(id) ON DELETE CASCADE,
  sender TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert sample sessions
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description) VALUES 
('Registration & Welcome Coffee', NULL, 'Main Lobby', 'main-lobby', 'networking', 'networking', 
 '2024-03-15 08:00:00+00', '2024-03-15 09:00:00+00', '60 min', NULL),

('Opening Keynote: The Future of Digital Innovation', 'Dr. Sarah Chen, CTO at InnovateFirst', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 09:00:00+00', '2024-03-15 10:00:00+00', '60 min', 
 'Join Dr. Chen as she explores emerging technologies and their impact on business transformation in the next decade.'),

('AI-Powered Product Development', 'Marcus Rodriguez, Head of AI', 'Workshop Room A', 'workshop-a', 'ai-tech', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Hands-on workshop covering machine learning integration in modern product development workflows.'),

('Building Scalable Mobile Apps', 'Jessica Kim, Senior Mobile Engineer', 'Conference Room B', 'conference-b', 'mobile-dev', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Best practices for creating mobile applications that can handle millions of users.'),

('Networking Lunch', NULL, 'Garden Terrace', 'garden-terrace', 'networking', 'networking', 
 '2024-03-15 12:30:00+00', '2024-03-15 13:30:00+00', '60 min', NULL);

-- Insert chat channels
INSERT INTO channels (name, display_name) VALUES 
('general', 'General'),
('keynote-qa', 'Keynote Q&A'),
('networking', 'Networking'),
('tech-talks', 'Tech Talks');

-- Insert sample messages
INSERT INTO messages (channel_id, sender, content) VALUES 
(1, 'sarah_chen', 'Welcome everyone! Looking forward to a great day of talks and networking 🎉'),
(1, 'marcus_dev', 'Excited for the AI workshop this morning! Anyone else attending?'),
(1, 'jessica_mobile', '@marcus_dev yes! I''ll be there. Looking forward to the hands-on part'),
(1, 'alex_startup', 'Coffee in the lobby is excellent btw 👌');

-- Enable Row Level Security
ALTER TABLE sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Create policies for read access (public read)
CREATE POLICY "Sessions are publicly readable" ON sessions FOR SELECT USING (true);
CREATE POLICY "Channels are publicly readable" ON channels FOR SELECT USING (true);
CREATE POLICY "Messages are publicly readable" ON messages FOR SELECT USING (true);

-- Create policy for inserting messages (anyone can post)
CREATE POLICY "Anyone can insert messages" ON messages FOR INSERT WITH CHECK (true);