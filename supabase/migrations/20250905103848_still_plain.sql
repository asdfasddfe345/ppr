/*
  # PrimoJobs.in 2.0 - Complete Database Schema

  Creates all tables for the career hub platform including jobs, webinars, blogs, and services.

  ## New Tables
  1. **companies** - Company profiles and information
  2. **jobs** - Job listings with advanced filtering capabilities
  3. **webinars** - Webinar sessions with registration system
  4. **webinar_registrations** - User registrations for webinars
  5. **blog_categories** - Blog content categorization
  6. **blog_tags** - Tag system for content discovery
  7. **blogs** - Blog posts with SEO optimization
  8. **blog_post_tags** - Many-to-many relationship for blog tags
  9. **services** - Service offerings with pricing
  10. **service_inquiries** - User inquiries for services
  11. **subscribers** - Email/WhatsApp/Telegram subscribers
  12. **alerts** - Job alerts and notifications

  ## Security
  - Enable RLS on all tables
  - Add policies for authenticated users and admin management
  - Implement proper data access controls

  ## Search & Performance
  - Add indexes for search optimization
  - Full-text search vectors for content discovery
*/

-- Create companies table
CREATE TABLE IF NOT EXISTS companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  logo_url TEXT,
  website_url TEXT,
  description TEXT,
  industry TEXT,
  headquarters TEXT,
  employee_count TEXT,
  founded_year INTEGER,
  linkedin_url TEXT,
  twitter_url TEXT,
  glassdoor_url TEXT,
  careers_url TEXT,
  is_hiring BOOLEAN DEFAULT TRUE,
  priority_score INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create jobs table with comprehensive filters
CREATE TABLE IF NOT EXISTS jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  location TEXT NOT NULL,
  experience_level TEXT NOT NULL CHECK (experience_level IN ('internship', 'fresher', 'entry', '0-1yr', '1-2yr', '2-3yr', '3-5yr', '5+yr')),
  graduation_years INTEGER[] DEFAULT '{}',
  job_type TEXT NOT NULL CHECK (job_type IN ('full-time', 'part-time', 'contract', 'internship')),
  work_mode TEXT NOT NULL DEFAULT 'office' CHECK (work_mode IN ('office', 'remote', 'hybrid')),
  stipend_min NUMERIC,
  stipend_max NUMERIC,
  ctc_min NUMERIC,
  ctc_max NUMERIC,
  skills_required TEXT[] DEFAULT '{}',
  role_category TEXT,
  department TEXT,
  apply_link TEXT NOT NULL,
  source TEXT NOT NULL DEFAULT 'direct' CHECK (source IN ('direct', 'careers', 'linkedin', 'off-campus', 'referral', 'naukri', 'internshala')),
  posted_at TIMESTAMPTZ DEFAULT NOW(),
  deadline TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  is_active BOOLEAN DEFAULT TRUE,
  is_featured BOOLEAN DEFAULT FALSE,
  views INTEGER DEFAULT 0,
  applications_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', 
      COALESCE(title, '') || ' ' || 
      COALESCE(description, '') || ' ' || 
      COALESCE(array_to_string(skills_required, ' '), '') || ' ' ||
      COALESCE(location, '') || ' ' ||
      COALESCE(role_category, '')
    )
  ) STORED
);

-- Create webinars table
CREATE TABLE IF NOT EXISTS webinars (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  speaker_name TEXT NOT NULL,
  speaker_bio TEXT,
  speaker_image_url TEXT,
  webinar_date TIMESTAMPTZ NOT NULL,
  duration_minutes INTEGER DEFAULT 60,
  max_capacity INTEGER,
  current_registrations INTEGER DEFAULT 0,
  is_paid BOOLEAN DEFAULT FALSE,
  price NUMERIC DEFAULT 0,
  registration_link TEXT,
  meeting_link TEXT,
  recording_url TEXT,
  is_featured BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create webinar registrations table
CREATE TABLE IF NOT EXISTS webinar_registrations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  webinar_id UUID NOT NULL REFERENCES webinars(id) ON DELETE CASCADE,
  registration_date TIMESTAMPTZ DEFAULT NOW(),
  payment_status TEXT NOT NULL DEFAULT 'pending' CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_id TEXT,
  amount_paid NUMERIC DEFAULT 0,
  attendance_status TEXT DEFAULT 'registered' CHECK (attendance_status IN ('registered', 'attended', 'missed')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, webinar_id)
);

