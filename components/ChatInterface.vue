<template>
  <div class="chat-interface">
    <div class="chat-header">
      <h2>{{ chatTitle }}</h2>
    </div>
    
    <div class="chat-container">
      <!-- Main Chat Area -->
      <div class="chat-messages" ref="messagesContainer">
        <div v-for="(message, index) in messages" :key="index" 
          :class="['message-wrapper', message.sender === 'user' ? 'user-message' : 'ai-message']">
          
          <!-- Regular message -->
          <div v-if="!message.hasCIM" class="message-content">
            <div class="message-bubble">
              <p v-html="formatMessage(message.content)"></p>
            </div>
            <div class="message-timestamp">{{ formatTime(message.timestamp) }}</div>
          </div>
          
          <!-- Message with Contextual Input Module -->
          <div v-else class="message-with-cim">
            <div class="message-bubble">
              <p v-html="formatMessage(message.content)"></p>
            </div>
            <div class="message-timestamp">{{ formatTime(message.timestamp) }}</div>
            
            <div class="cim-container">
              <component 
                v-if="message.cimComponent" 
                :is="message.cimComponent"
                v-bind="message.cimProps"
                @submit="handleCIMSubmit($event, message)"
                @cancel="handleCIMCancel(message)"
                @complete="handleCIMComplete($event, message)"
                @skip="handleCIMSkip(message)"
              />
            </div>
          </div>
        </div>
        
        <!-- Typing indicator when AI is responding -->
        <div v-if="isAiTyping" class="typing-indicator">
          <div class="dot"></div>
          <div class="dot"></div>
          <div class="dot"></div>
        </div>
      </div>
      
      <!-- Sideboard (right panel) -->
      <div class="sideboard-container" :class="{ 'expanded': isSideboardExpanded }">
        <div class="sideboard-toggle" @click="toggleSideboard">
          <span v-if="isSideboardExpanded">Hide Sideboard</span>
          <span v-else>Show Sideboard</span>
          <Icon :name="isSideboardExpanded ? 'heroicons:chevron-right' : 'heroicons:chevron-left'" />
        </div>
        
        <Sideboard 
          ref="sideboard"
          :title="sideboardTitle"
        />
      </div>
    </div>
    
    <!-- Input Area -->
    <div class="chat-input-area" v-if="!activeContextualInput">
      <textarea 
        v-model="userInput" 
        placeholder="Type your message..." 
        @keydown.enter.prevent="sendMessage"
        :disabled="isAiTyping"
        ref="inputField"
      ></textarea>
      <button @click="sendMessage" :disabled="!userInput.trim() || isAiTyping" class="send-button">
        <Icon name="heroicons:paper-airplane" />
      </button>
    </div>
    
    <!-- Contextual Input Buttons (when AI provides options) -->
    <div class="contextual-buttons" v-if="contextualButtons.length > 0 && !activeContextualInput">
      <button 
        v-for="(button, index) in contextualButtons" 
        :key="index"
        @click="handleContextualButton(button)"
        class="contextual-button"
      >
        {{ button.label }}
      </button>
    </div>
  </div>
</template>

<script>
import { useSupabase } from '~/services/supabase';
import { ref, onMounted, nextTick, computed } from 'vue';
import MusicCurationModule from './MusicCurationModule.vue';
import MusicCurationDisplay from './MusicCurationDisplay.vue';
import AuthForm from './AuthForm.vue';

