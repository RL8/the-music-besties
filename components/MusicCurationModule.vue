<template>
  <div class="music-curation-module">
    <div class="module-header">
      <h3>{{ title }}</h3>
      <p v-if="description" class="module-description">{{ description }}</p>
    </div>

    <!-- Artist Selection Step -->
    <div v-if="step === 'artist-selection'" class="step-container">
      <div class="search-container">
        <input 
          type="text" 
          v-model="searchQuery" 
          placeholder="Search for an artist..." 
          class="search-input"
          @keyup.enter="searchArtists"
        />
        <button @click="searchArtists" class="search-button" :disabled="isSearching">
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

    <!-- Album Selection Step -->
    <div v-if="step === 'album-selection'" class="step-container">
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

      <h4 class="step-subtitle">Select your favorite albums</h4>
      
      <div v-if="isLoadingAlbums" class="loading-message">
        Loading albums...
      </div>
      
      <div v-else-if="artistAlbums.length === 0" class="empty-message">
        No albums found for this artist
      </div>
      
      <div v-else class="albums-container">
        <div 
          v-for="album in artistAlbums" 
          :key="album.id" 
          class="album-card"
          @click="selectAlbum(album)"
        >
          <div class="album-image">
            <img 
              :src="album.image_url || '/images/default-album.png'" 
              :alt="album.title"
            />
          </div>
          <div class="album-info">
            <h4>{{ album.title }}</h4>
            <p v-if="album.release_year">{{ album.release_year }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Album Rating Step -->
    <div v-if="step === 'album-rating'" class="step-container">
      <div class="selected-album">
        <div class="album-image">
          <img 
            :src="selectedAlbum.image_url || '/images/default-album.png'" 
            :alt="selectedAlbum.title"
          />
        </div>
        <div class="album-info">
          <h4>{{ selectedAlbum.title }}</h4>
          <p v-if="selectedAlbum.release_year">{{ selectedAlbum.release_year }}</p>
        </div>
      </div>

      <h4 class="step-subtitle">Rate this album</h4>
      
      <div class="rating-container">
        <div class="star-rating">
          <span 
            v-for="i in 5" 
            :key="i" 
            class="star" 
            :class="{ 'active': i <= albumRating }"
            @click="albumRating = i"
          >★</span>
        </div>
        <span class="rating-text">{{ albumRating }} of 5 stars</span>
      </div>

      <div class="comment-container">
        <label for="album-comment">Your thoughts on this album:</label>
        <textarea 
          id="album-comment" 
          v-model="albumComment" 
          placeholder="Share your thoughts..."
          rows="3"
        ></textarea>
      </div>

      <div class="ranking-container">
        <label for="album-ranking">How important is this album to you? (0-100%)</label>
        <input 
          type="range" 
          id="album-ranking" 
          v-model.number="albumRanking" 
          min="0" 
          max="100" 
          step="5"
        />
        <span class="ranking-value">{{ albumRanking }}%</span>
      </div>
    </div>

    <!-- Song Selection Step -->
    <div v-if="step === 'song-selection'" class="step-container">
      <div class="selected-album">
        <div class="album-image">
          <img 
            :src="selectedAlbum.image_url || '/images/default-album.png'" 
            :alt="selectedAlbum.title"
          />
        </div>
        <div class="album-info">
          <h4>{{ selectedAlbum.title }}</h4>
          <p v-if="selectedAlbum.release_year">{{ selectedAlbum.release_year }}</p>
        </div>
      </div>

      <h4 class="step-subtitle">Select your favorite songs</h4>
      
      <div v-if="isLoadingSongs" class="loading-message">
        Loading songs...
      </div>
      
      <div v-else-if="albumSongs.length === 0" class="empty-message">
        No songs found for this album
      </div>
      
      <div v-else class="songs-container">
        <div 
          v-for="song in albumSongs" 
          :key="song.id" 
          class="song-card"
          @click="selectSong(song)"
        >
          <div class="song-number">{{ song.track_number || '-' }}</div>
          <div class="song-info">
            <h4>{{ song.title }}</h4>
            <p v-if="song.duration">{{ formatDuration(song.duration) }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Song Rating Step -->
    <div v-if="step === 'song-rating'" class="step-container">
      <div class="selected-song">
        <div class="song-info">
          <h4>{{ selectedSong.title }}</h4>
          <p>Track {{ selectedSong.track_number || '-' }}</p>
          <p v-if="selectedSong.duration">{{ formatDuration(selectedSong.duration) }}</p>
        </div>
      </div>

      <h4 class="step-subtitle">Rate this song</h4>
      
      <div class="rating-container">
        <div class="star-rating">
          <span 
            v-for="i in 5" 
            :key="i" 
            class="star" 
            :class="{ 'active': i <= songRating }"
            @click="songRating = i"
          >★</span>
        </div>
        <span class="rating-text">{{ songRating }} of 5 stars</span>
      </div>

      <div class="comment-container">
        <label for="song-comment">Your thoughts on this song:</label>
        <textarea 
          id="song-comment" 
          v-model="songComment" 
          placeholder="Share your thoughts..."
          rows="3"
        ></textarea>
      </div>

      <div class="ranking-container">
        <label for="song-ranking">How important is this song to you? (0-100%)</label>
        <input 
          type="range" 
          id="song-ranking" 
          v-model.number="songRanking" 
          min="0" 
          max="100" 
          step="5"
        />
        <span class="ranking-value">{{ songRanking }}%</span>
      </div>
    </div>

    <!-- Summary Step -->
    <div v-if="step === 'summary'" class="step-container">
      <h4 class="step-subtitle">Your Music Curation</h4>
      
      <div class="summary-container">
        <div class="summary-artist">
          <h4>Artist: {{ selectedArtist.name }}</h4>
        </div>
        
        <div v-if="curatedAlbums.length > 0" class="summary-albums">
          <h4>Albums:</h4>
          <div v-for="album in curatedAlbums" :key="album.id" class="summary-item">
            <div class="summary-title">{{ album.title }}</div>
            <div class="summary-rating">{{ album.rating }} ★</div>
          </div>
        </div>
        
        <div v-if="curatedSongs.length > 0" class="summary-songs">
          <h4>Songs:</h4>
          <div v-for="song in curatedSongs" :key="song.id" class="summary-item">
            <div class="summary-title">{{ song.title }}</div>
            <div class="summary-rating">{{ song.rating }} ★</div>
          </div>
        </div>
      </div>
    </div>

    <div class="module-actions">
      <button v-if="canGoBack" @click="goBack" class="back-button">Back</button>
      <button v-if="step === 'artist-selection'" @click="skipArtistSelection" class="skip-button">Skip</button>
      <button v-if="canContinue" @click="goNext" class="next-button">
        {{ nextButtonText }}
      </button>
      <button v-if="step === 'summary'" @click="finishCuration" class="finish-button">
        Finish Curation
      </button>
    </div>
  </div>
</template>

<script>
import { useSupabase } from '~/services/supabase';

export default {
  name: 'MusicCurationModule',
  props: {
    title: {
      type: String,
      default: 'Music Curation'
    },
    description: {
      type: String,
      default: 'Let\'s curate your music obsession!'
    },
    userId: {
      type: String,
      required: true
    },
    initialArtistId: {
      type: String,
      default: null
    }
  },
  data() {
    return {
      step: 'artist-selection',
      searchQuery: '',
      searchResults: [],
      searchError: null,
      isSearching: false,
      selectedArtist: null,
      artistAlbums: [],
      isLoadingAlbums: false,
      selectedAlbum: null,
      albumRating: 0,
      albumComment: '',
      albumRanking: 50,
      albumSongs: [],
      isLoadingSongs: false,
      selectedSong: null,
      songRating: 0,
      songComment: '',
      songRanking: 50,
      curatedAlbums: [],
      curatedSongs: [],
      stepHistory: []
    };
  },
  computed: {
    canGoBack() {
      return this.stepHistory.length > 0;
    },
    canContinue() {
      if (this.step === 'artist-selection') {
        return this.selectedArtist !== null;
      } else if (this.step === 'album-selection') {
        return true; // Can skip album selection
      } else if (this.step === 'album-rating') {
        return this.albumRating > 0;
      } else if (this.step === 'song-selection') {
        return true; // Can skip song selection
      } else if (this.step === 'song-rating') {
        return this.songRating > 0;
      }
      return false;
    },
    nextButtonText() {
      if (this.step === 'artist-selection') {
        return 'Continue to Albums';
      } else if (this.step === 'album-selection') {
        return 'Skip Album Selection';
      } else if (this.step === 'album-rating') {
        return 'Save & Continue to Songs';
      } else if (this.step === 'song-selection') {
        return 'Skip Song Selection';
      } else if (this.step === 'song-rating') {
        return 'Save & Continue';
      }
      return 'Continue';
    }
  },
  mounted() {
    // If an initial artist ID is provided, load that artist
    if (this.initialArtistId) {
      this.loadInitialArtist();
    }
  },
  methods: {
    async loadInitialArtist() {
      try {
        const response = await fetch(`/api/music/artists/${this.initialArtistId}`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          }
        });
        
        if (!response.ok) {
          throw new Error('Failed to load artist');
        }
        
        const artist = await response.json();
        this.selectedArtist = artist;
        this.goToStep('album-selection');
        this.loadArtistAlbums();
      } catch (error) {
        console.error('Error loading initial artist:', error);
      }
    },
    
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
      this.goToStep('album-selection');
      this.loadArtistAlbums();
    },
    
    skipArtistSelection() {
      this.$emit('skip');
    },

    async loadArtistAlbums() {
      this.isLoadingAlbums = true;
      
      try {
        const response = await fetch(`/api/music/artists/${this.selectedArtist.id}/albums`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          }
        });

        if (!response.ok) {
          throw new Error('Failed to load albums');
        }

        this.artistAlbums = await response.json();
      } catch (error) {
        console.error('Error loading albums:', error);
      } finally {
        this.isLoadingAlbums = false;
      }
    },

    selectAlbum(album) {
      this.selectedAlbum = album;
      this.goToStep('album-rating');
    },

    async saveAlbumRating() {
      try {
        const response = await fetch(`/api/music/curate`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          body: JSON.stringify({
            item_id: this.selectedAlbum.id,
            item_type: 'album',
            rating: this.albumRating,
            comment: this.albumComment,
            weighted_rank_percentage: this.albumRanking
          })
        });

        if (!response.ok) {
          throw new Error('Failed to save album rating');
        }

        // Add to curated albums
        this.curatedAlbums.push({
          id: this.selectedAlbum.id,
          title: this.selectedAlbum.title,
          rating: this.albumRating
        });

        // Reset album rating form
        this.albumRating = 0;
        this.albumComment = '';
        this.albumRanking = 50;
        
        // Load songs for this album
        this.goToStep('song-selection');
        this.loadAlbumSongs();
      } catch (error) {
        console.error('Error saving album rating:', error);
      }
    },

    async loadAlbumSongs() {
      this.isLoadingSongs = true;
      
      try {
        const response = await fetch(`/api/music/albums/${this.selectedAlbum.id}/tracks`, {
          headers: {
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          }
        });

        if (!response.ok) {
          throw new Error('Failed to load songs');
        }

        this.albumSongs = await response.json();
      } catch (error) {
        console.error('Error loading songs:', error);
      } finally {
        this.isLoadingSongs = false;
      }
    },

    selectSong(song) {
      this.selectedSong = song;
      this.goToStep('song-rating');
    },

    async saveSongRating() {
      try {
        const response = await fetch(`/api/music/curate`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${localStorage.getItem('access_token')}`
          },
          body: JSON.stringify({
            item_id: this.selectedSong.id,
            item_type: 'song',
            rating: this.songRating,
            comment: this.songComment,
            weighted_rank_percentage: this.songRanking
          })
        });

        if (!response.ok) {
          throw new Error('Failed to save song rating');
        }

        // Add to curated songs
        this.curatedSongs.push({
          id: this.selectedSong.id,
          title: this.selectedSong.title,
          rating: this.songRating
        });

        // Reset song rating form
        this.songRating = 0;
        this.songComment = '';
        this.songRanking = 50;
        
        // Go back to song selection to rate more songs
        this.goToStep('song-selection');
      } catch (error) {
        console.error('Error saving song rating:', error);
      }
    },

    goToSummary() {
      this.goToStep('summary');
    },

    finishCuration() {
      this.$emit('complete', {
        artist: this.selectedArtist,
        albums: this.curatedAlbums,
        songs: this.curatedSongs
      });
    },

    formatDuration(seconds) {
      if (!seconds) return '--:--';
      const minutes = Math.floor(seconds / 60);
      const remainingSeconds = seconds % 60;
      return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`;
    },

    goToStep(step) {
      this.stepHistory.push(this.step);
      this.step = step;
    },

    goBack() {
      if (this.stepHistory.length > 0) {
        this.step = this.stepHistory.pop();
      }
    },

    goNext() {
      if (this.step === 'artist-selection') {
        this.goToStep('album-selection');
        this.loadArtistAlbums();
      } else if (this.step === 'album-selection') {
        this.goToStep('song-selection');
      } else if (this.step === 'album-rating') {
        this.saveAlbumRating();
      } else if (this.step === 'song-selection') {
        this.goToSummary();
      } else if (this.step === 'song-rating') {
        this.saveSongRating();
      }
    }
  }
};
</script>

