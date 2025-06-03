import { createClient } from '@supabase/supabase-js';
import { useRuntimeConfig } from 'nuxt/app';

/**
 * Initialize and export the Supabase client
 * This will be used for authentication and database operations
 */
export const createSupabaseClient = () => {
  const config = useRuntimeConfig();
  const supabaseUrl = config.public.supabaseUrl;
  const supabaseKey = config.public.supabaseKey;
  
  // Check if the required environment variables are set
  if (!supabaseUrl || !supabaseKey) {
    console.warn('Supabase URL or Key not provided. Please check your environment variables.');
    return null;
  }
  
  return createClient(supabaseUrl, supabaseKey, {
    auth: {
      persistSession: true,
      autoRefreshToken: true
    }
  });
};

/**
 * Singleton instance of the Supabase client
 * Use this for most operations to avoid creating multiple clients
 */
let supabaseInstance = null;

export const useSupabase = () => {
  if (!supabaseInstance) {
    supabaseInstance = createSupabaseClient();
  }
  return supabaseInstance;
};

/**
 * Authentication helper functions
 */
export const auth = {
  /**
   * Sign up a new user
   * @param {string} email - User's email
   * @param {string} password - User's password
   * @param {object} metadata - Additional user metadata
   * @returns {Promise} - Promise resolving to the signup result
   */
  signUp: async (email, password, metadata = {}) => {
    const supabase = useSupabase();
    return await supabase.auth.signUp({
      email,
      password,
      options: {
        data: metadata
      }
    });
  },

  /**
   * Sign in a user with email and password
   * @param {string} email - User's email
   * @param {string} password - User's password
   * @returns {Promise} - Promise resolving to the signin result
   */
  signIn: async (email, password) => {
    const supabase = useSupabase();
    return await supabase.auth.signInWithPassword({
      email,
      password
    });
  },

  /**
   * Sign out the current user
   * @returns {Promise} - Promise resolving to the signout result
   */
  signOut: async () => {
    const supabase = useSupabase();
    return await supabase.auth.signOut();
  },

  /**
   * Get the current user session
   * @returns {Promise} - Promise resolving to the current session
   */
  getSession: async () => {
    const supabase = useSupabase();
    return await supabase.auth.getSession();
  },

  /**
   * Get the current user
   * @returns {Promise} - Promise resolving to the current user
   */
  getUser: async () => {
    const supabase = useSupabase();
    const { data } = await supabase.auth.getUser();
    return data?.user || null;
  }
};

/**
 * Profiles helper functions
 */
export const profiles = {
  /**
   * Get a user profile by ID
   * @param {string} id - User ID
   * @returns {Promise} - Promise resolving to the user profile
   */
  getById: async (id) => {
    const supabase = useSupabase();
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', id)
      .single();
    
    if (error) throw error;
    return data;
  },

  /**
   * Update a user profile
   * @param {string} id - User ID
   * @param {object} updates - Profile updates
   * @returns {Promise} - Promise resolving to the updated profile
   */
  update: async (id, updates) => {
    const supabase = useSupabase();
    const { data, error } = await supabase
      .from('profiles')
      .update({
        ...updates,
        updated_at: new Date()
      })
      .eq('id', id);
    
    if (error) throw error;
    return data;
  },

  /**
   * Set a user's primary artist
   * @param {string} userId - User ID
   * @param {string} artistId - ID of the artist
   * @returns {Promise} - Promise resolving to the updated profile
   */
  setPrimaryArtist: async (userId, artistId) => {
    const supabase = useSupabase();
    const { data, error } = await supabase
      .from('profiles')
      .update({
        primary_artist_id: artistId,
        updated_at: new Date()
      })
      .eq('id', userId);
    
    if (error) throw error;
    return data;
  }
};

export default useSupabase;