export default {
  name: 'ChatInterface',
  components: {
    MusicCurationModule,
    MusicCurationDisplay,
    AuthForm
  },
  props: {
    initialMessages: {
      type: Array,
      default: () => []
    },
    chatTitle: {
      type: String,
      default: 'Music Besties'
    },
    sideboardTitle: {
      type: String,
      default: 'Your Music Curation'
    }
  },
  setup(props) {
    // State
    const messages = ref(props.initialMessages.length > 0 ? props.initialMessages : []);
    const userInput = ref('');
    const isAiTyping = ref(false);
    const contextualButtons = ref([]);
    const activeContextualInput = ref(null);
    const isSideboardExpanded = ref(false);
    const messagesContainer = ref(null);
    const inputField = ref(null);
    const sideboard = ref(null);
    const supabase = useSupabase();
    const currentUser = ref(null);
    
    // Check if user is authenticated
    const isAuthenticated = computed(() => {
      return !!currentUser.value;
    });
    
    // Load current user
    const loadCurrentUser = async () => {
      try {
        const { data } = await supabase.auth.getUser();
        if (data?.user) {
          currentUser.value = data.user;
          
          // Get user profile
          const { data: profileData } = await supabase
            .from('profiles')
            .select('*')
            .eq('id', currentUser.value.id)
            .single();
            
          if (profileData) {
            currentUser.value.profile = profileData;
            
            // If user has a primary artist, show their curation in the sideboard
            if (profileData.primary_artist_id) {
              showMusicCurationInSideboard();
            }
          }
        }
      } catch (error) {
        console.error('Error loading current user:', error);
      }
    };
    
    // Send a message to the AI
    const sendMessage = async () => {
      if (!userInput.value.trim() || isAiTyping.value) return;
      
      // Add user message to chat
      const userMessage = {
        content: userInput.value,
        sender: 'user',
        timestamp: new Date(),
        hasCIM: false
      };
      
      messages.value.push(userMessage);
      
      // Clear input and scroll to bottom
      const input = userInput.value;
      userInput.value = '';
      scrollToBottom();
      
      // Set AI typing indicator
      isAiTyping.value = true;
      
      try {
        // In a real implementation, this would call the backend AI service
        // For now, we'll simulate AI responses based on user input
        await simulateAiResponse(input);
      } catch (error) {
        console.error('Error getting AI response:', error);
        
        // Add error message
        messages.value.push({
          content: 'Sorry, I encountered an error. Please try again.',
          sender: 'ai',
          timestamp: new Date(),
          hasCIM: false
        });
      } finally {
        isAiTyping.value = false;
        scrollToBottom();
        
        // Focus input field
        nextTick(() => {
          if (inputField.value) {
            inputField.value.focus();
          }
        });
      }
    };
    
    // Simulate AI response based on user input
    const simulateAiResponse = async (userInput) => {
      // Wait a moment to simulate AI thinking
      await new Promise(resolve => setTimeout(resolve, 1000));
      
      const lowercaseInput = userInput.toLowerCase();
      
      // Check for authentication-related queries
      if (lowercaseInput.includes('sign') || lowercaseInput.includes('register') || 
          lowercaseInput.includes('log in') || lowercaseInput.includes('login') || 
          lowercaseInput.includes('account')) {
        
        if (!isAuthenticated.value) {
          // Show authentication form
          messages.value.push({
            content: "Let's get you set up with an account so you can start curating your music obsession!",
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: true,
            cimComponent: 'AuthForm',
            cimProps: {}
          });
        } else {
          // User is already authenticated
          messages.value.push({
            content: `You're already logged in as ${currentUser.value.email}. What would you like to do next?`,
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: false
          });
        }
        return;
      }
      
      // Check for music curation related queries
      if ((lowercaseInput.includes('music') || lowercaseInput.includes('artist') || 
           lowercaseInput.includes('song') || lowercaseInput.includes('album') ||
           lowercaseInput.includes('favorite') || lowercaseInput.includes('obsession')) && 
          (lowercaseInput.includes('add') || lowercaseInput.includes('set') || 
           lowercaseInput.includes('curate') || lowercaseInput.includes('tell'))) {
        
        if (!isAuthenticated.value) {
          // Prompt user to authenticate first
          messages.value.push({
            content: "Before we can curate your music obsession, you'll need to sign in or create an account.",
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: false
          });
          
          contextualButtons.value = [
            { label: 'Sign In / Register', action: 'auth' }
          ];
        } else {
          // Show music curation module
          messages.value.push({
            content: "Great! Let's curate your music obsession. Tell me about your favorite artist.",
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: true,
            cimComponent: 'MusicCurationModule',
            cimProps: {
              userId: currentUser.value.id,
              title: 'Music Curation',
              description: 'Let\'s find your music obsession!'
            }
          });
        }
        return;
      }
      
      // Check for viewing curation
      if (lowercaseInput.includes('view') || lowercaseInput.includes('show') || 
          lowercaseInput.includes('see') || lowercaseInput.includes('my')) {
        
        if (lowercaseInput.includes('curation') || lowercaseInput.includes('music') || 
            lowercaseInput.includes('artist') || lowercaseInput.includes('profile')) {
          
          if (!isAuthenticated.value) {
            // Prompt user to authenticate first
            messages.value.push({
              content: "You'll need to sign in first to view your music curation.",
              sender: 'ai',
              timestamp: new Date(),
              hasCIM: false
            });
            
            contextualButtons.value = [
              { label: 'Sign In / Register', action: 'auth' }
            ];
          } else {
            // Show curation in sideboard
            messages.value.push({
              content: "I've opened your music curation in the sideboard. Take a look!",
              sender: 'ai',
              timestamp: new Date(),
              hasCIM: false
            });
            
            showMusicCurationInSideboard();
          }
          return;
        }
      }
      
      // Default response
      messages.value.push({
        content: "I'm your AI concierge for music curation. I can help you curate your music obsession, find your music tribe, and connect with others who share your taste. What would you like to do?",
        sender: 'ai',
        timestamp: new Date(),
        hasCIM: false
      });
      
      // Add contextual buttons for common actions
      contextualButtons.value = [
        { label: 'Curate My Music', action: 'curate' },
        { label: 'View My Profile', action: 'view-profile' }
      ];
    };
    
    // Handle contextual button clicks
    const handleContextualButton = (button) => {
      switch (button.action) {
        case 'auth':
          // Show authentication form
          messages.value.push({
            content: "Let's get you set up with an account.",
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: true,
            cimComponent: 'AuthForm',
            cimProps: {}
          });
          break;
          
        case 'curate':
          // Simulate user asking to curate music
          userInput.value = "I want to curate my music obsession";
          sendMessage();
          break;
          
        case 'view-profile':
          // Simulate user asking to view profile
          userInput.value = "Show me my music curation";
          sendMessage();
          break;
          
        default:
          console.warn('Unknown button action:', button.action);
      }
      
      // Clear contextual buttons
      contextualButtons.value = [];
    };
    
    // Handle CIM submit
    const handleCIMSubmit = (data, message) => {
      console.log('CIM submit:', data);
      
      // Handle different CIM types
      if (message.cimComponent === 'AuthForm') {
        // Handle auth form submission
        handleAuthSubmit(data);
      }
      
      // Clear active contextual input
      activeContextualInput.value = null;
    };
    
    // Handle auth form submission
    const handleAuthSubmit = async (data) => {
      try {
        if (data.action === 'register') {
          // Register user
          const { error } = await supabase.auth.signUp({
            email: data.email,
            password: data.password
          });
          
          if (error) throw error;
          
          // Add success message
          messages.value.push({
            content: `Great! You've registered successfully. Now you can start curating your music obsession.`,
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: false
          });
          
          // Load current user
          await loadCurrentUser();
          
        } else if (data.action === 'login') {
          // Login user
          const { error } = await supabase.auth.signInWithPassword({
            email: data.email,
            password: data.password
          });
          
          if (error) throw error;
          
          // Add success message
          messages.value.push({
            content: `Welcome back! Ready to continue your music journey?`,
            sender: 'ai',
            timestamp: new Date(),
            hasCIM: false
          });
          
          // Load current user
          await loadCurrentUser();
        }
        
        // Add contextual buttons for next steps
        contextualButtons.value = [
          { label: 'Curate My Music', action: 'curate' }
        ];
        
      } catch (error) {
        console.error('Auth error:', error);
        
        // Add error message
        messages.value.push({
          content: `Sorry, there was an error: ${error.message}`,
          sender: 'ai',
          timestamp: new Date(),
          hasCIM: false
        });
      }
    };
    
    // Handle CIM cancel
    const handleCIMCancel = (message) => {
      console.log('CIM cancel:', message);
      
      // Remove the CIM from the message
      message.hasCIM = false;
      
      // Add a follow-up message
      messages.value.push({
        content: "No problem. What would you like to do instead?",
        sender: 'ai',
        timestamp: new Date(),
        hasCIM: false
      });
      
      // Clear active contextual input
      activeContextualInput.value = null;
    };
    
    // Handle CIM complete (for multi-step modules)
    const handleCIMComplete = (data, message) => {
      console.log('CIM complete:', data);
      
      if (message.cimComponent === 'MusicCurationModule') {
        // Handle music curation completion
        handleMusicCurationComplete(data);
      }
      
      // Remove the CIM from the message
      message.hasCIM = false;
      
      // Clear active contextual input
      activeContextualInput.value = null;
    };
    
    // Handle music curation completion
    const handleMusicCurationComplete = async (data) => {
      try {
        // Update user's primary artist
        if (data.artist && currentUser.value) {
          await supabase
            .from('profiles')
            .update({
              primary_artist_id: data.artist.id,
              updated_at: new Date()
            })
            .eq('id', currentUser.value.id);
            
          // Update local user data
          if (currentUser.value.profile) {
            currentUser.value.profile.primary_artist_id = data.artist.id;
          }
        }
        
        // Add success message
        messages.value.push({
          content: `Perfect! I've saved your music curation. You've curated ${data.albums?.length || 0} albums and ${data.songs?.length || 0} songs by ${data.artist?.name || 'your favorite artist'}.`,
          sender: 'ai',
          timestamp: new Date(),
          hasCIM: false
        });
        
        // Show curation in sideboard
        showMusicCurationInSideboard();
        
      } catch (error) {
        console.error('Error saving music curation:', error);
        
        // Add error message
        messages.value.push({
          content: `Sorry, there was an error saving your curation: ${error.message}`,
          sender: 'ai',
          timestamp: new Date(),
          hasCIM: false
        });
      }
    };
    
    // Handle CIM skip
    const handleCIMSkip = (message) => {
      console.log('CIM skip:', message);
      
      // Remove the CIM from the message
      message.hasCIM = false;
      
      // Add a follow-up message
      messages.value.push({
        content: "No problem. We can come back to this later. What would you like to do now?",
        sender: 'ai',
        timestamp: new Date(),
        hasCIM: false
      });
      
      // Clear active contextual input
      activeContextualInput.value = null;
    };
    
    // Show music curation in sideboard
    const showMusicCurationInSideboard = () => {
      if (sideboard.value && currentUser.value) {
        sideboard.value.setContent(MusicCurationDisplay, {
          userId: currentUser.value.id
        });
        
        // Expand sideboard if it's not already expanded
        if (!isSideboardExpanded.value) {
          isSideboardExpanded.value = true;
        }
      }
    };
    
    // Toggle sideboard
    const toggleSideboard = () => {
      isSideboardExpanded.value = !isSideboardExpanded.value;
    };
    
    // Format message with line breaks and links
    const formatMessage = (message) => {
      if (!message) return '';
      
      // Convert line breaks to <br>
      let formatted = message.replace(/\n/g, '<br>');
      
      // Convert URLs to links
      formatted = formatted.replace(
        /(https?:\/\/[^\s]+)/g, 
        '<a href="$1" target="_blank" rel="noopener noreferrer">$1</a>'
      );
      
      return formatted;
    };
    
    // Format timestamp
    const formatTime = (timestamp) => {
      if (!timestamp) return '';
      
      const date = new Date(timestamp);
      return date.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    };
    
    // Scroll to bottom of messages
    const scrollToBottom = () => {
      nextTick(() => {
        if (messagesContainer.value) {
          messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight;
        }
      });
    };
    
    // Initialize chat with welcome message if no initial messages
    const initializeChat = () => {
      if (messages.value.length === 0) {
        messages.value.push({
          content: "👋 Hi there! I'm your AI concierge for Music Besties. I'm here to help you curate your music obsession and find your music tribe. What would you like to do today?",
          sender: 'ai',
          timestamp: new Date(),
          hasCIM: false
        });
        
        // Add contextual buttons for common actions
        contextualButtons.value = [
          { label: 'Sign In / Register', action: 'auth' },
          { label: 'Curate My Music', action: 'curate' }
        ];
      }
    };
    
    // Lifecycle hooks
    onMounted(() => {
      // Load current user
      loadCurrentUser();
      
      // Initialize chat
      initializeChat();
      
      // Scroll to bottom
      scrollToBottom();
    });
    
    return {
      messages,
      userInput,
      isAiTyping,
      contextualButtons,
      activeContextualInput,
      isSideboardExpanded,
      messagesContainer,
      inputField,
      sideboard,
      currentUser,
      isAuthenticated,
      sendMessage,
      handleContextualButton,
      handleCIMSubmit,
      handleCIMCancel,
      handleCIMComplete,
      handleCIMSkip,
      toggleSideboard,
      formatMessage,
      formatTime
    };
  }
};
</script>

