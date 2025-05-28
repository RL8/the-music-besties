<template>
  <div class="app-container">
    <header class="app-header">
      <h1>The Music Besties</h1>
    </header>
    
    <main class="app-main">
      <div class="chat-section">
        <ChatUI 
          ref="chatUI" 
          :input-disabled="isInputModuleActive" 
          @message-sent="handleMessageSent" 
        />
      </div>
      
      <div class="sideboard-section">
        <Sideboard ref="sideboard" title="Your Music Journey" />
      </div>
    </main>
    
    <Teleport to="body">
      <ContextualInputModule
        v-if="isInputModuleActive"
        :title="inputModule.title"
        :description="inputModule.description"
        :input-type="inputModule.inputType"
        :label="inputModule.label"
        :placeholder="inputModule.placeholder"
        :required="inputModule.required"
        :component-type="inputModule.componentType"
        :submit-button-text="inputModule.submitButtonText"
        @submit="handleInputSubmit"
        @cancel="handleInputCancel"
      />
    </Teleport>
  </div>
</template>

<script setup>
import { ref, onMounted, markRaw } from 'vue';
import WelcomeDisplay from '~/components/WelcomeDisplay.vue';
import apiService from '~/services/api';

// References to child components
const chatUI = ref(null);
const sideboard = ref(null);

// Input module state
const isInputModuleActive = ref(false);
const inputModule = ref({
  title: '',
  description: '',
  inputType: 'text',
  label: '',
  placeholder: '',
  required: true,
  componentType: '',
  submitButtonText: 'Save'
});

// User data
const userData = ref({
  name: ''
});

// Handle message sent from chat
async function handleMessageSent(message) {
  try {
    // Show typing indicator
    chatUI.value.isTyping = true;
    
    // Call the backend API
    const response = await apiService.sendChatMessage(message);
    
    // Hide typing indicator
    chatUI.value.isTyping = false;
    
    // Add AI response to chat
    chatUI.value.addMessage(response.message, 'ai');
    
    // Handle component trigger if present
    if (response.component_trigger) {
      handleComponentTrigger(response.component_trigger);
    }
  } catch (error) {
    console.error('Error handling message:', error);
    chatUI.value.isTyping = false;
    chatUI.value.addMessage('Sorry, I encountered an error. Please try again.', 'ai');
  }
}

// Handle component trigger from API
function handleComponentTrigger(trigger) {
  if (trigger.component_type === 'name_input_form' || 
      trigger.component_type === 'contextual_input_module') {
    // Show input module
    inputModule.value = {
      title: trigger.data.title || 'Input Required',
      description: trigger.data.description || '',
      inputType: trigger.data.input_type || 'text',
      label: trigger.data.label || '',
      placeholder: trigger.data.placeholder || '',
      required: trigger.data.required !== undefined ? trigger.data.required : true,
      componentType: trigger.component_type,
      submitButtonText: trigger.data.submit_button_text || 'Save'
    };
    isInputModuleActive.value = true;
  } else if (trigger.component_type === 'sideboard_welcome_display') {
    // Show welcome display in sideboard
    sideboard.value.setContent(markRaw(WelcomeDisplay), { name: trigger.data.name });
  }
}

// Handle input submission
async function handleInputSubmit(data) {
  isInputModuleActive.value = false;
  
  try {
    if (data.componentType === 'name_input_form' || 
        data.componentType === 'contextual_input_module') {
      // Store name in user data
      userData.value.name = data.value;
      
      // Show typing indicator
      chatUI.value.isTyping = true;
      
      // Submit name to backend
      const response = await apiService.submitName(data.value);
      
      // Hide typing indicator
      chatUI.value.isTyping = false;
      
      // Add AI response to chat
      chatUI.value.addMessage(response.message, 'ai');
      
      // Handle component trigger if present
      if (response.component_trigger) {
        handleComponentTrigger(response.component_trigger);
      }
    }
  } catch (error) {
    console.error('Error submitting input:', error);
    chatUI.value.isTyping = false;
    chatUI.value.addMessage('Sorry, I encountered an error processing your input. Please try again.', 'ai');
  }
}

// Handle input cancellation
function handleInputCancel() {
  isInputModuleActive.value = false;
  chatUI.value.addMessage("No problem, you can share your name later if you'd like.", 'ai');
}

// Initial greeting when app loads
onMounted(() => {
  // The initial greeting is already handled by the ChatUI component
});
</script>

<style>
/* Global styles */
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  color: #1f2937;
  background-color: #f3f4f6;
}

.app-container {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}

.app-header {
  padding: 1rem 0;
  text-align: center;
  margin-bottom: 1rem;
}

.app-header h1 {
  font-size: 1.75rem;
  color: #4f46e5;
  font-weight: 700;
}

.app-main {
  display: flex;
  flex-direction: column;
  flex: 1;
  gap: 1rem;
}

.chat-section {
  flex: 1;
  min-height: 60vh;
}

.sideboard-section {
  width: 100%;
}

/* Responsive layout for larger screens */
@media (min-width: 768px) {
  .app-main {
    flex-direction: row;
  }
  
  .chat-section {
    flex: 2;
  }
  
  .sideboard-section {
    flex: 1;
  }
}
</style>