-- Create blog categories table
CREATE TABLE IF NOT EXISTS blog_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT,
  icon TEXT,
  color TEXT DEFAULT '#3B82F6',
  parent_id UUID REFERENCES blog_categories(id) ON DELETE SET NULL,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create blog tags table
CREATE TABLE IF NOT EXISTS blog_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT UNIQUE NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  color TEXT DEFAULT '#6B7280',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create blogs table with SEO optimization
CREATE TABLE IF NOT EXISTS blogs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  author_id UUID NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
  category_id UUID NOT NULL REFERENCES blog_categories(id) ON DELETE RESTRICT,
  content TEXT NOT NULL,
  excerpt TEXT,
  featured_image_url TEXT,
  meta_title TEXT,
  meta_description TEXT,
  published_at TIMESTAMPTZ,
  is_published BOOLEAN DEFAULT FALSE,
  is_featured BOOLEAN DEFAULT FALSE,
  reading_time INTEGER,
  views INTEGER DEFAULT 0,
  likes INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  search_vector tsvector GENERATED ALWAYS AS (
    to_tsvector('english', 
      COALESCE(title, '') || ' ' || 
      COALESCE(content, '') || ' ' || 
      COALESCE(excerpt, '') || ' ' ||
      COALESCE(meta_description, '')
    )
  ) STORED
);

-- Create blog post tags junction table
CREATE TABLE IF NOT EXISTS blog_post_tags (
  blog_id UUID NOT NULL REFERENCES blogs(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES blog_tags(id) ON DELETE CASCADE,
  PRIMARY KEY (blog_id, tag_id)
);

-- Create services table
CREATE TABLE IF NOT EXISTS services (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  slug TEXT UNIQUE NOT NULL,
  description TEXT NOT NULL,
  detailed_description TEXT,
  price NUMERIC NOT NULL DEFAULT 0,
  duration_days INTEGER,
  features TEXT[] DEFAULT '{}',
  is_active BOOLEAN DEFAULT TRUE,
  is_popular BOOLEAN DEFAULT FALSE,
  icon TEXT,
  image_url TEXT,
  testimonials JSONB DEFAULT '[]'::jsonb,
  faq JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create service inquiries table
CREATE TABLE IF NOT EXISTS service_inquiries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
  inquiry_type TEXT NOT NULL DEFAULT 'general' CHECK (inquiry_type IN ('general', 'pricing', 'custom', 'consultation')),
  message TEXT NOT NULL,
  contact_preference TEXT DEFAULT 'email' CHECK (contact_preference IN ('email', 'phone', 'whatsapp')),
  urgency TEXT DEFAULT 'normal' CHECK (urgency IN ('low', 'normal', 'high', 'urgent')),
  status TEXT DEFAULT 'new' CHECK (status IN ('new', 'in_progress', 'quoted', 'closed')),
  admin_notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create subscribers table for newsletter
CREATE TABLE IF NOT EXISTS subscribers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  phone TEXT,
  telegram_username TEXT,
  subscription_type TEXT NOT NULL DEFAULT 'email' CHECK (subscription_type IN ('email', 'whatsapp', 'telegram', 'all')),
  preferences JSONB DEFAULT '{}'::jsonb,
  is_active BOOLEAN DEFAULT TRUE,
  verified BOOLEAN DEFAULT FALSE,
  verification_token TEXT,
  subscribed_at TIMESTAMPTZ DEFAULT NOW(),
  unsubscribed_at TIMESTAMPTZ
);

-- Create alerts table for job alerts
CREATE TABLE IF NOT EXISTS alerts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  alert_type TEXT NOT NULL DEFAULT 'job' CHECK (alert_type IN ('job', 'webinar', 'blog', 'exam')),
  criteria JSONB NOT NULL,
  frequency TEXT NOT NULL DEFAULT 'daily' CHECK (frequency IN ('instant', 'daily', 'weekly')),
  is_active BOOLEAN DEFAULT TRUE,
  last_sent TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE webinars ENABLE ROW LEVEL SECURITY;
ALTER TABLE webinar_registrations ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE blogs ENABLE ROW LEVEL SECURITY;
ALTER TABLE blog_post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE services ENABLE ROW LEVEL SECURITY;
ALTER TABLE service_inquiries ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscribers ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;

-- RLS Policies for companies
CREATE POLICY "Anyone can read companies" ON companies FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage companies" ON companies FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for jobs
CREATE POLICY "Anyone can read active jobs" ON jobs FOR SELECT TO authenticated USING (is_active = TRUE);
CREATE POLICY "Admins can manage jobs" ON jobs FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for webinars
CREATE POLICY "Anyone can read webinars" ON webinars FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage webinars" ON webinars FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for webinar registrations
CREATE POLICY "Users can read own registrations" ON webinar_registrations FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own registrations" ON webinar_registrations FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can manage all registrations" ON webinar_registrations FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for blog categories
CREATE POLICY "Anyone can read blog categories" ON blog_categories FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage blog categories" ON blog_categories FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for blog tags
CREATE POLICY "Anyone can read blog tags" ON blog_tags FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage blog tags" ON blog_tags FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for blogs
CREATE POLICY "Anyone can read published blogs" ON blogs FOR SELECT TO authenticated USING (is_published = TRUE);
CREATE POLICY "Admins can manage blogs" ON blogs FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for blog post tags
CREATE POLICY "Anyone can read blog post tags" ON blog_post_tags FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage blog post tags" ON blog_post_tags FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for services
CREATE POLICY "Anyone can read services" ON services FOR SELECT TO authenticated USING (is_active = TRUE);
CREATE POLICY "Admins can manage services" ON services FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for service inquiries
CREATE POLICY "Users can read own inquiries" ON service_inquiries FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create inquiries" ON service_inquiries FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Admins can manage all inquiries" ON service_inquiries FOR ALL USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);

