# 🔧 Google OAuth Setup Guide

## Current Issue: "The given origin is not allowed for the given client ID"

This error occurs when your local development server URL is not registered as an authorized origin in Google Cloud Console. You have the Supabase redirect URI configured, but since this app uses Google Identity Services directly, you need to configure your local development URLs.

## Quick Fix for Development

### Step 1: Update Google Cloud Console Settings

1. **Go to [Google Cloud Console](https://console.cloud.google.com)**
2. **Select your project** (or create a new one if needed)
3. **Navigate to APIs & Services → Credentials**
4. **Find the OAuth 2.0 Client ID**: `688195257967-r2n6l9fauav7dv29bkk1jrlqdq4e75m3.apps.googleusercontent.com`
5. **Click on it to edit**

### Step 2: Add Development URLs

**IMPORTANT**: Since your app uses Google Identity Services directly (not Supabase Auth), you need to add your local development URLs, not just the Supabase callback.

**In "Authorized JavaScript origins" section, add:**
```
http://localhost:5173
https://localhost:5173
http://127.0.0.1:5173
https://127.0.0.1:5173
https://afznkzacrdluvjlnqffr.supabase.co
```

**In "Authorized redirect URIs" section, keep your existing Supabase URI and add:**
```
https://afznkzacrdluvjlnqffr.supabase.co/auth/v1/callback
http://localhost:5173
https://localhost:5173
```

### Current Configuration Status
✅ **Supabase Redirect URI**: Already configured correctly
❌ **Local Development Origins**: Need to be added

### Step 3: Save and Test

1. **Click "Save"** in Google Cloud Console
2. **Wait 5-10 minutes** for changes to propagate
3. **Clear browser cache and cookies**
4. **Restart your development server**: `npm run dev`
5. **Try Google sign-in again**

## Alternative: Create Your Own OAuth Client

If you can't modify the existing client, create your own:

### 1. Enable Required APIs
- Go to **APIs & Services** → **Library**
- Enable: **Google+ API** and **Google Identity Services API**

### 2. Configure OAuth Consent Screen
- Go to **APIs & Services** → **OAuth consent screen**
- Choose **External** user type
- Fill required fields:
  - App name: `Your App Name`
  - User support email: Your email
  - Developer contact: Your email

### 3. Create New OAuth Client
- Go to **APIs & Services** → **Credentials**
- Click **Create Credentials** → **OAuth 2.0 Client IDs**
- Application type: **Web application**
- Add the origins and redirect URIs from Step 2 above

### 4. Update Your Code
Replace the client ID in `src/lib/googleAuth.ts`:
```typescript
private clientId = 'YOUR_NEW_CLIENT_ID_HERE';
```

## Troubleshooting

### Still getting origin errors?
- Double-check URLs are exactly correct (no trailing slashes)
- Ensure you're using the right protocol (http vs https)
- Try both `localhost` and `127.0.0.1`
- Wait 10 minutes after making changes

### Browser issues?
- **Clear all browser data** for localhost
- **Disable ad blockers** and privacy extensions
- **Allow third-party cookies**
- **Try incognito/private mode**
- **Try a different browser**

### Development workaround
If Google OAuth continues to fail, use these test accounts:
- **Demo User**: `demo@primojobs.com` / `demo123`
- **Admin User**: `admin@primojobs.com` / `admin123`

## Production Deployment

When deploying to production:

### Step 1: Get Your Production URL
After deploying to Netlify (or your chosen platform), you'll get a production URL like:
- `https://your-app-name.netlify.app`
- Or your custom domain: `https://yourdomain.com`

### Step 2: Update Google Cloud Console for Production
1. **Go to [Google Cloud Console](https://console.cloud.google.com)**
2. **Navigate to APIs & Services → Credentials**
3. **Edit your OAuth 2.0 Client ID**
4. **Add your production URLs to "Authorized JavaScript origins":**
   ```
   https://your-app-name.netlify.app
   https://yourdomain.com (if using custom domain)
   ```
5. **Keep your existing Supabase redirect URI in "Authorized redirect URIs":**
   ```
   https://afznkzacrdluvjlnqffr.supabase.co/auth/v1/callback
   ```
6. **Save the changes**

### Step 3: Complete Production Configuration
Your final Google OAuth configuration should include:

**Authorized JavaScript origins:**
```
http://localhost:5173                    (for local development)
https://localhost:5173                   (for local development)
https://your-app-name.netlify.app        (for production)
https://yourdomain.com                   (if using custom domain)
https://afznkzacrdluvjlnqffr.supabase.co (for Supabase)
```

**Authorized redirect URIs:**
```
https://afznkzacrdluvjlnqffr.supabase.co/auth/v1/callback
http://localhost:5173                    (for local development)
https://localhost:5173                   (for local development)
```

### Step 4: Test Production Deployment
1. Deploy your app to production
2. Wait 5-10 minutes for Google OAuth changes to propagate
3. Test Google sign-in on your production site
4. Verify that both email/password and Google authentication work

### Important Notes for Production:
- **HTTPS Required**: Google OAuth requires HTTPS in production (Netlify provides this automatically)
- **Domain Verification**: Make sure your production domain is correctly configured
- **Environment Variables**: Ensure your `.env` variables are set in your deployment platform
- **Propagation Time**: Google OAuth changes can take 5-10 minutes to take effect

### Troubleshooting Production Issues:
- **"Origin not allowed" error**: Double-check that your production URL is exactly correct in Google Cloud Console
- **Redirect URI mismatch**: Ensure the Supabase callback URL is correctly configured
- **HTTPS issues**: Verify your site is served over HTTPS
- **Cache issues**: Clear browser cache and try in incognito mode

## Need Immediate Access?

Use email/password authentication while setting up Google OAuth:
- The app works fully without Google sign-in
- Create account with any email/password
- Google sign-in is optional, not required