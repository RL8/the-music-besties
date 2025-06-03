# Deployment Guide for The Music Besties

This guide provides instructions for deploying The Music Besties application to production environments.

## Prerequisites

Before deploying, ensure you have:

1. A Supabase account and project set up
2. Access to a hosting platform for the frontend (e.g., Vercel, Netlify)
3. Access to a hosting platform for the backend (e.g., Railway, Heroku, or a VPS)
4. An OpenAI API key for the chat functionality

## Database Setup

### 1. Set Up Supabase Tables

Execute the schema SQL in the Supabase SQL editor:

1. Navigate to your Supabase project dashboard
2. Go to the SQL Editor
3. Copy the contents of `database/schema-phase1.sql`
4. Run the SQL to create all necessary tables

### 2. Configure Row-Level Security (RLS)

Set up RLS policies to secure your data:

1. Go to the Authentication → Policies section in Supabase
2. For each table, create appropriate policies:

**Profiles Table**:
- Allow users to read their own profile
- Allow users to update their own profile

```sql
-- Read policy
CREATE POLICY "Users can view their own profile"
ON profiles
FOR SELECT
USING (auth.uid() = id);

-- Update policy
CREATE POLICY "Users can update their own profile"
ON profiles
FOR UPDATE
USING (auth.uid() = id);
```

**User Curations Table**:
- Allow users to read their own curations
- Allow users to create and update their own curations

```sql
-- Read policy
CREATE POLICY "Users can view their own curations"
ON user_curations
FOR SELECT
USING (auth.uid() = user_id);

-- Insert policy
CREATE POLICY "Users can create their own curations"
ON user_curations
FOR INSERT
WITH CHECK (auth.uid() = user_id);

-- Update policy
CREATE POLICY "Users can update their own curations"
ON user_curations
FOR UPDATE
USING (auth.uid() = user_id);
```

## Backend Deployment

### Option 1: Railway

1. Create a new project in Railway
2. Connect your GitHub repository
3. Configure the following environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_KEY`: Your Supabase service role key (for admin operations)
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `FRONTEND_URL`: The URL of your frontend application
   - `PORT`: 8000 (or as required by the platform)
4. Set the start command to: `cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT`

### Option 2: Heroku

1. Create a new Heroku app
2. Connect your GitHub repository
3. Add a `Procfile` to the root of your project with the content:
   ```
   web: cd backend && uvicorn main:app --host 0.0.0.0 --port $PORT
   ```
4. Configure the following environment variables in Heroku settings:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_KEY`: Your Supabase service role key
   - `OPENAI_API_KEY`: Your OpenAI API key
   - `FRONTEND_URL`: The URL of your frontend application

### Option 3: VPS (e.g., DigitalOcean, AWS EC2)

1. SSH into your server
2. Clone your repository
3. Install dependencies:
   ```bash
   cd the-music-besties
   cd backend
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -r requirements.txt
   ```
4. Create a `.env` file in the backend directory with the required environment variables
5. Set up a process manager like PM2 or systemd to keep the application running
6. Configure Nginx as a reverse proxy to your application

Example Nginx configuration:
```nginx
server {
    listen 80;
    server_name api.musicbesties.app;

    location / {
        proxy_pass http://localhost:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## Frontend Deployment

### Option 1: Vercel (Recommended for Nuxt.js)

1. Create a new project in Vercel
2. Connect your GitHub repository
3. Configure the following environment variables:
   - `SUPABASE_URL`: Your Supabase project URL
   - `SUPABASE_KEY`: Your Supabase anon/public key (not the service role key)
   - `API_BASE_URL`: The URL of your deployed backend
4. Set the framework preset to "Nuxt.js"
5. Deploy the application

### Option 2: Netlify

1. Create a new site in Netlify
2. Connect your GitHub repository
3. Set the build command to: `npm run build`
4. Set the publish directory to: `.output/public`
5. Configure the environment variables as with Vercel
6. Deploy the application

## Post-Deployment Steps

### 1. Update CORS Settings

Ensure your backend allows requests from your frontend domain:

1. Update the CORS configuration in `backend/main.py` to include your frontend domain
2. Redeploy the backend

### 2. Test the Deployed Application

1. Test user registration and login
2. Test the music curation flow
3. Verify that the chat interface works correctly
4. Check that the sideboard displays user curations

### 3. Set Up Monitoring (Optional)

1. Implement logging with a service like Sentry or LogRocket
2. Set up uptime monitoring with UptimeRobot or similar
3. Configure performance monitoring

## Troubleshooting

### Common Issues

1. **CORS Errors**: Ensure the backend CORS configuration includes your frontend domain
2. **Authentication Issues**: Verify Supabase keys and URLs are correct
3. **API Connection Problems**: Check network settings and firewall rules
4. **Environment Variables**: Ensure all required variables are set correctly

### Logs and Debugging

- Backend logs can be accessed through your hosting platform's logging interface
- For Vercel and Netlify, check the deployment logs in their respective dashboards
- For VPS deployments, check the application logs in your configured log location

## Scaling Considerations

As your user base grows, consider:

1. Upgrading your Supabase plan for increased database capacity
2. Implementing caching strategies for frequently accessed data
3. Setting up a CDN for static assets
4. Using serverless functions for specific high-load operations

## Backup and Recovery

1. Regularly export your Supabase database for backup
2. Document the deployment process for quick recovery in case of issues
3. Consider setting up a staging environment for testing changes before production

## Security Considerations

1. Ensure all API keys and secrets are stored securely as environment variables
2. Regularly rotate API keys and credentials
3. Implement rate limiting for API endpoints
4. Keep dependencies updated to patch security vulnerabilities
