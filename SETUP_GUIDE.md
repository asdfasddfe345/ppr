# 🚀 Complete Setup Guide for PrimoJobs

## Step 1: Create Supabase Project

1. **Go to [supabase.com](https://supabase.com)**
2. **Click "Start your project"**
3. **Sign up/Login with GitHub or Google**
4. **Click "New Project"**
5. **Fill in project details:**
   - Organization: Choose or create one
   - Name: `primojobs-exam-hub`
   - Database Password: Create a strong password
   - Region: Choose closest to your users
6. **Click "Create new project"**
7. **Wait 2-3 minutes for setup to complete**

## Step 2: Get Your Supabase Credentials

1. **In your Supabase dashboard, go to Settings → API**
2. **Copy these values:**
   - Project URL (looks like: `https://abcdefghijklmnop.supabase.co`)
   - Anon public key (starts with `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`)

## Step 3: Update Environment Variables

1. **Open the `.env` file in your project**
2. **Replace the placeholder values:**

```env
VITE_SUPABASE_URL=https://your-actual-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-actual-anon-key-here
```

## Step 4: Set Up Database Tables

1. **In Supabase dashboard, go to SQL Editor**
2. **Click "New Query"**
3. **Copy and paste this SQL:**

```sql
-- Create users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create questions table
CREATE TABLE questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  company TEXT NOT NULL,
  role TEXT NOT NULL,
  category TEXT NOT NULL,
  question_text TEXT NOT NULL,
  solution_code TEXT NOT NULL,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create access_logs table
CREATE TABLE access_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  question_id UUID REFERENCES questions(id) ON DELETE CASCADE,
  access_start_time TIMESTAMPTZ NOT NULL,
  access_expiry_time TIMESTAMPTZ NOT NULL,
  payment_status BOOLEAN DEFAULT FALSE,
  payment_id TEXT,
  amount_paid NUMERIC NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create materials table
CREATE TABLE materials (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  image_url TEXT NOT NULL,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create payment_settings table
CREATE TABLE payment_settings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  base_price NUMERIC NOT NULL DEFAULT 49,
  currency TEXT NOT NULL DEFAULT 'INR',
  active_coupons JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE access_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_settings ENABLE ROW LEVEL SECURITY;

-- Create policies for users table
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);
CREATE POLICY "Allow insert for authenticated users" ON users FOR INSERT WITH CHECK (auth.uid() = id);

-- Create policies for questions table
CREATE POLICY "Anyone can read questions" ON questions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage questions" ON questions FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.email IN ('admin@primojobs.com', 'your-admin-email@gmail.com')
  )
);

-- Create policies for access_logs table
CREATE POLICY "Users can read own access logs" ON access_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own access logs" ON access_logs FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Create policies for materials table
CREATE POLICY "Anyone can read materials" ON materials FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage materials" ON materials FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.email IN ('admin@primojobs.com', 'your-admin-email@gmail.com')
  )
);

-- Create policies for payment_settings table
CREATE POLICY "Anyone can read payment settings" ON payment_settings FOR SELECT TO authenticated USING (true);
CREATE POLICY "Admins can manage payment settings" ON payment_settings FOR ALL USING (
  EXISTS (
    SELECT 1 FROM users 
    WHERE users.id = auth.uid() 
    AND users.email IN ('admin@primojobs.com', 'your-admin-email@gmail.com')
  )
);

-- Insert default data
INSERT INTO questions (company, role, category, question_text, solution_code, image_url) VALUES
('TCS', 'Software Engineer', 'Coding', 'Write a function to find the maximum element in an array.', 'function findMax(arr) { return Math.max(...arr); }', 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=800'),
('Wipro', 'Data Analyst', 'Aptitude', 'If a train travels 120 km in 2 hours, what is its speed?', 'Speed = Distance / Time = 120 / 2 = 60 km/h', 'https://images.pexels.com/photos/590022/pexels-photo-590022.jpeg?auto=compress&cs=tinysrgb&w=800'),
('Infosys', 'System Engineer', 'Interview', 'Explain the difference between SQL and NoSQL databases.', 'SQL: Relational, structured data, ACID properties. NoSQL: Non-relational, flexible schema, eventual consistency.', 'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=800');

INSERT INTO materials (title, description, image_url) VALUES
('Complete DSA Guide', 'Master data structures and algorithms with this comprehensive guide', 'https://images.pexels.com/photos/1181671/pexels-photo-1181671.jpeg?auto=compress&cs=tinysrgb&w=800'),
('Interview Tips & Tricks', 'Ace your technical interviews with these proven strategies', 'https://images.pexels.com/photos/1181244/pexels-photo-1181244.jpeg?auto=compress&cs=tinysrgb&w=800');

INSERT INTO payment_settings (base_price, currency, active_coupons) VALUES
(49, 'INR', '[{"code": "FREE100", "discount": 100, "description": "Free access"}, {"code": "HALF50", "discount": 50, "description": "50% off"}, {"code": "SAVE20", "discount": 20, "description": "20% discount"}]');
```

4. **Click "Run" to execute the SQL**

## Step 5: Configure Google OAuth

1. **In Supabase dashboard, go to Authentication → Providers**
2. **Find "Google" and click the toggle to enable it**
3. **Enter your Google OAuth credentials:**
   - Client ID: `688195257967-r2n6l9fauav7dv29bkk1jrlqdq4e75m3.apps.googleusercontent.com`
   - Client Secret: `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`
4. **Click "Save"**

## Step 6: Update Google Cloud Console

1. **Go to [Google Cloud Console](https://console.cloud.google.com)**
2. **Select your project**
3. **Go to APIs & Services → Credentials**
4. **Click on your OAuth 2.0 Client ID**
5. **Add these to Authorized JavaScript origins:**
   ```
   https://localhost:5173
   http://localhost:5173
   ```
   (Add your production domain here when deploying)

6. **Add this to Authorized redirect URIs:**
   ```
   https://your-actual-project-id.supabase.co/auth/v1/callback
   ```
7. **Click "Save"**

## Step 7: Test the Setup

1. **Restart your development server:**
   ```bash
   npm run dev
   ```
2. **Try to sign up with email or Google**
3. **Check if users appear in Supabase → Authentication → Users**

## Troubleshooting

### If you see "your-project.supabase.co's server IP address could not be found":
- Make sure you've updated the `.env` file with your actual Supabase URL
- Restart the development server after updating `.env`

### If Google login doesn't work:
- Check that you've enabled Google provider in Supabase
- Verify the redirect URI in Google Cloud Console
- Make sure your Google OAuth credentials are correct

### If database operations fail:
- Check that you've run the SQL commands in Supabase
- Verify that RLS policies are set up correctly
- Check the browser console for specific error messages

## Admin Access

To make yourself an admin, update your email in the SQL policies above, or manually update the user record in Supabase.

## Need Help?

If you encounter any issues:
1. Check the browser console for error messages
2. Check Supabase logs in the dashboard
3. Verify all environment variables are set correctly
4. Make sure all SQL commands executed successfully