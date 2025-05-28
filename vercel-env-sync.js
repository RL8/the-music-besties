// vercel-env-sync.js
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Starting Vercel environment variable sync...');

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

  // Define which variables to sync to Vercel
  const vercelVars = {
    VUE_APP_FASTAPI_URL: masterEnv.BACKEND_URL || 'http://localhost:8000',
    VUE_APP_SUPABASE_URL: masterEnv.SUPABASE_URL || '',
    VUE_APP_SUPABASE_KEY: masterEnv.SUPABASE_KEY || ''
  };

  console.log('Syncing environment variables to Vercel...');
  
  // Sync to Vercel
  Object.entries(vercelVars).forEach(([key, value]) => {
    try {
      console.log(`Setting ${key} in Vercel...`);
      
      // Remove existing variable if it exists (ignore errors)
      try {
        execSync(`vercel env rm ${key} production -y`, { stdio: 'pipe' });
      } catch (e) {
        // Variable might not exist yet, which is fine
      }
      
      // Add the new variable value
      // We use a temporary file to avoid issues with special characters in the value
      const tempFile = path.join(__dirname, '.temp-env-value');
      fs.writeFileSync(tempFile, value);
      
      execSync(`vercel env add ${key} production < ${tempFile}`, { stdio: 'inherit' });
      
      // Clean up temp file
      fs.unlinkSync(tempFile);
      
      console.log(`✅ Successfully set ${key} in Vercel`);
    } catch (error) {
      console.error(`❌ Failed to set ${key}: ${error.message}`);
    }
  });

  console.log('Vercel environment variables synced successfully!');
} catch (error) {
  console.error('Error syncing environment variables to Vercel:', error.message);
  process.exit(1);
}