<style scoped>
.music-curation-module {
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
  padding: 20px;
  max-width: 600px;
  margin: 0 auto;
}

.module-header {
  margin-bottom: 20px;
  text-align: center;
}

.module-header h3 {
  font-size: 1.5rem;
  margin-bottom: 8px;
  color: #4f46e5;
}

.module-description {
  color: #6b7280;
  font-size: 0.9rem;
}

.step-container {
  margin-bottom: 20px;
}

.search-container {
  display: flex;
  margin-bottom: 15px;
}

.search-input {
  flex: 1;
  padding: 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px 0 0 6px;
  font-size: 1rem;
}

.search-button {
  padding: 10px 15px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 0 6px 6px 0;
  cursor: pointer;
}

.search-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

.results-container {
  max-height: 300px;
  overflow-y: auto;
  border: 1px solid #e5e7eb;
  border-radius: 6px;
}

.artist-card, .album-card, .song-card {
  display: flex;
  align-items: center;
  padding: 10px;
  border-bottom: 1px solid #e5e7eb;
  cursor: pointer;
  transition: background-color 0.2s;
}

.artist-card:hover, .album-card:hover, .song-card:hover {
  background-color: #f3f4f6;
}

.artist-image, .album-image {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  margin-right: 15px;
}

.artist-image img, .album-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.song-number {
  width: 30px;
  text-align: center;
  font-weight: bold;
  color: #6b7280;
}

