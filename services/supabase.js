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
  
  return createClient(supabaseUrl, supabaseKey);
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

export default useSupabase;
