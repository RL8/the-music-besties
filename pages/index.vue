<template>
  <div class="app-container">
    <ChatInterface />
  </div>
</template>

<script setup>
import ChatInterface from '~/components/ChatInterface.vue';
</script>

<style>
html, body {
  margin: 0;
  padding: 0;
  height: 100%;
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  background-color: #f9fafb;
  color: #1f2937;
}

.app-container {
  height: 100vh;
  width: 100%;
  max-width: 100%;
  margin: 0 auto;
  overflow: hidden;
}

/* Global styles */
* {
  box-sizing: border-box;
}

a {
  color: #4f46e5;
  text-decoration: none;
}

a:hover {
  text-decoration: underline;
}

button {
  cursor: pointer;
}

button:disabled {
  cursor: not-allowed;
  opacity: 0.7;
}

/* For mobile devices */
@media (max-width: 768px) {
  .app-container {
    padding: 0;
  }
}
</style>
