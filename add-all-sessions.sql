-- First clear existing sessions and add all sessions from original HTML
DELETE FROM sessions;

-- Insert all sessions from the original schedule.html
INSERT INTO sessions (title, speaker, location, room, track, type, start_time, end_time, duration, description) VALUES 

-- 8:00 AM - 9:00 AM
('Registration & Welcome Coffee', NULL, 'Main Lobby', 'main-lobby', 'networking', 'networking', 
 '2024-03-15 08:00:00+00', '2024-03-15 09:00:00+00', '60 min', NULL),

-- 9:00 AM - 10:00 AM
('Opening Keynote: The Future of Digital Innovation', 'Dr. Sarah Chen, CTO at InnovateFirst', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 09:00:00+00', '2024-03-15 10:00:00+00', '60 min', 
 'Join Dr. Chen as she explores emerging technologies and their impact on business transformation in the next decade.'),

-- 10:15 AM - 11:15 AM
('AI-Powered Product Development', 'Marcus Rodriguez, Head of AI', 'Workshop Room A', 'workshop-a', 'ai-tech', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Hands-on workshop covering machine learning integration in modern product development workflows.'),

('Building Scalable Mobile Apps', 'Jessica Kim, Senior Mobile Engineer', 'Conference Room B', 'conference-b', 'mobile-dev', 'workshop', 
 '2024-03-15 10:15:00+00', '2024-03-15 11:15:00+00', '60 min', 
 'Best practices for creating mobile applications that can handle millions of users.'),

-- 11:30 AM - 12:30 PM
('Panel: The Evolution of Remote Work', 'Various Industry Leaders', 'Main Auditorium', 'main-auditorium', 'keynote', 'panel', 
 '2024-03-15 11:30:00+00', '2024-03-15 12:30:00+00', '60 min', 
 'A discussion on how remote work has changed business operations and team dynamics.'),

-- 12:30 PM - 1:30 PM
('Networking Lunch', NULL, 'Garden Terrace', 'garden-terrace', 'networking', 'networking', 
 '2024-03-15 12:30:00+00', '2024-03-15 13:30:00+00', '60 min', NULL),

-- 1:30 PM - 2:30 PM
('Sustainable Technology: Building for Tomorrow', 'Dr. Ahmed Hassan, Environmental Tech Researcher', 'Main Auditorium', 'main-auditorium', 'keynote', 'keynote', 
 '2024-03-15 13:30:00+00', '2024-03-15 14:30:00+00', '60 min', 
 'Exploring how technology companies can reduce their environmental impact while scaling innovation.'),

-- 2:45 PM - 3:45 PM
('Advanced Cloud Architecture Patterns', 'Robert Chen, Cloud Solutions Architect', 'Workshop Room A', 'workshop-a', 'cloud-arch', 'workshop', 
 '2024-03-15 14:45:00+00', '2024-03-15 15:45:00+00', '60 min', 
 'Deep dive into modern cloud design patterns for high-availability systems.'),

('UX Design in the Age of AI', 'Lisa Park, Principal UX Designer', 'Conference Room B', 'conference-b', 'ux-design', 'talk', 
 '2024-03-15 14:45:00+00', '2024-03-15 15:45:00+00', '60 min', 
 'How artificial intelligence is reshaping user experience design principles and practices.'),

-- 4:00 PM - 5:00 PM
('Startup Pitch Session', '5 Selected Startups', 'Main Auditorium', 'main-auditorium', 'keynote', 'presentation', 
 '2024-03-15 16:00:00+00', '2024-03-15 17:00:00+00', '60 min', 
 'Watch promising startups present their innovative solutions to a panel of investors.'),

-- 5:15 PM - 6:30 PM
('Closing Reception & Awards', NULL, 'Rooftop Terrace', 'rooftop-terrace', 'networking', 'networking', 
 '2024-03-15 17:15:00+00', '2024-03-15 18:30:00+00', '75 min', NULL);

-- Clear and add all messages from original
DELETE FROM messages;
INSERT INTO messages (channel_id, sender, content, created_at) VALUES 
(1, 'sarah_chen', 'Welcome everyone! Looking forward to a great day of talks and networking 🎉', '2024-03-15 08:15:00+00'),
(1, 'marcus_dev', 'Excited for the AI workshop this morning! Anyone else attending?', '2024-03-15 08:22:00+00'),
(1, 'jessica_mobile', '@marcus_dev yes! I''ll be there. Looking forward to the hands-on part', '2024-03-15 08:24:00+00'),
(1, 'alex_startup', 'Coffee in the lobby is excellent btw 👌', '2024-03-15 08:28:00+00'),
(1, 'lisa_design', 'Where''s the best place to sit for the keynote? First time here', '2024-03-15 08:35:00+00'),
(1, 'robert_cloud', '@lisa_design middle section has the best acoustics and screen visibility', '2024-03-15 08:37:00+00'),
(1, 'ahmed_research', 'Quick reminder: lunch networking starts at 12:30 on the garden terrace!', '2024-03-15 08:45:00+00'),
(1, 'you', 'Thanks for the tips everyone! This is my first tech conference', '2024-03-15 08:52:00+00');