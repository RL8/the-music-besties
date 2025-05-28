// sync-env.js
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Starting environment variable sync...');

try {
  // Load master .env
  const masterEnvPath = path.resolve(path.join(__dirname, '.env.master'));
  if (!fs.existsSync(masterEnvPath)) {
    console.error('Error: .env.master file not found!');
    console.log('Please create a .env.master file based on env-master-template.txt');
    process.exit(1);
  }

  console.log('Loading master environment variables...');
  const masterEnv = dotenv.parse(fs.readFileSync(masterEnvPath));

  // Frontend variables
  const frontendVars = {
    VUE_APP_FASTAPI_URL: masterEnv.BACKEND_URL || 'http://localhost:8000',
    VUE_APP_SUPABASE_URL: masterEnv.SUPABASE_URL || '',
    VUE_APP_SUPABASE_KEY: masterEnv.SUPABASE_KEY || ''
  };

  // Backend variables
  const backendVars = {
    SUPABASE_URL: masterEnv.SUPABASE_URL || '',
    SUPABASE_KEY: masterEnv.SUPABASE_KEY || '',
    OPENAI_API_KEY: masterEnv.OPENAI_API_KEY || '',
    FRONTEND_URL: masterEnv.FRONTEND_URL || 'http://localhost:3000'
  };

  // Write frontend .env
  console.log('Writing frontend environment variables...');
  fs.writeFileSync(path.join(__dirname, '.env'), Object.entries(frontendVars)
    .map(([key, val]) => `${key}=${val}`)
    .join('\n'));

  // Write backend .env
  console.log('Writing backend environment variables...');
  fs.writeFileSync(path.join(__dirname, 'backend', '.env'), Object.entries(backendVars)
    .map(([key, val]) => `${key}=${val}`)
    .join('\n'));

  console.log('Environment variables synced successfully!');
} catch (error) {
  console.error('Error syncing environment variables:', error.message);
  process.exit(1);
}
