/**
 * Test script for The Music Besties application
 * 
 * This script helps test the core functionality of the application:
 * 1. Backend API endpoints
 * 2. Supabase connection
 * 3. Frontend components
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';
import readline from 'readline';
import { fileURLToPath } from 'url';

// Get current directory equivalent to __dirname in CommonJS
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Create readline interface for user input
const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// ANSI color codes for console output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  dim: '\x1b[2m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m'
};

// Test configuration
const config = {
  backendPort: 8000,
  frontendPort: 3000,
  backendUrl: 'http://localhost:8000',
  frontendUrl: 'http://localhost:3000',
  envFile: '.env.master',
  requiredEnvVars: ['SUPABASE_URL', 'SUPABASE_KEY', 'OPENAI_API_KEY']
};

/**
 * Main test function
 */
async function runTests() {
  printHeader('THE MUSIC BESTIES TEST SCRIPT');
  console.log(`${colors.cyan}This script will help test the core functionality of your application.${colors.reset}\n`);

  // Check environment setup
  await checkEnvironment();
  
  // Test backend
  await testBackend();
  
  // Test frontend
  await testFrontend();
  
  // Final summary
  printTestSummary();
  
  rl.close();
}

/**
 * Check environment setup
 */
async function checkEnvironment() {
  printSection('Environment Setup');
  
  // Check if .env.master exists
  const envExists = fs.existsSync(path.join(process.cwd(), config.envFile));
  if (envExists) {
    console.log(`${colors.green}✓ ${config.envFile} file found${colors.reset}`);
    
    // Check required environment variables
    const envContent = fs.readFileSync(path.join(process.cwd(), config.envFile), 'utf8');
    let missingVars = [];
    
    for (const envVar of config.requiredEnvVars) {
      if (!envContent.includes(`${envVar}=`) || envContent.includes(`${envVar}=your_`)) {
        missingVars.push(envVar);
      }
    }
    
    if (missingVars.length > 0) {
      console.log(`${colors.red}✗ Missing or incomplete environment variables: ${missingVars.join(', ')}${colors.reset}`);
      console.log(`${colors.yellow}Please update your ${config.envFile} file with the required values.${colors.reset}`);
      
      const proceed = await askQuestion('Do you want to continue anyway? (y/n): ');
      if (proceed.toLowerCase() !== 'y') {
        process.exit(1);
      }
    } else {
      console.log(`${colors.green}✓ All required environment variables are set${colors.reset}`);
    }
  } else {
    console.log(`${colors.red}✗ ${config.envFile} file not found${colors.reset}`);
    console.log(`${colors.yellow}Please create a ${config.envFile} file based on env-master-template.txt${colors.reset}`);
    
    const proceed = await askQuestion('Do you want to continue anyway? (y/n): ');
    if (proceed.toLowerCase() !== 'y') {
      process.exit(1);
    }
  }
  
  // Check if node_modules exists
  const nodeModulesExists = fs.existsSync(path.join(process.cwd(), 'node_modules'));
  if (nodeModulesExists) {
    console.log(`${colors.green}✓ node_modules found${colors.reset}`);
  } else {
    console.log(`${colors.red}✗ node_modules not found${colors.reset}`);
    console.log(`${colors.yellow}Running npm install...${colors.reset}`);
    
    try {
      execSync('npm install', { stdio: 'inherit' });
      console.log(`${colors.green}✓ npm install completed successfully${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ npm install failed${colors.reset}`);
      process.exit(1);
    }
  }
  
  // Check if Python virtual environment exists
  const venvExists = fs.existsSync(path.join(process.cwd(), 'backend', 'venv'));
  if (venvExists) {
    console.log(`${colors.green}✓ Python virtual environment found${colors.reset}`);
  } else {
    console.log(`${colors.yellow}Python virtual environment not found. Would you like to create one?${colors.reset}`);
    
    const createVenv = await askQuestion('Create Python virtual environment? (y/n): ');
    if (createVenv.toLowerCase() === 'y') {
      console.log(`${colors.yellow}Creating Python virtual environment...${colors.reset}`);
      
      try {
        execSync('cd backend && python -m venv venv', { stdio: 'inherit' });
        console.log(`${colors.green}✓ Python virtual environment created successfully${colors.reset}`);
        
        // Install backend dependencies
        console.log(`${colors.yellow}Installing backend dependencies...${colors.reset}`);
        
        if (process.platform === 'win32') {
          execSync('cd backend && .\\venv\\Scripts\\activate && pip install -r requirements.txt', { stdio: 'inherit' });
        } else {
          execSync('cd backend && source venv/bin/activate && pip install -r requirements.txt', { stdio: 'inherit' });
        }
        
        console.log(`${colors.green}✓ Backend dependencies installed successfully${colors.reset}`);
      } catch (error) {
        console.log(`${colors.red}✗ Failed to create Python virtual environment or install dependencies${colors.reset}`);
        console.log(`${colors.yellow}Please create it manually:${colors.reset}`);
        console.log(`cd backend && python -m venv venv`);
        console.log(`cd backend && .\\venv\\Scripts\\activate && pip install -r requirements.txt (Windows)`);
        console.log(`cd backend && source venv/bin/activate && pip install -r requirements.txt (Mac/Linux)`);
      }
    }
  }
}

