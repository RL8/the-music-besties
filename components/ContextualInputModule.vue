<template>
  <div class="contextual-input-module">
    <div class="module-overlay" @click.self="cancelInput">
      <div class="module-container">
        <div class="module-header">
          <h3>{{ title }}</h3>
          <button class="close-button" @click="cancelInput">
            <Icon name="heroicons:x-mark" class="close-icon" />
          </button>
        </div>
        <div class="module-content">
          <p v-if="description" class="module-description">{{ description }}</p>
          
          <!-- Text input -->
          <div v-if="inputType === 'text'" class="input-field">
            <label :for="inputId">{{ label }}</label>
            <input 
              :id="inputId" 
              type="text" 
              v-model="inputValue" 
              :placeholder="placeholder" 
              :required="required"
            />
            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
          </div>
          
          <!-- Number input -->
          <div v-else-if="inputType === 'number'" class="input-field">
            <label :for="inputId">{{ label }}</label>
            <input 
              :id="inputId" 
              type="number" 
              v-model="inputValue" 
              :placeholder="placeholder" 
              :required="required"
              :min="min"
              :max="max"
            />
            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
          </div>
          
          <!-- Select input -->
          <div v-else-if="inputType === 'select'" class="input-field">
            <label :for="inputId">{{ label }}</label>
            <select 
              :id="inputId" 
              v-model="inputValue" 
              :required="required"
            >
              <option value="" disabled selected>{{ placeholder }}</option>
              <option v-for="option in options" :key="option.value" :value="option.value">
                {{ option.label }}
              </option>
            </select>
            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
          </div>
          
          <!-- Textarea input -->
          <div v-else-if="inputType === 'textarea'" class="input-field">
            <label :for="inputId">{{ label }}</label>
            <textarea 
              :id="inputId" 
              v-model="inputValue" 
              :placeholder="placeholder" 
              :required="required"
              :rows="rows || 4"
            ></textarea>
            <p v-if="errorMessage" class="error-message">{{ errorMessage }}</p>
          </div>
        </div>
        <div class="module-actions">
          <button class="cancel-button" @click="cancelInput">Cancel</button>
          <button class="save-button" @click="submitInput" :disabled="!isValid">
            {{ submitButtonText }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue';
import { v4 as uuidv4 } from 'uuid';

const props = defineProps({
  title: {
    type: String,
    default: 'Input Required'
  },
  description: {
    type: String,
    default: ''
  },
  inputType: {
    type: String,
    default: 'text',
    validator: (value) => ['text', 'number', 'select', 'textarea'].includes(value)
  },
  label: {
    type: String,
    required: true
  },
  placeholder: {
    type: String,
    default: ''
  },
  required: {
    type: Boolean,
    default: true
  },
  min: {
    type: Number,
    default: null
  },
  max: {
    type: Number,
    default: null
  },
  options: {
    type: Array,
    default: () => []
  },
  rows: {
    type: Number,
    default: 4
  },
  submitButtonText: {
    type: String,
    default: 'Save'
  },
  componentType: {
    type: String,
    required: true
  }
});

const emit = defineEmits(['submit', 'cancel']);

const inputId = ref(`input-${uuidv4()}`);
const inputValue = ref('');
const errorMessage = ref('');

// Validate input based on type
const isValid = computed(() => {
  if (!props.required) return true;
  
  if (!inputValue.value) {
    errorMessage.value = 'This field is required';
    return false;
  }
  
  if (props.inputType === 'number') {
    const numValue = Number(inputValue.value);
    if (props.min !== null && numValue < props.min) {
      errorMessage.value = `Value must be at least ${props.min}`;
      return false;
    }
    if (props.max !== null && numValue > props.max) {
      errorMessage.value = `Value must be at most ${props.max}`;
      return false;
    }
  }
  
  errorMessage.value = '';
  return true;
});

// Focus the input field when component is mounted
onMounted(() => {
  const inputElement = document.getElementById(inputId.value);
  if (inputElement) {
    inputElement.focus();
  }
});

// Submit the input value
function submitInput() {
  if (!isValid.value) return;
  
  emit('submit', {
    value: inputValue.value,
    componentType: props.componentType
  });
}

// Cancel the input
function cancelInput() {
  emit('cancel');
}
</script>

<style scoped>
.contextual-input-module {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
}

.module-overlay {
  width: 100%;
  height: 100%;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 1rem;
}

.module-container {
  background-color: white;
  border-radius: 12px;
  width: 100%;
  max-width: 500px;
  box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
  overflow: hidden;
}

.module-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #4f46e5;
  color: white;
}

.module-header h3 {
  margin: 0;
  font-size: 1.25rem;
}

.close-button {
  background: none;
  border: none;
  color: white;
  cursor: pointer;
  padding: 0.25rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

.close-icon {
  width: 1.25rem;
  height: 1.25rem;
}

.module-content {
  padding: 1.5rem;
}

.module-description {
  margin-top: 0;
  margin-bottom: 1.5rem;
  color: #4b5563;
}

.input-field {
  margin-bottom: 1.5rem;
}

.input-field label {
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 500;
  color: #1f2937;
}

.input-field input,
.input-field select,
.input-field textarea {
  width: 100%;
  padding: 0.75rem;
  border: 1px solid #d1d5db;
  border-radius: 0.375rem;
  font-size: 1rem;
  transition: border-color 0.2s;
}

.input-field input:focus,
.input-field select:focus,
.input-field textarea:focus {
  outline: none;
  border-color: #4f46e5;
  box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.2);
}

.error-message {
  color: #dc2626;
  font-size: 0.875rem;
  margin-top: 0.5rem;
  margin-bottom: 0;
}

.module-actions {
  display: flex;
  justify-content: flex-end;
  padding: 1rem 1.5rem;
  background-color: #f9fafb;
  border-top: 1px solid #e5e7eb;
}

.cancel-button,
.save-button {
  padding: 0.5rem 1rem;
  border-radius: 0.375rem;
  font-weight: 500;
  cursor: pointer;
  transition: background-color 0.2s;
}

.cancel-button {
  background-color: white;
  border: 1px solid #d1d5db;
  color: #4b5563;
  margin-right: 0.75rem;
}

.cancel-button:hover {
  background-color: #f3f4f6;
}

.save-button {
  background-color: #4f46e5;
  border: none;
  color: white;
}

.save-button:hover:not(:disabled) {
  background-color: #4338ca;
}

.save-button:disabled {
  background-color: #a5b4fc;
  cursor: not-allowed;
}
</style>
