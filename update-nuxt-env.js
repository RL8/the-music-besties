// update-nuxt-env.js
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Updating Nuxt.js environment with Railway backend URL including /api prefix...');

try {
  // Load existing .env file if it exists
  const envPath = path.join(__dirname, '.env');
  let envContent = '';
  
  if (fs.existsSync(envPath)) {
    envContent = fs.readFileSync(envPath, 'utf8');
    const envVars = dotenv.parse(envContent);
    
    // Update the backend URL with /api prefix
    envVars.VUE_APP_FASTAPI_URL = 'https://mb-api-service-production.up.railway.app/api';
    
    // Convert back to string
    envContent = Object.entries(envVars)
      .map(([key, val]) => `${key}=${val}`)
      .join('\n');
  } else {
    // Create new .env file with backend URL including /api prefix
    envContent = `VUE_APP_FASTAPI_URL=https://mb-api-service-production.up.railway.app/api`;
  }
  
  // Write the updated content to .env file
  fs.writeFileSync(envPath, envContent);
  
  console.log('Nuxt.js environment updated successfully!');
  console.log('Backend API URL set to: https://mb-api-service-production.up.railway.app/api');
  console.log('Now run "vercel --prod" to deploy the updated frontend');
} catch (error) {
  console.error('Error updating Nuxt.js environment:', error.message);
  process.exit(1);
}
