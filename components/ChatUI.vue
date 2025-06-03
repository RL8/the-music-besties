<template>
  <div class="chat-container">
    <div class="messages-container" ref="messagesContainer">
      <div v-for="(message, index) in messages" :key="index" class="message-wrapper">
        <div :class="['message', message.sender === 'ai' ? 'ai-message' : 'user-message']">
          <div class="message-content">{{ message.content }}</div>
          <div class="message-timestamp">{{ formatTime(message.timestamp) }}</div>
        </div>
      </div>
      <div v-if="isTyping" class="message ai-message typing-indicator">
        <span></span>
        <span></span>
        <span></span>
      </div>
    </div>
    <div class="input-container">
      <input
        type="text"
        v-model="userMessage"
        @keyup.enter="sendMessage"
        placeholder="Type a message..."
        :disabled="inputDisabled"
        class="message-input"
      />
      <button @click="sendMessage" :disabled="inputDisabled" class="send-button">
        <Icon name="heroicons:paper-airplane-solid" class="send-icon" />
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, nextTick } from 'vue';
import apiService from '~/services/api';

const props = defineProps({
  inputDisabled: {
    type: Boolean,
    default: false
  }
});

const emit = defineEmits(['message-sent']);

const userMessage = ref('');
const messages = ref([]);
const isTyping = ref(false);
const messagesContainer = ref(null);

// Add initial AI greeting when component mounts
onMounted(async () => {
  try {
    // Show loading indicator
    isTyping.value = true;
    
    // Initialize chat with the backend
    const response = await apiService.initializeChat();
    
    // Hide loading indicator
    isTyping.value = false;
    
    // Add the AI response to the chat
    if (response && response.message) {
      addMessage(response.message, 'ai');
    } else {
      // Fallback message if API call fails
      addMessage('Welcome to Music Besties! I\'m your AI concierge powered by OpenAI. How can I help you today?', 'ai');
    }
  } catch (error) {
    console.error('Error initializing chat:', error);
    isTyping.value = false;
    // Fallback message if API call fails
    addMessage('Welcome to Music Besties! I\'m your AI concierge. How can I help you today?', 'ai');
  }
});

// Watch for changes in messages and scroll to bottom
watch(messages, () => {
  scrollToBottom();
}, { deep: true });

// Watch for changes in typing indicator and scroll to bottom
watch(isTyping, () => {
  scrollToBottom();
});

// Function to add a message to the chat
function addMessage(content, sender) {
  messages.value.push({
    content,
    sender,
    timestamp: new Date()
  });
}

// Function to send a message
function sendMessage() {
  if (!userMessage.value.trim() || props.inputDisabled) return;
  
  const message = userMessage.value;
  addMessage(message, 'user');
  userMessage.value = '';
  
  // Emit event for parent component to handle
  emit('message-sent', message);
}

// Function to format timestamp
function formatTime(date) {
  return new Date(date).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
}

// Function to scroll to bottom of messages
function scrollToBottom() {
  nextTick(() => {
    if (messagesContainer.value) {
      messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
    }
  });
}

// Expose methods for parent components
defineExpose({
  addMessage,
  isTyping
});
</script>

<style scoped>
.chat-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  max-width: 800px;
  margin: 0 auto;
  background-color: #f9fafb;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
}

.messages-container {
  flex: 1;
  overflow-y: auto;
  padding: 1rem;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.message-wrapper {
  display: flex;
  flex-direction: column;
}

.message {
  max-width: 80%;
  padding: 0.75rem 1rem;
  border-radius: 1rem;
  position: relative;
  margin-bottom: 0.25rem;
}

.user-message {
  align-self: flex-end;
  background-color: #4f46e5;
  color: white;
  border-bottom-right-radius: 0.25rem;
}

.ai-message {
  align-self: flex-start;
  background-color: #e5e7eb;
  color: #1f2937;
  border-bottom-left-radius: 0.25rem;
}

.message-content {
  word-break: break-word;
}

.message-timestamp {
  font-size: 0.7rem;
  opacity: 0.7;
  margin-top: 0.25rem;
  text-align: right;
}

.input-container {
  display: flex;
  padding: 1rem;
  background-color: white;
  border-top: 1px solid #e5e7eb;
}

.message-input {
  flex: 1;
  padding: 0.75rem 1rem;
  border: 1px solid #d1d5db;
  border-radius: 9999px;
  margin-right: 0.5rem;
  font-size: 1rem;
  outline: none;
  transition: border-color 0.2s;
}

.message-input:focus {
  border-color: #4f46e5;
}

.message-input:disabled {
  background-color: #f3f4f6;
  cursor: not-allowed;
}

.send-button {
  background-color: #4f46e5;
  color: white;
  border: none;
  width: 2.5rem;
  height: 2.5rem;
  border-radius: 9999px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
  transition: background-color 0.2s;
}

.send-button:hover:not(:disabled) {
  background-color: #4338ca;
}

.send-button:disabled {
  background-color: #a5b4fc;
  cursor: not-allowed;
}

.send-icon {
  width: 1.25rem;
  height: 1.25rem;
}

/* Typing indicator */
.typing-indicator {
  display: flex;
  align-items: center;
  padding: 0.75rem 1rem;
}

.typing-indicator span {
  height: 0.5rem;
  width: 0.5rem;
  margin: 0 0.1rem;
  background-color: #9ca3af;
  border-radius: 50%;
  display: inline-block;
  animation: bounce 1.4s infinite ease-in-out both;
}

.typing-indicator span:nth-child(1) {
  animation-delay: -0.32s;
}

.typing-indicator span:nth-child(2) {
  animation-delay: -0.16s;
}

@keyframes bounce {
  0%, 80%, 100% { 
    transform: scale(0);
  } 40% { 
    transform: scale(1);
  }
}
</style>
