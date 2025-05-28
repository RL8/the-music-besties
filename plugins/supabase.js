import { createSupabaseClient } from '~/services/supabase';

export default defineNuxtPlugin(nuxtApp => {
  const supabase = createSupabaseClient();
  
  // Make Supabase available throughout the app
  nuxtApp.provide('supabase', supabase);
});
