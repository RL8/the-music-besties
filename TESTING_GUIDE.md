# Testing Guide for The Music Besties

This guide provides a structured approach to testing The Music Besties application to ensure all components work correctly before deployment.

## Setup for Testing

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Create a Python virtual environment (if not already done):
   ```bash
   python -m venv venv
   ```

3. Activate the virtual environment:
   - Windows:
     ```bash
     venv\Scripts\activate
     ```
   - Mac/Linux:
     ```bash
     source venv/bin/activate
     ```

4. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```

5. Create a `.env` file in the backend directory with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_key
   OPENAI_API_KEY=your_openai_api_key
   FRONTEND_URL=http://localhost:3000
   ```

6. Start the backend server:
   ```bash
   uvicorn main:app --reload
   ```

### Frontend Setup

1. In a separate terminal, navigate to the project root
2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file in the project root with the following variables:
   ```
   SUPABASE_URL=your_supabase_url
   SUPABASE_KEY=your_supabase_anon_key
   API_BASE_URL=http://localhost:8000
   ```

4. Start the frontend server:
   ```bash
   npm run dev
   ```

## Test Cases

### 1. Basic Functionality Tests

#### 1.1 Backend Health Check
- Access `http://localhost:8000/health`
- Expected result: `{"status": "healthy"}`

#### 1.2 Frontend Loading
- Access `http://localhost:3000`
- Expected result: The chat interface should load with a welcome message

### 2. Authentication Flow Tests

#### 2.1 User Registration
1. In the chat interface, type "I want to register" or click the "Sign In / Register" button
2. Fill in the registration form with:
   - Username
   - Email
   - Password
3. Submit the form
4. Expected result: Success message and automatic login

#### 2.2 User Login
1. If already logged in, log out first
2. In the chat interface, type "I want to login" or click the "Sign In / Register" button
3. Switch to the login tab
4. Enter your email and password
5. Submit the form
6. Expected result: Success message and access to user features

#### 2.3 Profile Verification
1. After logging in, verify that your user profile is correctly displayed
2. Expected result: Username should be visible in the UI

### 3. Music Curation Flow Tests

#### 3.1 Artist Selection
1. In the chat interface, type "I want to curate my music" or click the "Curate Music" button
2. The Music Curation Module should appear
3. Search for an artist (e.g., "Taylor Swift", "The Beatles")
4. Select an artist from the search results
5. Expected result: Artist should be selected and the module should proceed to album selection

#### 3.2 Album Rating
1. After selecting an artist, the module should display albums
2. Select an album
3. Rate the album (1-5 stars)
4. Add a comment about the album
5. Set the importance percentage
6. Click "Save and Continue"
7. Expected result: Album rating should be saved and the module should proceed to song selection

#### 3.3 Song Rating
1. After rating an album, the module should display songs from that album
2. Select a song
3. Rate the song (1-5 stars)
4. Add a comment about the song
5. Set the importance percentage
6. Click "Save and Continue"
7. Expected result: Song rating should be saved and you should be able to continue with more songs or finish

#### 3.4 Curation Completion
1. After rating songs, click "Finish Curation"
2. Expected result: Success message and the sideboard should display your curation

### 4. Chat Interface Tests

#### 4.1 Basic Conversation
1. Type various greetings (e.g., "Hello", "Hi")
2. Expected result: AI should respond with a greeting and introduction

#### 4.2 Music-Related Queries
1. Type music-related questions (e.g., "Tell me about my music curation", "Show me my profile")
2. Expected result: AI should respond appropriately and potentially show the sideboard

#### 4.3 Contextual Buttons
1. Observe the contextual buttons that appear after AI responses
2. Click on different buttons
3. Expected result: Buttons should trigger appropriate actions (e.g., showing the curation module)

### 5. Sideboard Tests

#### 5.1 Sideboard Display
1. Type "Show me my music curation" or click a button that displays the sideboard
2. Expected result: Sideboard should expand and show your music curation

#### 5.2 Curation Content
1. Examine the content in the sideboard
2. Expected result: Your selected artist, rated albums, and rated songs should be displayed with correct ratings and comments

#### 5.3 Sideboard Toggle
1. Click the toggle button to hide the sideboard
2. Click it again to show the sideboard
3. Expected result: Sideboard should collapse and expand correctly

### 6. Database Verification Tests

#### 6.1 Profile Data
1. In the Supabase dashboard, navigate to the `profiles` table
2. Find your user record
3. Expected result: Your profile should exist with the correct username and primary_artist_id

#### 6.2 Curation Data
1. In the Supabase dashboard, navigate to the `user_curations` table
2. Filter by your user ID
3. Expected result: Your album and song ratings should be stored with correct values

### 7. Error Handling Tests

#### 7.1 Invalid Login
1. Attempt to login with incorrect credentials
2. Expected result: Error message should be displayed

#### 7.2 Network Disconnection
1. Start the application normally
2. Disconnect your internet connection
3. Try to perform actions that require API calls
4. Expected result: Appropriate error messages should be displayed

#### 7.3 Missing Fields
1. In registration or curation forms, try to submit without filling required fields
2. Expected result: Validation errors should be displayed

### 8. Responsive Design Tests

#### 8.1 Mobile View
1. Open the application in a mobile device or using browser developer tools mobile emulation
2. Test the chat interface, forms, and sideboard
3. Expected result: UI should adapt to smaller screens with appropriate layouts

#### 8.2 Tablet View
1. Test the application in tablet dimensions
2. Expected result: UI should display correctly with appropriate adaptations

#### 8.3 Desktop View
1. Test the application in desktop dimensions
2. Expected result: UI should take advantage of the larger screen space

## Test Reporting

For each test case:
1. Note whether it passed or failed
2. If failed, document:
   - The expected behavior
   - The actual behavior
   - Screenshots if applicable
   - Steps to reproduce
   - Any error messages

## Regression Testing

After fixing any issues:
1. Re-run the affected test cases
2. Verify that the fix doesn't introduce new issues
3. Run a subset of other tests to ensure no regressions

## Performance Testing (Optional)

1. Test with multiple concurrent users
2. Monitor response times for API calls
3. Check memory usage during extended use

## Security Testing (Optional)

1. Test for common vulnerabilities (XSS, CSRF)
2. Verify that authentication is required for protected endpoints
3. Ensure sensitive data is not exposed in responses

## Conclusion

This testing guide provides a comprehensive approach to verifying the functionality of The Music Besties application. By following these test cases, you can ensure that all components work correctly before deploying to production.

Remember that testing is an iterative process. As you discover and fix issues, update your test cases to include checks for those specific scenarios to prevent regression in the future.
