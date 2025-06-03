// update-frontend-env.js
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Updating frontend environment with Railway backend URL...');

try {
  // Frontend directory
  const frontendDir = path.join(__dirname, 'frontend');
  
  // Create or update .env file in frontend directory
  const envContent = `VUE_APP_FASTAPI_URL=https://mb-api-service-production.up.railway.app
${fs.existsSync(path.join(frontendDir, '.env')) ? fs.readFileSync(path.join(frontendDir, '.env'), 'utf8') : ''}`;
  
  // Write the updated content to .env file
  fs.writeFileSync(path.join(frontendDir, '.env'), envContent);
  
  console.log('Frontend environment updated successfully!');
  console.log('Backend URL set to: https://mb-api-service-production.up.railway.app');
  console.log('Now run "vercel --prod" from the frontend directory to deploy');
} catch (error) {
  console.error('Error updating frontend environment:', error.message);
  process.exit(1);
}