.artist-info, .album-info, .song-info {
  flex: 1;
}

.artist-info h4, .album-info h4, .song-info h4 {
  margin: 0 0 5px 0;
  font-size: 1rem;
}

.artist-info p, .album-info p, .song-info p {
  margin: 0;
  font-size: 0.8rem;
  color: #6b7280;
}

.selected-artist, .selected-album, .selected-song {
  display: flex;
  align-items: center;
  padding: 10px;
  background-color: #f3f4f6;
  border-radius: 6px;
  margin-bottom: 15px;
}

.step-subtitle {
  font-size: 1.1rem;
  margin-bottom: 15px;
  color: #374151;
}

.rating-container {
  margin-bottom: 15px;
  text-align: center;
}

.star-rating {
  font-size: 2rem;
  margin-bottom: 5px;
}

.star {
  color: #d1d5db;
  cursor: pointer;
  transition: color 0.2s;
}

.star.active {
  color: #fbbf24;
}

.rating-text {
  font-size: 0.9rem;
  color: #6b7280;
}

.comment-container {
  margin-bottom: 15px;
}

.comment-container label {
  display: block;
  margin-bottom: 5px;
  font-size: 0.9rem;
  color: #374151;
}

.comment-container textarea {
  width: 100%;
  padding: 10px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  resize: vertical;
}

.ranking-container {
  margin-bottom: 15px;
}

.ranking-container label {
  display: block;
  margin-bottom: 5px;
  font-size: 0.9rem;
  color: #374151;
}

.ranking-container input {
  width: 100%;
  margin-bottom: 5px;
}

.ranking-value {
  font-size: 0.9rem;
  color: #6b7280;
}

.summary-container {
  border: 1px solid #e5e7eb;
  border-radius: 6px;
  padding: 15px;
}

.summary-artist {
  margin-bottom: 15px;
}

.summary-albums, .summary-songs {
  margin-bottom: 15px;
}

.summary-item {
  display: flex;
  justify-content: space-between;
  padding: 5px 0;
  border-bottom: 1px solid #f3f4f6;
}

.module-actions {
  display: flex;
  justify-content: space-between;
  margin-top: 20px;
}

.back-button, .skip-button {
  padding: 10px 15px;
  background-color: #9ca3af;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

.next-button, .finish-button {
  padding: 10px 15px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
}

.error-message {
  color: #ef4444;
  margin-top: 10px;
  font-size: 0.9rem;
}

.loading-message, .empty-message {
  text-align: center;
  padding: 20px;
  color: #6b7280;
  font-style: italic;
}
</style>
