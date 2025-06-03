// update-api-url.js
import fs from 'fs';
import path from 'path';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';

// Get current directory
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

console.log('Updating API URL to include /api prefix...');

try {
  // Load master .env
  const masterEnvPath = path.resolve(path.join(__dirname, '.env.master'));
  if (!fs.existsSync(masterEnvPath)) {
    console.error('Error: .env.master file not found!');
    process.exit(1);
  }

  console.log('Loading master environment variables...');
  const masterEnvContent = fs.readFileSync(masterEnvPath, 'utf8');
  const masterEnv = dotenv.parse(fs.readFileSync(masterEnvPath));

  // Update the BACKEND_URL to include the /api prefix
  const railwayBackendUrl = 'https://mb-api-service-production.up.railway.app/api';
  
  // Check if BACKEND_URL exists in the file
  let updatedContent;
  if (masterEnvContent.includes('BACKEND_URL=')) {
    // Replace the existing BACKEND_URL
    updatedContent = masterEnvContent.replace(
      /BACKEND_URL=.*/,
      `BACKEND_URL=${railwayBackendUrl}`
    );
  } else {
    // Add the BACKEND_URL if it doesn't exist
    updatedContent = masterEnvContent + `\nBACKEND_URL=${railwayBackendUrl}\n`;
  }

  // Write the updated content back to .env.master
  fs.writeFileSync(masterEnvPath, updatedContent);

  console.log(`Backend URL updated to: ${railwayBackendUrl}`);
  console.log('Now run "node sync-env.js" to sync the changes to frontend and backend .env files');
} catch (error) {
  console.error('Error updating backend URL:', error.message);
  process.exit(1);
}