/**
 * Test backend functionality
 */
async function testBackend() {
  printSection('Backend Tests');
  
  // Check if backend is running
  console.log(`${colors.yellow}Checking if backend is running...${colors.reset}`);
  
  let backendRunning = false;
  try {
    execSync(`curl -s ${config.backendUrl}/health`, { stdio: 'ignore' });
    backendRunning = true;
  } catch (error) {
    backendRunning = false;
  }
  
  if (backendRunning) {
    console.log(`${colors.green}✓ Backend is running at ${config.backendUrl}${colors.reset}`);
  } else {
    console.log(`${colors.red}✗ Backend is not running${colors.reset}`);
    console.log(`${colors.yellow}Would you like to start the backend?${colors.reset}`);
    
    const startBackend = await askQuestion('Start backend server? (y/n): ');
    if (startBackend.toLowerCase() === 'y') {
      console.log(`${colors.yellow}Starting backend server...${colors.reset}`);
      console.log(`${colors.cyan}The backend will run in a separate terminal window.${colors.reset}`);
      
      try {
        if (process.platform === 'win32') {
          // For Windows, open a new Command Prompt window
          execSync('start cmd.exe /K "cd backend && .\\venv\\Scripts\\activate && uvicorn main:app --reload"');
        } else {
          // For Mac/Linux, open a new terminal window
          execSync('gnome-terminal -- bash -c "cd backend && source venv/bin/activate && uvicorn main:app --reload; exec bash" || ' +
                   'xterm -e "cd backend && source venv/bin/activate && uvicorn main:app --reload; exec bash" || ' +
                   'open -a Terminal.app backend && source venv/bin/activate && uvicorn main:app --reload"');
        }
        
        console.log(`${colors.green}✓ Backend server started in a new terminal window${colors.reset}`);
        console.log(`${colors.yellow}Waiting for backend to be ready...${colors.reset}`);
        
        // Wait for backend to be ready
        let attempts = 0;
        const maxAttempts = 10;
        
        while (attempts < maxAttempts) {
          try {
            execSync(`curl -s ${config.backendUrl}/health`, { stdio: 'ignore' });
            console.log(`${colors.green}✓ Backend is now running at ${config.backendUrl}${colors.reset}`);
            backendRunning = true;
            break;
          } catch (error) {
            process.stdout.write('.');
            await new Promise(resolve => setTimeout(resolve, 1000));
            attempts++;
          }
        }
        
        if (!backendRunning) {
          console.log(`\n${colors.red}✗ Backend did not start successfully${colors.reset}`);
          console.log(`${colors.yellow}Please check the backend terminal for errors.${colors.reset}`);
        }
      } catch (error) {
        console.log(`${colors.red}✗ Failed to start backend server${colors.reset}`);
        console.log(`${colors.yellow}Please start it manually:${colors.reset}`);
        console.log(`cd backend && .\\venv\\Scripts\\activate && uvicorn main:app --reload (Windows)`);
        console.log(`cd backend && source venv/bin/activate && uvicorn main:app --reload (Mac/Linux)`);
      }
    }
  }
  
  // Test backend endpoints
  if (backendRunning) {
    console.log(`\n${colors.yellow}Testing backend endpoints...${colors.reset}`);
    
    // Test health endpoint
    try {
      const healthOutput = execSync(`curl -s ${config.backendUrl}/health`).toString();
      console.log(`${colors.green}✓ Health endpoint: ${healthOutput}${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Health endpoint test failed${colors.reset}`);
    }
    
    // Test root endpoint
    try {
      const rootOutput = execSync(`curl -s ${config.backendUrl}/`).toString();
      console.log(`${colors.green}✓ Root endpoint: ${rootOutput}${colors.reset}`);
    } catch (error) {
      console.log(`${colors.red}✗ Root endpoint test failed${colors.reset}`);
    }
    
    // Test chat init endpoint
    try {
      const chatInitOutput = execSync(`curl -s -X POST ${config.backendUrl}/api/chat/init`).toString();
      const chatInitJson = JSON.parse(chatInitOutput);
      
      if (chatInitJson.message && chatInitJson.message.content) {
        console.log(`${colors.green}✓ Chat init endpoint: Success${colors.reset}`);
        console.log(`${colors.dim}  Response: "${chatInitJson.message.content.substring(0, 50)}..."${colors.reset}`);
      } else {
        console.log(`${colors.red}✗ Chat init endpoint: Invalid response format${colors.reset}`);
      }
    } catch (error) {
      console.log(`${colors.red}✗ Chat init endpoint test failed: ${error.message}${colors.reset}`);
    }
  }
}

/**
 * Test frontend functionality
 */
