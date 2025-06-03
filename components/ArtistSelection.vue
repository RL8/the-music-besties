<template>
  <div class="artist-selection">
    <div v-if="step === 'search'" class="search-step">
      <h3 class="title">Select Your Music Obsession</h3>
      <p class="description">Who's that one artist you could talk about forever?</p>
      
      <div class="search-container">
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Search for an artist..." 
          class="search-input"
          @keyup.enter="searchArtists"
        />
        <button @click="searchArtists" class="search-button">
          <span v-if="isSearching">Searching...</span>
          <span v-else>Search</span>
        </button>
      </div>

      <div v-if="searchResults.length > 0" class="results-container">
        <div 
          v-for="artist in searchResults" 
          :key="artist.id" 
          class="artist-card"
          @click="selectArtist(artist)"
        >
          <div class="artist-image">
            <img 
              :src="artist.image_url || '/images/default-artist.png'" 
              :alt="artist.name"
            />
          </div>
          <div class="artist-info">
            <h4>{{ artist.name }}</h4>
            <p v-if="artist.genre">{{ artist.genre }}</p>
          </div>
        </div>
      </div>

      <div v-if="searchError" class="error-message">
        {{ searchError }}
      </div>
    </div>

    <div v-if="step === 'confirm'" class="confirm-step">
      <h3 class="title">Confirm Your Selection</h3>
      
      <div class="selected-artist">
        <div class="artist-image">
          <img 
            :src="selectedArtist.image_url || '/images/default-artist.png'" 
            :alt="selectedArtist.name"
          />
        </div>
        <div class="artist-info">
          <h4>{{ selectedArtist.name }}</h4>
          <p v-if="selectedArtist.genre">{{ selectedArtist.genre }}</p>
        </div>
      </div>

      <p class="confirmation-text">
        Is this the artist you want to select as your music obsession?
      </p>

      <div class="action-buttons">
        <button @click="confirmArtist" class="confirm-button">
          <span v-if="isConfirming">Confirming...</span>
          <span v-else>Yes, That's The One!</span>
        </button>
        <button @click="step = 'search'" class="back-button">
          No, Go Back
        </button>
      </div>
    </div>

    <div v-if="step === 'success'" class="success-step">
      <h3 class="title">Perfect Choice!</h3>
      
      <div class="selected-artist">
        <div class="artist-image">
          <img 
            :src="selectedArtist.image_url || '/images/default-artist.png'" 
            :alt="selectedArtist.name"
          />
        </div>
        <div class="artist-info">
          <h4>{{ selectedArtist.name }}</h4>
          <p v-if="selectedArtist.genre">{{ selectedArtist.genre }}</p>
        </div>
      </div>

      <p class="success-text">
        {{ selectedArtist.name }} has been set as your music obsession!
      </p>

      <div class="action-buttons">
        <button @click="$emit('continue')" class="continue-button">
          Continue
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { useSupabase } from '~/services/supabase';

export default {
  name: 'ArtistSelection',
  props: {
    userId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      step: 'search',
      searchQuery: '',
      searchResults: [],
      selectedArtist: null,
      isSearching: false,
      isConfirming: false,
      searchError: null
    };
  },
  methods: {
    async searchArtists() {
      if (!this.searchQuery.trim()) {
        this.searchError = 'Please enter an artist name';
        return;
      }

      this.isSearching = true;
      this.searchError = null;

      try {
        const response = await fetch(`/api/music/search`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          body: JSON.stringify({
            query: this.searchQuery
          })
        });

        if (!response.ok) {
          throw new Error('Failed to search for artists');
        }

        const data = await response.json();
        this.searchResults = data.items || [];

        if (this.searchResults.length === 0) {
          this.searchError = 'No artists found. Try another search term.';
        }
      } catch (error) {
        console.error('Error searching artists:', error);
        this.searchError = 'An error occurred while searching. Please try again.';
      } finally {
        this.isSearching = false;
      }
    },

    selectArtist(artist) {
      this.selectedArtist = artist;
      this.step = 'confirm';
    },

    async confirmArtist() {
      this.isConfirming = true;

      try {
        const response = await fetch(`/api/music/set-primary-artist`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          body: JSON.stringify({
            user_id: this.userId,
            artist_id: this.selectedArtist.id
          })
        });

        if (!response.ok) {
          throw new Error('Failed to set primary artist');
        }

        // Update user profile in Supabase
        const supabase = useSupabase();
        await supabase
          .from('profiles')
          .update({
            primary_artist_id: this.selectedArtist.id,
            updated_at: new Date()
          })
          .eq('id', this.userId);

        this.step = 'success';
      } catch (error) {
        console.error('Error confirming artist:', error);
        this.searchError = 'An error occurred while confirming your selection. Please try again.';
        this.step = 'confirm';
      } finally {
        this.isConfirming = false;
      }
    }
  }
};
</script>

<style scoped>
.artist-selection {
  background-color: var(--chat-bg, #f8f9fa);
  border-radius: 12px;
  padding: 20px;
  max-width: 500px;
  margin: 0 auto;
}

.title {
  font-size: 1.5rem;
  margin-bottom: 10px;
  color: var(--primary-color, #333);
}

.description {
  margin-bottom: 20px;
  color: var(--text-color, #555);
}

.search-container {
  display: flex;
  margin-bottom: 20px;
}

.search-input {
  flex: 1;
  padding: 10px 15px;
  border: 1px solid var(--border-color, #ddd);
  border-radius: 8px 0 0 8px;
  font-size: 1rem;
}

.search-button {
  padding: 10px 15px;
  background-color: var(--primary-color, #4a90e2);
  color: white;
  border: none;
  border-radius: 0 8px 8px 0;
  cursor: pointer;
  font-size: 1rem;
}

.results-container {
  max-height: 400px;
  overflow-y: auto;
  margin-bottom: 20px;
}

.artist-card {
  display: flex;
  align-items: center;
  padding: 10px;
  border: 1px solid var(--border-color, #ddd);
  border-radius: 8px;
  margin-bottom: 10px;
  cursor: pointer;
  transition: background-color 0.2s;
}

.artist-card:hover {
  background-color: var(--hover-bg, #f0f0f0);
}

.artist-image {
  width: 60px;
  height: 60px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 15px;
}

.artist-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.artist-info h4 {
  margin: 0 0 5px 0;
  font-size: 1.1rem;
}

.artist-info p {
  margin: 0;
  font-size: 0.9rem;
  color: var(--secondary-text, #777);
}

.error-message {
  color: var(--error-color, #e74c3c);
  margin-top: 10px;
}

.selected-artist {
  display: flex;
  align-items: center;
  padding: 15px;
  border: 2px solid var(--primary-color, #4a90e2);
  border-radius: 12px;
  margin-bottom: 20px;
}

.confirmation-text, .success-text {
  margin-bottom: 20px;
  font-size: 1.1rem;
}

.action-buttons {
  display: flex;
  justify-content: space-between;
}

.confirm-button, .continue-button {
  padding: 12px 20px;
  background-color: var(--success-color, #2ecc71);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
  font-weight: bold;
}

.back-button {
  padding: 12px 20px;
  background-color: var(--secondary-color, #95a5a6);
  color: white;
  border: none;
  border-radius: 8px;
  cursor: pointer;
  font-size: 1rem;
}
</style>
