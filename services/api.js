import { useRuntimeConfig } from 'nuxt/app';

/**
 * Service for interacting with the backend API
 */
export default {
  /**
   * Send a chat message to the API
   * @param {string} message - The user's message
   * @returns {Promise} - Promise resolving to the API response
   */
  async sendChatMessage(message) {
    const config = useRuntimeConfig();
    const apiBaseUrl = config.public.apiBaseUrl;
    
    try {
      const response = await fetch(`${apiBaseUrl}/chat`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
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
    
    try {
      const response = await fetch(`${apiBaseUrl}/api/submit-name`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
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
