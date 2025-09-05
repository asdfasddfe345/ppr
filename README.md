# PrimoJobs Exam Hub

A comprehensive platform for students and job-seekers to access real-time company-specific coding, aptitude, and interview questions.

## Features

- 🔐 **Authentication**: Email/password and Google OAuth login
- 💳 **Payment Integration**: Razorpay with dynamic pricing and coupon codes
- 📚 **Question Bank**: Company-specific questions with solutions
- ⏰ **Time-based Access**: 1-hour paid access to premium content
- 👨‍💼 **Admin Panel**: Manage questions, materials, and payment settings
- 📱 **Responsive Design**: Works on mobile, tablet, and desktop

## Tech Stack

- **Frontend**: React + TypeScript + Tailwind CSS
- **Authentication**: Supabase Auth with Google OAuth
- **Database**: Supabase (PostgreSQL)
- **Payment**: Razorpay
- **Icons**: Lucide React

## Setup Instructions

### 1. Supabase Setup

1. Create a new project at [supabase.com](https://supabase.com)
2. Copy your project URL and anon key
3. Update the `.env` file with your Supabase credentials

### 2. Google OAuth Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project or select existing one
3. Enable Google+ API
4. Create OAuth 2.0 credentials:
   - Client ID: `688195257967-r2n6l9fauav7dv29bkk1jrlqdq4e75m3.apps.googleusercontent.com`
   - Client Secret: `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`
5. Add authorized origins and redirect URIs in Google Console:
   **Authorized JavaScript origins:**
   - `https://localhost:5173` (for local development)
   - `http://localhost:5173` (for local development)
   - Your production domain (when deploying)
   
   **Authorized redirect URIs:**
   - `https://your-project.supabase.co/auth/v1/callback`
6. In Supabase Dashboard → Authentication → Providers → Google:
   - Enable Google provider
   - Add your Client ID and Client Secret

### 3. Database Schema

Run these SQL commands in your Supabase SQL editor:

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

-- Create policies
CREATE POLICY "Users can read own data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own data" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Anyone can read questions" ON questions FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone can read materials" ON materials FOR SELECT TO authenticated USING (true);
CREATE POLICY "Anyone can read payment settings" ON payment_settings FOR SELECT TO authenticated USING (true);

CREATE POLICY "Users can read own access logs" ON access_logs FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own access logs" ON access_logs FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### 4. Environment Variables

Create a `.env` file:

```env
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

### 5. Install Dependencies

```bash
npm install
```

### 6. Run Development Server

```bash
npm run dev
```

## Admin Access

To make a user an admin, update the `fetchUserProfile` function in `AuthContext.tsx` to include your admin email:

```typescript
const isAdmin = existingUser.email === 'admin@primojobs.com' || 
               existingUser.email === 'your-admin-email@gmail.com';
```

## Payment Integration

The app includes Razorpay integration with:
- Dynamic pricing controlled by admin
- Coupon code system
- 1-hour time-based access
- Payment verification and logging

## Features Overview

### For Users:
- Browse questions by company, role, and category
- Pay for 1-hour access to solutions
- Track access history and remaining time
- Access free learning materials
- Google and email authentication

### For Admins:
- Add/edit/delete questions
- Manage payment settings and coupon codes
- Upload learning materials
- View user analytics

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License