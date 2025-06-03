<template>
  <div class="auth-form">
    <div class="auth-header">
      <h3>{{ isLogin ? 'Welcome Back' : 'Join Music Besties' }}</h3>
      <p>{{ isLogin ? 'Sign in to continue your music journey' : 'Create an account to start your music journey' }}</p>
    </div>

    <form @submit.prevent="handleSubmit" class="auth-fields">
      <div v-if="!isLogin" class="form-group">
        <label for="username">Username</label>
        <input 
          type="text" 
          id="username" 
          v-model="formData.username" 
          required
          placeholder="Choose a username"
          :disabled="loading"
        />
      </div>

      <div class="form-group">
        <label for="email">Email</label>
        <input 
          type="email" 
          id="email" 
          v-model="formData.email" 
          required
          placeholder="Enter your email"
          :disabled="loading"
        />
      </div>

      <div class="form-group">
        <label for="password">Password</label>
        <input 
          type="password" 
          id="password" 
          v-model="formData.password" 
          required
          placeholder="Enter your password"
          :disabled="loading"
        />
      </div>

      <div v-if="error" class="error-message">
        {{ error }}
      </div>

      <div class="form-actions">
        <button 
          type="submit" 
          class="primary-button"
          :disabled="loading"
        >
          {{ isLogin ? 'Sign In' : 'Create Account' }}
        </button>
        
        <button 
          type="button" 
          class="secondary-button"
          @click="toggleAuthMode"
          :disabled="loading"
        >
          {{ isLogin ? 'Need an account?' : 'Already have an account?' }}
        </button>
      </div>
    </form>

    <div v-if="loading" class="loading-indicator">
      <div class="spinner"></div>
      <span>{{ isLogin ? 'Signing in...' : 'Creating your account...' }}</span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';
import { useSupabase } from '~/services/supabase';

const props = defineProps({
  mode: {
    type: String,
    default: 'login', // 'login' or 'signup'
  }
});

const emit = defineEmits(['success', 'cancel', 'error']);

const supabase = useSupabase();
const isLogin = ref(props.mode === 'login');
const loading = ref(false);
const error = ref('');

const formData = ref({
  email: '',
  password: '',
  username: ''
});

const toggleAuthMode = () => {
  isLogin.value = !isLogin.value;
  error.value = '';
};

const handleSubmit = async () => {
  error.value = '';
  loading.value = true;

  try {
    if (isLogin.value) {
      // Login flow
      const { data, error: authError } = await supabase.auth.signInWithPassword({
        email: formData.value.email,
        password: formData.value.password
      });

      if (authError) throw authError;
      
      emit('success', { 
        action: 'login', 
        user: data.user 
      });
    } else {
      // Signup flow
      const { data, error: authError } = await supabase.auth.signUp({
        email: formData.value.email,
        password: formData.value.password,
        options: {
          data: {
            username: formData.value.username
          }
        }
      });

      if (authError) throw authError;

      // After signup, create a profile record in the profiles table
      if (data.user) {
        const { error: profileError } = await supabase
          .from('profiles')
          .insert({
            id: data.user.id,
            username: formData.value.username,
            updated_at: new Date()
          });

        if (profileError) throw profileError;
      }
      
      emit('success', { 
        action: 'signup', 
        user: data.user 
      });
    }
  } catch (err) {
    console.error('Authentication error:', err);
    error.value = err.message || 'An error occurred during authentication';
    emit('error', err);
  } finally {
    loading.value = false;
  }
};
</script>

<style scoped>
.auth-form {
  background-color: #ffffff;
  border-radius: 12px;
  padding: 1.5rem;
  width: 100%;
  max-width: 400px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}

.auth-header {
  margin-bottom: 1.5rem;
  text-align: center;
}

.auth-header h3 {
  font-size: 1.5rem;
  color: #4f46e5;
  margin-bottom: 0.5rem;
}

.auth-header p {
  color: #6b7280;
  font-size: 0.9rem;
}

.form-group {
  margin-bottom: 1rem;
}

.form-group label {
  display: block;
  margin-bottom: 0.5rem;
  font-size: 0.9rem;
  color: #374151;
}

.form-group input {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 1rem;
}

.form-group input:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 2px rgba(79, 70, 229, 0.2);
}

.error-message {
  color: #ef4444;
  font-size: 0.875rem;
  margin-bottom: 1rem;
  padding: 0.5rem;
  background-color: rgba(239, 68, 68, 0.1);
  border-radius: 4px;
}

.form-actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.primary-button, .secondary-button {
  width: 100%;
  padding: 0.75rem;
  border-radius: 6px;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.primary-button {
  background-color: #4f46e5;
  color: white;
  border: none;
}

.primary-button:hover {
  background-color: #4338ca;
}

.secondary-button {
  background-color: transparent;
  color: #4f46e5;
  border: 1px solid #4f46e5;
}

.secondary-button:hover {
  background-color: rgba(79, 70, 229, 0.1);
}

.loading-indicator {
  display: flex;
  align-items: center;
  justify-content: center;
  margin-top: 1rem;
  color: #6b7280;
}

.spinner {
  border: 2px solid rgba(79, 70, 229, 0.2);
  border-top: 2px solid #4f46e5;
  border-radius: 50%;
  width: 1rem;
  height: 1rem;
  animation: spin 1s linear infinite;
  margin-right: 0.5rem;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}
</style>
