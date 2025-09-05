export interface User {
  id: string;
  name: string;
  email: string;
  password: string;
  isAdmin?: boolean;
  createdAt: Date;
}

export interface Question {
  id: string;
  company: string;
  role: string;
  category: 'coding' | 'aptitude' | 'interview' | 'technical';
  difficulty: 'easy' | 'medium' | 'hard';
  questionText: string;
  solutionText: string;
  codeExample?: string;
  explanation: string;
  tags: string[];
  imageUrl?: string;
  price?: number;
  isActive?: boolean;
  showOnHomepage?: boolean;
  homepageOrder?: number;
  createdAt: Date;
  updatedAt: Date;
}

export interface AccessLog {
  id: string;
  userId: string;
  questionId: string;
  accessStartTime: Date;
  accessExpiryTime: Date;
  paymentStatus: boolean;
  paymentId?: string;
  amountPaid: number;
}

export interface PaymentSettings {
  basePrice: number;
  currency: string;
  activeCoupons: CouponCode[];
}

export interface CouponCode {
  code: string;
  discount: number;
  description?: string;
}

export interface Material {
  id: string;
  title: string;
  description: string;
  category: 'interview-tips' | 'coding-guide' | 'aptitude-tricks' | 'company-specific';
  company?: string;
  role?: string;
  content: string;
  imageUrl: string;
  uploadedAt: Date;
}

export interface Company {
  id: string;
  name: string;
  slug: string;
  logo_url?: string;
  website_url?: string;
  description?: string;
  industry?: string;
  headquarters?: string;
  employee_count?: string;
  founded_year?: number;
  linkedin_url?: string;
  twitter_url?: string;
  glassdoor_url?: string;
  careers_url?: string;
  is_hiring: boolean;
  priority_score: number;
  created_at: Date;
  updated_at: Date;
}

export interface Job {
  id: string;
  company_id: string;
  title: string;
  slug: string;
  description: string;
  location: string;
  experience_level: 'internship' | 'fresher' | 'entry' | '0-1yr' | '1-2yr' | '2-3yr' | '3-5yr' | '5+yr';
  graduation_years: number[];
  job_type: 'full-time' | 'part-time' | 'contract' | 'internship';
  work_mode: 'office' | 'remote' | 'hybrid';
  stipend_min?: number;
  stipend_max?: number;
  ctc_min?: number;
  ctc_max?: number;
  skills_required: string[];
  role_category?: string;
  department?: string;
  apply_link: string;
  source: 'direct' | 'careers' | 'linkedin' | 'off-campus' | 'referral' | 'naukri' | 'internshala';
  posted_at: Date;
  deadline?: Date;
  expires_at?: Date;
  is_active: boolean;
  is_featured: boolean;
  views: number;
  applications_count: number;
  created_at: Date;
  updated_at: Date;
}

export interface Webinar {
  id: string;
  title: string;
  slug: string;
  description: string;
  speaker_name: string;
  speaker_bio?: string;
  speaker_image_url?: string;
  webinar_date: Date;
  duration_minutes: number;
  max_capacity?: number;
  current_registrations: number;
  is_paid: boolean;
  price: number;
  registration_link?: string;
  meeting_link?: string;
  recording_url?: string;
  is_featured: boolean;
  created_at: Date;
  updated_at: Date;
}

export interface WebinarRegistration {
  id: string;
  user_id: string;
  webinar_id: string;
  registration_date: Date;
  payment_status: 'pending' | 'completed' | 'failed' | 'refunded';
  payment_id?: string;
  amount_paid: number;
  attendance_status: 'registered' | 'attended' | 'missed';
  created_at: Date;
}

export interface BlogCategory {
  id: string;
  name: string;
  slug: string;
  description?: string;
  icon?: string;
  color: string;
  parent_id?: string;
  sort_order: number;
  created_at: Date;
}

export interface BlogTag {
  id: string;
  name: string;
  slug: string;
  color: string;
  created_at: Date;
}

export interface Blog {
  id: string;
  title: string;
  slug: string;
  author_id: string;
  category_id: string;
  content: string;
  excerpt?: string;
  featured_image_url?: string;
  meta_title?: string;
  meta_description?: string;
  published_at?: Date;
  is_published: boolean;
  is_featured: boolean;
  reading_time?: number;
  views: number;
  likes: number;
  created_at: Date;
  updated_at: Date;
  tags?: BlogTag[];
  category?: BlogCategory;
  author?: User;
}

export interface Service {
  id: string;
  name: string;
  slug: string;
  description: string;
  detailed_description?: string;
  price: number;
  duration_days?: number;
  features: string[];
  is_active: boolean;
  is_popular: boolean;
  icon?: string;
  image_url?: string;
  testimonials: any[];
  faq: any[];
  created_at: Date;
  updated_at: Date;
}

export interface ServiceInquiry {
  id: string;
  user_id: string;
  service_id: string;
  inquiry_type: 'general' | 'pricing' | 'custom' | 'consultation';
  message: string;
  contact_preference: 'email' | 'phone' | 'whatsapp';
  urgency: 'low' | 'normal' | 'high' | 'urgent';
  status: 'new' | 'in_progress' | 'quoted' | 'closed';
  admin_notes?: string;
  created_at: Date;
  updated_at: Date;
}

export interface Subscriber {
  id: string;
  email: string;
  phone?: string;
  telegram_username?: string;
  subscription_type: 'email' | 'whatsapp' | 'telegram' | 'all';
  preferences: any;
  is_active: boolean;
  verified: boolean;
  verification_token?: string;
  subscribed_at: Date;
  unsubscribed_at?: Date;
}

export interface Alert {
  id: string;
  user_id: string;
  alert_type: 'job' | 'webinar' | 'blog' | 'exam';
  criteria: any;
  frequency: 'instant' | 'daily' | 'weekly';
  is_active: boolean;
  last_sent?: Date;
  created_at: Date;
}

export interface CompanyRole {
  id: string;
  company: string;
  role: string;
  description: string;
  requirements: string[];
  examPattern: ExamSection[];
  totalQuestions: number;
  isActive: boolean;
}

export interface ExamSection {
  name: string;
  questions: number;
  duration: number;
  type: 'coding' | 'aptitude' | 'technical' | 'interview';
}