-- RLS Policies for subscribers
CREATE POLICY "Admins can read all subscribers" ON subscribers FOR SELECT USING (
  EXISTS (SELECT 1 FROM users WHERE users.id = auth.uid() AND users.email IN ('admin@primojobs.com', 'demo@primojobs.com', 'primoboostai@gmail.com'))
);
CREATE POLICY "Anyone can subscribe" ON subscribers FOR INSERT WITH CHECK (true);

-- RLS Policies for alerts
CREATE POLICY "Users can manage own alerts" ON alerts FOR ALL USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_jobs_company_id ON jobs(company_id);
CREATE INDEX IF NOT EXISTS idx_jobs_experience_level ON jobs(experience_level);
CREATE INDEX IF NOT EXISTS idx_jobs_location ON jobs(location);
CREATE INDEX IF NOT EXISTS idx_jobs_deadline ON jobs(deadline);
CREATE INDEX IF NOT EXISTS idx_jobs_search_vector ON jobs USING gin(search_vector);
CREATE INDEX IF NOT EXISTS idx_jobs_featured ON jobs(is_featured) WHERE is_featured = TRUE;
CREATE INDEX IF NOT EXISTS idx_jobs_active ON jobs(is_active) WHERE is_active = TRUE;

CREATE INDEX IF NOT EXISTS idx_webinars_date ON webinars(webinar_date);
CREATE INDEX IF NOT EXISTS idx_webinars_featured ON webinars(is_featured) WHERE is_featured = TRUE;

CREATE INDEX IF NOT EXISTS idx_blogs_published ON blogs(is_published, published_at) WHERE is_published = TRUE;
CREATE INDEX IF NOT EXISTS idx_blogs_category ON blogs(category_id);
CREATE INDEX IF NOT EXISTS idx_blogs_search_vector ON blogs USING gin(search_vector);
CREATE INDEX IF NOT EXISTS idx_blogs_featured ON blogs(is_featured) WHERE is_featured = TRUE;

CREATE INDEX IF NOT EXISTS idx_companies_hiring ON companies(is_hiring) WHERE is_hiring = TRUE;
CREATE INDEX IF NOT EXISTS idx_companies_priority ON companies(priority_score DESC);