<style scoped>
.chat-interface {
  display: flex;
  flex-direction: column;
  height: 100vh;
  max-width: 1200px;
  margin: 0 auto;
  background-color: #f9fafb;
}

.chat-header {
  padding: 15px;
  background-color: #4f46e5;
  color: white;
  text-align: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.chat-header h2 {
  margin: 0;
  font-size: 1.5rem;
}

.chat-container {
  display: flex;
  flex: 1;
  overflow: hidden;
}

.chat-messages {
  flex: 1;
  padding: 15px;
  overflow-y: auto;
  display: flex;
  flex-direction: column;
}

.message-wrapper {
  margin-bottom: 15px;
  max-width: 80%;
}

.user-message {
  align-self: flex-end;
}

.ai-message {
  align-self: flex-start;
}

.message-bubble {
  padding: 10px 15px;
  border-radius: 18px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
}

.user-message .message-bubble {
  background-color: #4f46e5;
  color: white;
  border-bottom-right-radius: 4px;
}

.ai-message .message-bubble {
  background-color: white;
  color: #1f2937;
  border-bottom-left-radius: 4px;
}

.message-bubble p {
  margin: 0;
  line-height: 1.4;
}

.message-timestamp {
  font-size: 0.7rem;
  color: #6b7280;
  margin-top: 5px;
  padding: 0 5px;
}

.message-with-cim {
  width: 100%;
}

.cim-container {
  margin-top: 15px;
  border-radius: 12px;
  overflow: hidden;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
}

.typing-indicator {
  display: flex;
  align-items: center;
  padding: 10px 15px;
  background-color: white;
  border-radius: 18px;
  align-self: flex-start;
  margin-bottom: 15px;
  box-shadow: 0 1px 2px rgba(0, 0, 0, 0.1);
  width: 60px;
}

.dot {
  width: 8px;
  height: 8px;
  background-color: #6b7280;
  border-radius: 50%;
  margin: 0 3px;
  animation: typing 1.5s infinite ease-in-out;
}

.dot:nth-child(1) {
  animation-delay: 0s;
}

.dot:nth-child(2) {
  animation-delay: 0.2s;
}

.dot:nth-child(3) {
  animation-delay: 0.4s;
}

@keyframes typing {
  0%, 100% {
    transform: translateY(0);
  }
  50% {
    transform: translateY(-5px);
  }
}

.sideboard-container {
  width: 0;
  transition: width 0.3s ease;
  overflow: hidden;
  position: relative;
}

.sideboard-container.expanded {
  width: 350px;
  border-left: 1px solid #e5e7eb;
}

.sideboard-toggle {
  position: absolute;
  top: 50%;
  left: 0;
  transform: translateY(-50%);
  background-color: #4f46e5;
  color: white;
  padding: 10px;
  border-radius: 0 8px 8px 0;
  cursor: pointer;
  display: flex;
  align-items: center;
  font-size: 0.8rem;
  z-index: 10;
}

.sideboard-toggle span {
  margin-right: 5px;
}

.chat-input-area {
  display: flex;
  padding: 15px;
  background-color: white;
  border-top: 1px solid #e5e7eb;
}

.chat-input-area textarea {
  flex: 1;
  padding: 12px;
  border: 1px solid #d1d5db;
  border-radius: 8px;
  resize: none;
  font-family: inherit;
  font-size: 1rem;
  height: 50px;
  max-height: 150px;
}

.send-button {
  width: 50px;
  height: 50px;
  margin-left: 10px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}

.send-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

.contextual-buttons {
  display: flex;
  flex-wrap: wrap;
  padding: 10px 15px;
  background-color: white;
  border-top: 1px solid #e5e7eb;
}

.contextual-button {
  margin: 5px;
  padding: 8px 15px;
  background-color: #f3f4f6;
  border: 1px solid #d1d5db;
  border-radius: 20px;
  font-size: 0.9rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.contextual-button:hover {
  background-color: #e5e7eb;
}

/* Mobile responsiveness */
@media (max-width: 768px) {
  .message-wrapper {
    max-width: 90%;
  }
  
  .sideboard-container.expanded {
    position: absolute;
    top: 0;
    right: 0;
    bottom: 0;
    width: 100%;
    z-index: 100;
    background-color: #f9fafb;
  }
  
  .sideboard-toggle {
    top: 10px;
    left: auto;
    right: 10px;
    transform: none;
  }
}
</style>
