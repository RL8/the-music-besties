// update-vercel-env.js
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { execSync } from 'child_process';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Updating Vercel environment variables for Nuxt.js compatibility...');

try {
  // Load existing .env file if it exists
  const envPath = path.join(__dirname, '.env');
  if (!fs.existsSync(envPath)) {
    console.error('Error: .env file not found!');
    process.exit(1);
  }

  const envContent = fs.readFileSync(envPath, 'utf8');
  const envVars = dotenv.parse(envContent);
  
  // Map Vue environment variables to Nuxt format
  const envMapping = {
    'VUE_APP_SUPABASE_URL': 'NUXT_PUBLIC_SUPABASE_URL',
    'VUE_APP_SUPABASE_KEY': 'NUXT_PUBLIC_SUPABASE_KEY',
    'VUE_APP_FASTAPI_URL': 'NUXT_PUBLIC_API_BASE_URL'
  };
  
  console.log('Creating .vercel/.env.production file with Nuxt-compatible environment variables...');
  
  // Create .vercel directory if it doesn't exist
  const vercelDir = path.join(__dirname, '.vercel');
  if (!fs.existsSync(vercelDir)) {
    fs.mkdirSync(vercelDir, { recursive: true });
  }
  
  // Create .env.production file with Nuxt-compatible environment variables
  let vercelEnvContent = '';
  
  // Add Nuxt-compatible environment variables
  for (const [vueVar, nuxtVar] of Object.entries(envMapping)) {
    if (envVars[vueVar]) {
      vercelEnvContent += `${nuxtVar}=${envVars[vueVar]}\n`;
      console.log(`Mapped ${vueVar} to ${nuxtVar}`);
    }
  }
  
  // Write to .vercel/.env.production
  const vercelEnvPath = path.join(vercelDir, '.env.production');
  fs.writeFileSync(vercelEnvPath, vercelEnvContent);
  
  console.log('Vercel environment variables updated successfully!');
  console.log('Now run "vercel --prod" to deploy with the updated environment variables');
} catch (error) {
  console.error('Error updating Vercel environment variables:', error.message);
  process.exit(1);
}