-- Insert default blog categories
INSERT INTO blog_categories (name, slug, description, icon, color) VALUES
('Job Strategy', 'job-strategy', 'Strategic guidance for job hunting and career planning', 'Target', '#3B82F6'),
('Company Guides', 'company-guides', 'In-depth company profiles and hiring insights', 'Building', '#10B981'),
('Interview Prep', 'interview-prep', 'Tips and techniques for acing interviews', 'MessageCircle', '#8B5CF6'),
('Roadmaps', 'roadmaps', 'Career roadmaps and skill development paths', 'Map', '#F59E0B'),
('Exam Prep', 'exam-prep', 'Preparation guides for coding and aptitude tests', 'BookOpen', '#EF4444')
ON CONFLICT (slug) DO NOTHING;

-- Insert default blog tags
INSERT INTO blog_tags (name, slug, color) VALUES
('Fresher Jobs', 'fresher-jobs', '#3B82F6'),
('Interview Tips', 'interview-tips', '#10B981'),
('Resume Writing', 'resume-writing', '#8B5CF6'),
('Coding Interview', 'coding-interview', '#F59E0B'),
('Aptitude Test', 'aptitude-test', '#EF4444'),
('Soft Skills', 'soft-skills', '#06B6D4'),
('Career Growth', 'career-growth', '#84CC16'),
('Salary Negotiation', 'salary-negotiation', '#F97316')
ON CONFLICT (slug) DO NOTHING;

-- Insert default services
INSERT INTO services (name, slug, description, detailed_description, price, duration_days, features, is_popular, icon) VALUES
(
  'JD-based Resume Optimizer',
  'resume-optimizer',
  'AI-powered resume optimization based on specific job descriptions',
  'Our advanced AI analyzes job descriptions and optimizes your resume for maximum ATS compatibility and recruiter appeal.',
  999,
  3,
  ARRAY['ATS Optimization', 'Keyword Integration', 'Format Enhancement', '24/7 Support', 'Unlimited Revisions'],
  TRUE,
  'FileText'
),
(
  'Interview Preparation Coaching',
  'interview-prep',
  'One-on-one interview coaching with industry experts',
  'Personalized interview coaching sessions covering technical, behavioral, and case study interviews.',
  1999,
  7,
  ARRAY['Mock Interviews', 'Feedback Reports', 'Industry-specific Prep', 'Follow-up Sessions'],
  TRUE,
  'MessageSquare'
),
(
  'Project Guidance & Portfolio Building',
  'project-guidance',
  'Build impressive projects that stand out to recruiters',
  'Get expert guidance on selecting, building, and presenting projects that showcase your skills effectively.',
  1499,
  14,
  ARRAY['Project Selection', 'Code Reviews', 'Portfolio Website', 'GitHub Optimization'],
  FALSE,
  'Code'
),
(
  'Complete Profile Building',
  'profile-building',
  'End-to-end professional profile enhancement',
  'Complete makeover of your professional presence including LinkedIn, GitHub, and portfolio optimization.',
  2499,
  10,
  ARRAY['LinkedIn Optimization', 'GitHub Enhancement', 'Portfolio Creation', 'Professional Photography Guidance'],
  FALSE,
  'User'
)
ON CONFLICT (slug) DO NOTHING;

-- Insert sample companies
INSERT INTO companies (name, slug, description, industry, headquarters, website_url, logo_url, is_hiring, priority_score) VALUES
(
  'Tata Consultancy Services',
  'tcs',
  'Tata Consultancy Services (TCS) is an Indian multinational information technology services and consulting company.',
  'Information Technology',
  'Mumbai, India',
  'https://www.tcs.com',
  'https://logos-world.net/wp-content/uploads/2020/09/TCS-Emblem.png',
  TRUE,
  100
),
(
  'Wipro Limited',
  'wipro',
  'Wipro Limited is an Indian multinational corporation that provides information technology, consulting and business process services.',
  'Information Technology',
  'Bangalore, India', 
  'https://www.wipro.com',
  'https://upload.wikimedia.org/wikipedia/commons/a/a0/Wipro_Primary_Logo_Color_RGB.png',
  TRUE,
  95
),
(
  'Infosys Limited',
  'infosys',
  'Infosys is an Indian multinational information technology company that provides business consulting, information technology and outsourcing services.',
  'Information Technology',
  'Bangalore, India',
  'https://www.infosys.com',
  'https://upload.wikimedia.org/wikipedia/commons/9/95/Infosys_logo.svg',
  TRUE,
  95
),
(
  'Tech Mahindra',
  'tech-mahindra',
  'Tech Mahindra Limited is an Indian multinational information technology services and consulting company.',
  'Information Technology',
  'Pune, India',
  'https://www.techmahindra.com',
  'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/Tech_Mahindra_New_Logo.svg/1280px-Tech_Mahindra_New_Logo.svg.png',
  TRUE,
  90
)
ON CONFLICT (slug) DO NOTHING;

