<template>
  <div class="exchange-unit" :class="{ 'collapsed': isCollapsed }">
    <div class="exchange-header" @click="toggleCollapse">
      <h4>{{ title }}</h4>
      <Icon :name="isCollapsed ? 'heroicons:chevron-down' : 'heroicons:chevron-up'" class="toggle-icon" />
    </div>
    <div class="exchange-content" v-if="!isCollapsed">
      <slot></slot>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue';

const props = defineProps({
  title: {
    type: String,
    required: true
  },
  initiallyCollapsed: {
    type: Boolean,
    default: false
  }
});

const isCollapsed = ref(props.initiallyCollapsed);

function toggleCollapse() {
  isCollapsed.value = !isCollapsed.value;
}
</script>

<style scoped>
.exchange-unit {
  border: 1px solid #e5e7eb;
  border-radius: 8px;
  margin-bottom: 1rem;
  background-color: white;
  overflow: hidden;
  transition: all 0.3s ease;
}

.exchange-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem 1rem;
  background-color: #f3f4f6;
  cursor: pointer;
  user-select: none;
}

.exchange-header h4 {
  margin: 0;
  font-size: 1rem;
  color: #4b5563;
}

.toggle-icon {
  width: 1.25rem;
  height: 1.25rem;
  color: #6b7280;
  transition: transform 0.3s ease;
}

.exchange-content {
  padding: 1rem;
}

.collapsed .toggle-icon {
  transform: rotate(180deg);
}
</style>
