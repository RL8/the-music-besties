<template>
  <div class="sideboard" :class="{ 'expanded': isExpanded }">
    <div class="sideboard-header" @click="toggleSideboard">
      <h3>{{ title }}</h3>
      <Icon :name="isExpanded ? 'heroicons:chevron-up' : 'heroicons:chevron-down'" class="toggle-icon" />
    </div>
    <div class="sideboard-content" v-if="isExpanded">
      <div class="active-display-area">
        <component 
          v-if="activeComponent" 
          :is="activeComponent" 
          v-bind="activeComponentProps"
        />
        <div v-else class="empty-state">
          <p>No content to display yet</p>
        </div>
      </div>
      <div class="sideboard-history" v-if="history.length > 0">
        <h4>History</h4>
        <div v-for="(item, index) in history" :key="index" class="history-item">
          {{ item.title }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue';

const props = defineProps({
  title: {
    type: String,
    default: 'Sideboard'
  }
});

const isExpanded = ref(false);
const activeComponent = ref(null);
const activeComponentProps = ref({});
const history = ref([]);

// Toggle sideboard expansion
function toggleSideboard() {
  isExpanded.value = !isExpanded.value;
}

// Set content to display in the sideboard
function setContent(component, props = {}) {
  activeComponent.value = component;
  activeComponentProps.value = props;
  
  // If the sideboard is not expanded, expand it
  if (!isExpanded.value) {
    isExpanded.value = true;
  }
}

// Add an item to history
function addToHistory(title, componentName, props = {}) {
  history.value.push({
    title,
    componentName,
    props
  });
}

// Clear the active content
function clearContent() {
  activeComponent.value = null;
  activeComponentProps.value = {};
}

// Expose methods for parent components
defineExpose({
  setContent,
  addToHistory,
  clearContent,
  toggleSideboard
});
</script>

<style scoped>
.sideboard {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
  margin-top: 1rem;
  overflow: hidden;
  transition: all 0.3s ease;
}

.sideboard-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 1rem;
  background-color: #4f46e5;
  color: white;
  cursor: pointer;
}

.sideboard-header h3 {
  margin: 0;
  font-size: 1.25rem;
}

.toggle-icon {
  width: 1.25rem;
  height: 1.25rem;
  transition: transform 0.3s ease;
}

.sideboard-content {
  padding: 1rem;
  max-height: 0;
  overflow: hidden;
  transition: max-height 0.3s ease, padding 0.3s ease;
}

.expanded .sideboard-content {
  max-height: 500px;
  padding: 1rem;
}

.active-display-area {
  min-height: 100px;
  background-color: #f9fafb;
  border-radius: 8px;
  padding: 1rem;
  margin-bottom: 1rem;
}

.empty-state {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100%;
  color: #6b7280;
  font-style: italic;
}

.sideboard-history {
  border-top: 1px solid #e5e7eb;
  padding-top: 1rem;
}

.sideboard-history h4 {
  margin-top: 0;
  margin-bottom: 0.5rem;
  font-size: 1rem;
  color: #4b5563;
}

.history-item {
  padding: 0.5rem;
  border-radius: 4px;
  background-color: #f3f4f6;
  margin-bottom: 0.5rem;
  font-size: 0.875rem;
  cursor: pointer;
  transition: background-color 0.2s;
}

.history-item:hover {
  background-color: #e5e7eb;
}
</style>
