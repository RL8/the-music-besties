// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  devtools: { enabled: true },
  
  // Application metadata
  app: {
    head: {
      title: 'Music Besties',
      meta: [
        { charset: 'utf-8' },
        { name: 'viewport', content: 'width=device-width, initial-scale=1' },
        { hid: 'description', name: 'description', content: 'Your AI-powered music curation companion' }
      ],
      link: [
        { rel: 'icon', type: 'image/x-icon', href: '/favicon.ico' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap' }
      ]
    }
  },
  
  // CSS global styles
  css: [
    '~/assets/css/main.css'
  ],
  
  // Modules
  modules: [
    'nuxt-icon'
  ],
  
  // Runtime config for environment variables
  runtimeConfig: {
    // Private keys (server-side only)
    openaiApiKey: process.env.OPENAI_API_KEY,
    
    // Public keys (exposed to the client)
    public: {
      supabaseUrl: process.env.SUPABASE_URL,
      supabaseKey: process.env.SUPABASE_KEY,
      apiBaseUrl: process.env.API_BASE_URL || 'http://localhost:8000'
    }
  },
  
  // Build configuration
  build: {
    transpile: []
  },
  
  // Server configuration
  server: {
    port: process.env.PORT || 3000,
    host: process.env.HOST || 'localhost'
  },
  
  // Auto-import components
  components: true
})