-- Insert sample jobs
INSERT INTO jobs (company_id, title, slug, description, location, experience_level, graduation_years, job_type, work_mode, stipend_min, stipend_max, ctc_min, ctc_max, skills_required, role_category, department, apply_link, source, deadline) 
SELECT 
  c.id,
  'Software Developer Trainee',
  'software-developer-trainee-' || c.slug,
  'Join our team as a Software Developer Trainee and kickstart your career in technology. You will work on real-world projects while learning from experienced professionals.',
  'Multiple Locations',
  'fresher',
  ARRAY[2024, 2025],
  'full-time',
  'office',
  15000,
  25000,
  300000,
  500000,
  ARRAY['Java', 'Python', 'JavaScript', 'SQL', 'Git'],
  'Software Development',
  'Engineering',
  'https://careers.example.com/apply',
  'direct',
  NOW() + INTERVAL '30 days'
FROM companies c
WHERE c.slug IN ('tcs', 'wipro', 'infosys', 'tech-mahindra')
ON CONFLICT (slug) DO NOTHING;

-- Insert sample webinars
INSERT INTO webinars (title, slug, description, speaker_name, speaker_bio, webinar_date, duration_minutes, max_capacity, is_paid, price, is_featured) VALUES
(
  'Cracking the Coding Interview: Data Structures & Algorithms',
  'cracking-coding-interview-dsa',
  'Master the fundamentals of data structures and algorithms to excel in technical interviews at top companies.',
  'Rahul Sharma',
  'Senior Software Engineer at Google with 8+ years of experience in system design and algorithms.',
  NOW() + INTERVAL '7 days',
  90,
  500,
  TRUE,
  299,
  TRUE
),
(
  'Resume Building Workshop for Freshers',
  'resume-building-freshers',
  'Learn how to create a compelling resume that stands out to recruiters and gets you interview calls.',
  'Priya Patel',
  'HR Director with 10+ years of experience in talent acquisition across IT companies.',
  NOW() + INTERVAL '14 days',
  60,
  1000,
  FALSE,
  0,
  FALSE
),
(
  'System Design Fundamentals',
  'system-design-fundamentals',
  'Introduction to system design concepts essential for software engineering roles.',
  'Amit Kumar',
  'Principal Engineer at Amazon, specializing in distributed systems and scalable architecture.',
  NOW() - INTERVAL '7 days',
  120,
  300,
  TRUE,
  499,
  FALSE
)
ON CONFLICT (slug) DO NOTHING;

-- Insert sample blog posts
INSERT INTO blogs (title, slug, author_id, category_id, content, excerpt, meta_title, meta_description, published_at, is_published, is_featured, reading_time) 
SELECT 
  'How to Land Your First Job as a Fresher in 2024',
  'land-first-job-fresher-2024',
  u.id,
  c.id,
  'Landing your first job as a fresher can be challenging, but with the right strategy, you can increase your chances significantly...',
  'A comprehensive guide for freshers to navigate the job market and land their dream job in 2024.',
  'How to Land Your First Job as a Fresher in 2024 | PrimoJobs',
  'Complete guide for freshers to land their first job in 2024. Tips, strategies, and actionable advice from industry experts.',
  NOW() - INTERVAL '2 days',
  TRUE,
  TRUE,
  8
FROM users u, blog_categories c 
WHERE u.email = 'admin@primojobs.com' AND c.slug = 'job-strategy'
LIMIT 1
ON CONFLICT (slug) DO NOTHING;

-- Create functions for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers for auto-updating timestamps
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_jobs_updated_at BEFORE UPDATE ON jobs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_webinars_updated_at BEFORE UPDATE ON webinars FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_blogs_updated_at BEFORE UPDATE ON blogs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_services_updated_at BEFORE UPDATE ON services FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_service_inquiries_updated_at BEFORE UPDATE ON service_inquiries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();