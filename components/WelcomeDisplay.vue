<template>
  <div class="welcome-display">
    <div class="welcome-header">
      <Icon name="heroicons:musical-note" class="music-icon" />
      <h2>Welcome, {{ name }}!</h2>
    </div>
    <div class="welcome-content">
      <p>We're excited to have you join The Music Besties community. This is where you'll discover your music tribe - people who share your unique taste in music.</p>
      <p>Here's what you can do:</p>
      <ul>
        <li>Curate your favorite artists and songs</li>
        <li>Find others with similar music taste</li>
        <li>Connect with your music besties</li>
      </ul>
      <p class="next-steps">Ready to start? Just chat with me and I'll guide you through the process!</p>
    </div>
  </div>
</template>

<script setup>
defineProps({
  name: {
    type: String,
    required: true
  }
});
</script>

<style scoped>
.welcome-display {
  color: #1f2937;
}

.welcome-header {
  display: flex;
  align-items: center;
  margin-bottom: 1rem;
}

.music-icon {
  width: 2rem;
  height: 2rem;
  color: #4f46e5;
  margin-right: 0.75rem;
}

.welcome-header h2 {
  margin: 0;
  font-size: 1.5rem;
  color: #4f46e5;
}

.welcome-content {
  font-size: 1rem;
  line-height: 1.5;
}

.welcome-content p {
  margin-bottom: 1rem;
}

.welcome-content ul {
  margin-bottom: 1rem;
  padding-left: 1.5rem;
}

.welcome-content li {
  margin-bottom: 0.5rem;
}

.next-steps {
  font-weight: 500;
  color: #4f46e5;
}
</style>