async function testFrontend() {
  printSection('Frontend Tests');
  
  // Check if frontend is running
  console.log(`${colors.yellow}Checking if frontend is running...${colors.reset}`);
  
  let frontendRunning = false;
  try {
    execSync(`curl -s ${config.frontendUrl}`, { stdio: 'ignore' });
    frontendRunning = true;
  } catch (error) {
    frontendRunning = false;
  }
  
  if (frontendRunning) {
    console.log(`${colors.green}✓ Frontend is running at ${config.frontendUrl}${colors.reset}`);
  } else {
    console.log(`${colors.red}✗ Frontend is not running${colors.reset}`);
    console.log(`${colors.yellow}Would you like to start the frontend?${colors.reset}`);
    
    const startFrontend = await askQuestion('Start frontend server? (y/n): ');
    if (startFrontend.toLowerCase() === 'y') {
      console.log(`${colors.yellow}Starting frontend server...${colors.reset}`);
      console.log(`${colors.cyan}The frontend will run in a separate terminal window.${colors.reset}`);
      
      try {
        if (process.platform === 'win32') {
          // For Windows, open a new Command Prompt window
          execSync('start cmd.exe /K "npm run dev"');
        } else {
          // For Mac/Linux, open a new terminal window
          execSync('gnome-terminal -- bash -c "npm run dev; exec bash" || ' +
                   'xterm -e "npm run dev; exec bash" || ' +
                   'open -a Terminal.app "npm run dev"');
        }
        
        console.log(`${colors.green}✓ Frontend server started in a new terminal window${colors.reset}`);
        console.log(`${colors.yellow}Waiting for frontend to be ready...${colors.reset}`);
        
        // Wait for frontend to be ready
        let attempts = 0;
        const maxAttempts = 20;
        
        while (attempts < maxAttempts) {
          try {
            execSync(`curl -s ${config.frontendUrl}`, { stdio: 'ignore' });
            console.log(`${colors.green}✓ Frontend is now running at ${config.frontendUrl}${colors.reset}`);
            frontendRunning = true;
            break;
          } catch (error) {
            process.stdout.write('.');
            await new Promise(resolve => setTimeout(resolve, 1000));
            attempts++;
          }
        }
        
        if (!frontendRunning) {
          console.log(`\n${colors.red}✗ Frontend did not start successfully${colors.reset}`);
          console.log(`${colors.yellow}Please check the frontend terminal for errors.${colors.reset}`);
        }
      } catch (error) {
        console.log(`${colors.red}✗ Failed to start frontend server${colors.reset}`);
        console.log(`${colors.yellow}Please start it manually:${colors.reset}`);
        console.log(`npm run dev`);
      }
    }
  }
  
  if (frontendRunning) {
    console.log(`\n${colors.yellow}Frontend is running. Please open ${config.frontendUrl} in your browser to test the application.${colors.reset}`);
    console.log(`${colors.cyan}Manual testing steps:${colors.reset}`);
    console.log(`1. Verify that the chat interface loads correctly`);
    console.log(`2. Test user authentication (registration and login)`);
    console.log(`3. Test music curation flow (artist, album, and song selection)`);
    console.log(`4. Verify that the sideboard displays the user's music curation`);
    
    await askQuestion('\nPress Enter when you have completed the manual testing steps...');
  }
}

/**
 * Print final test summary
 */
function printTestSummary() {
  printSection('Test Summary');
  
  console.log(`${colors.green}${colors.bright}Testing completed!${colors.reset}`);
  console.log(`\n${colors.cyan}Next steps:${colors.reset}`);
  console.log(`1. Fix any issues identified during testing`);
  console.log(`2. Continue development of additional features`);
  console.log(`3. Prepare for deployment`);
  
  console.log(`\n${colors.yellow}For deployment, you'll need to:${colors.reset}`);
  console.log(`- Set up environment variables on your hosting platform`);
  console.log(`- Configure your database with the correct schema`);
  console.log(`- Set up authentication providers`);
  
  console.log(`\n${colors.magenta}${colors.bright}Thank you for using the test script!${colors.reset}`);
}

/**
 * Helper function to print a section header
 */
function printHeader(text) {
  const separator = '='.repeat(text.length + 8);
  console.log(`\n${colors.cyan}${separator}${colors.reset}`);
  console.log(`${colors.cyan}=== ${colors.bright}${text}${colors.reset} ${colors.cyan}===${colors.reset}`);
  console.log(`${colors.cyan}${separator}${colors.reset}\n`);
}

/**
 * Helper function to print a section title
 */
function printSection(text) {
  console.log(`\n${colors.bright}${colors.blue}[ ${text} ]${colors.reset}`);
  console.log(`${colors.blue}${'─'.repeat(text.length + 4)}${colors.reset}`);
}

/**
 * Helper function to ask a question and get user input
 */
function askQuestion(question) {
  return new Promise(resolve => {
    rl.question(question, answer => {
      resolve(answer);
    });
  });
}

// Run the tests
runTests();
