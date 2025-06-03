import { useRuntimeConfig } from 'nuxt/app';

/**
 * Helper function to get the authentication token from various storage locations
 * @returns {string} The authentication token
 */
function getAuthToken() {
  try {
    const config = useRuntimeConfig();
    // First try the standard format
    let token = localStorage.getItem('sb-access-token') || '';
    
    // If not found, try to get it from the Supabase storage format
    if (!token) {
      const supabaseUrl = config.public.supabaseUrl;
      if (supabaseUrl) {
        const supabaseKey = supabaseUrl.replace('https://', '').replace('.supabase.co', '');
        const supabaseData = localStorage.getItem(`sb-${supabaseKey}-auth-token`);
        if (supabaseData) {
          try {
            const parsedData = JSON.parse(supabaseData);
            token = parsedData?.access_token || '';
          } catch (e) {
            console.error('Error parsing Supabase auth data:', e);
          }
        }
      }
    }
    
    // If still no token, try other common Supabase formats
    if (!token) {
      // Try to find any key in localStorage that looks like a Supabase token
      for (let i = 0; i < localStorage.length; i++) {
        const key = localStorage.key(i);
        if (key && key.startsWith('sb-') && key.includes('-auth-token')) {
          try {
            const data = JSON.parse(localStorage.getItem(key));
            if (data && data.access_token) {
              token = data.access_token;
              break;
            }
          } catch (e) {
            // Ignore parsing errors and continue
          }
        }
      }
    }
    
    return token;
  } catch (e) {
    console.error('Error retrieving auth token:', e);
    return '';
  }
}

/**
 * Service for interacting with the backend API
 */
export default {
  /**
   * Initialize a new chat conversation
   * @returns {Promise} - Promise resolving to the initial chat response
   */
  async initializeChat() {
    const config = useRuntimeConfig();
    const apiBaseUrl = config.public.apiBaseUrl;
    
    // Get authentication token using our helper function
    const token = getAuthToken();
    
    try {
      // Make sure we're using the correct API endpoint with /api prefix
      const response = await fetch(`${apiBaseUrl}/api/chat/init`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        }
      });
      
      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error initializing chat:', error);
      throw error;
    }
  },
  
  /**
   * Send a chat message to the API
   * @param {string} message - The user's message
   * @returns {Promise} - Promise resolving to the API response
   */
  async sendChatMessage(message) {
    const config = useRuntimeConfig();
    const apiBaseUrl = config.public.apiBaseUrl;
    
    // Get authentication token using our helper function
    const token = getAuthToken();
    
    try {
      // Make sure we're using the correct API endpoint with /api prefix
      const response = await fetch(`${apiBaseUrl}/api/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ message }),
      });
      
      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error sending chat message:', error);
      throw error;
    }
  },
  
  /**
   * Submit user's name to the API
   * @param {string} name - The user's name
   * @returns {Promise} - Promise resolving to the API response
   */
  async submitName(name) {
    const config = useRuntimeConfig();
    const apiBaseUrl = config.public.apiBaseUrl;
    
    // Get authentication token using our helper function
    const token = getAuthToken();
    
    try {
      const response = await fetch(`${apiBaseUrl}/api/submit-name`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: JSON.stringify({ name }),
      });
      
      if (!response.ok) {
        throw new Error(`API error: ${response.status}`);
      }
      
      return await response.json();
    } catch (error) {
      console.error('Error submitting name:', error);
      throw error;
    }
  }
};
