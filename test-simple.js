/**
 * Simple test script for The Music Besties application
 */

import { execSync } from 'child_process';
import { createInterface } from 'readline';
import { promises as fs } from 'fs';
import { dirname, join } from 'path';
import { fileURLToPath } from 'url';

// Get current directory
const __dirname = dirname(fileURLToPath(import.meta.url));

// Create readline interface
const rl = createInterface({
  input: process.stdin,
  output: process.stdout
});

// ANSI color codes
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  cyan: '\x1b[36m'
};

// Configuration
const config = {
  backendUrl: 'http://localhost:8000',
  frontendUrl: 'http://localhost:3000'
};

/**
 * Main function
 */
async function main() {
  console.log(`${colors.cyan}${colors.bright}=== THE MUSIC BESTIES TEST SCRIPT ===${colors.reset}\n`);
  console.log(`${colors.cyan}This script will test the core functionality of your application.${colors.reset}\n`);

  // Check environment files
  await checkEnvironment();
  
  // Test backend
  await testBackend();
  
  // Test frontend
  await testFrontend();
  
  // Completion
  console.log(`\n${colors.green}${colors.bright}Testing completed!${colors.reset}`);
  console.log(`${colors.cyan}You can now continue with development or deployment.${colors.reset}`);
  
  rl.close();
}

/**
 * Check environment setup
 */
async function checkEnvironment() {
  console.log(`${colors.blue}${colors.bright}[ Environment Check ]${colors.reset}`);
  
  try {
    // Check if .env.master exists
    try {
      await fs.access(join(__dirname, '.env.master'));
      console.log(`${colors.green}✓ .env.master file found${colors.reset}`);
    } catch (error) {
      console.log(`${colors.yellow}⚠ .env.master file not found${colors.reset}`);
      console.log(`${colors.yellow}  Create one based on env-master-template.txt${colors.reset}`);
    }
    
    // Check if backend directory exists
    try {
      await fs.access(join(__dirname, 'backend'));
      console.log(`${colors.green}✓ Backend directory found${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Backend directory not found${colors.reset}`);
    }
    
    // Check if components directory exists
    try {
      await fs.access(join(__dirname, 'components'));
      console.log(`${colors.green}✓ Components directory found${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Components directory not found${colors.reset}`);
    }
  } catch (error) {
    console.log(`${colors.red}Error checking environment: ${error.message}${colors.reset}`);
  }
}

/**
 * Test backend
 */
async function testBackend() {
  console.log(`\n${colors.blue}${colors.bright}[ Backend Test ]${colors.reset}`);
  
  // Check if backend is running
  console.log(`${colors.yellow}Checking if backend is running...${colors.reset}`);
  
  let backendRunning = false;
  try {
    execSync(`curl -s ${config.backendUrl}/health`, { stdio: 'ignore' });
    backendRunning = true;
    console.log(`${colors.green}✓ Backend is running at ${config.backendUrl}${colors.reset}`);
  } catch (error) {
    console.log(`${colors.yellow}⚠ Backend is not running${colors.reset}`);
    console.log(`${colors.yellow}  Start it with: cd backend && uvicorn main:app --reload${colors.reset}`);
  }
  
  if (backendRunning) {
    // Test health endpoint
    try {
      const healthOutput = execSync(`curl -s ${config.backendUrl}/health`).toString();
      console.log(`${colors.green}✓ Health endpoint response: ${healthOutput}${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Health endpoint test failed${colors.reset}`);
    }
    
    // Test root endpoint
    try {
      const rootOutput = execSync(`curl -s ${config.backendUrl}/`).toString();
      console.log(`${colors.green}✓ Root endpoint response: ${rootOutput}${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Root endpoint test failed${colors.reset}`);
    }
  }
}

/**
 * Test frontend
 */
async function testFrontend() {
  console.log(`\n${colors.blue}${colors.bright}[ Frontend Test ]${colors.reset}`);
  
  // Check if frontend is running
  console.log(`${colors.yellow}Checking if frontend is running...${colors.reset}`);
  
  try {
    execSync(`curl -s ${config.frontendUrl}`, { stdio: 'ignore' });
    console.log(`${colors.green}✓ Frontend is running at ${config.frontendUrl}${colors.reset}`);
    
    console.log(`\n${colors.cyan}Manual testing steps:${colors.reset}`);
    console.log(`1. Open ${config.frontendUrl} in your browser`);
    console.log(`2. Test user authentication (registration and login)`);
    console.log(`3. Test music curation flow (artist, album, and song selection)`);
    console.log(`4. Verify that the sideboard displays the user's music curation`);
  } catch (error) {
    console.log(`${colors.yellow}⚠ Frontend is not running${colors.reset}`);
    console.log(`${colors.yellow}  Start it with: npm run dev${colors.reset}`);
  }
}

// Run the main function
main().catch(error => {
  console.error(`${colors.red}Error: ${error.message}${colors.reset}`);
  rl.close();
});
