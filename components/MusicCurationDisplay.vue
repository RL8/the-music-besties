<template>
  <div class="music-curation-display">
    <div v-if="isLoading" class="loading-state">
      <p>Loading your music curation...</p>
    </div>
    
    <div v-else-if="error" class="error-state">
      <p>{{ error }}</p>
      <button @click="loadCuration" class="retry-button">Retry</button>
    </div>
    
    <div v-else-if="!hasContent" class="empty-state">
      <p>You haven't curated any music yet.</p>
      <p class="prompt-text">Tell the AI about your favorite artist to get started!</p>
    </div>
    
    <div v-else class="curation-content">
      <!-- Artist Section -->
      <div class="artist-section" v-if="artist">
        <div class="section-header">
          <h3>My Artist Obsession</h3>
        </div>
        
        <div class="artist-card">
          <div class="artist-image">
            <img :src="artist.image_url || '/images/default-artist.png'" :alt="artist.name">
          </div>
          <div class="artist-info">
            <h4>{{ artist.name }}</h4>
            <p v-if="artist.genre">{{ artist.genre }}</p>
          </div>
        </div>
      </div>
      
      <!-- Albums Section -->
      <div class="albums-section" v-if="albums && albums.length > 0">
        <div class="section-header">
          <h3>My Top Albums</h3>
        </div>
        
        <div class="albums-list">
          <div v-for="album in sortedAlbums" :key="album.id" class="album-item">
            <div class="album-image">
              <img :src="album.image_url || '/images/default-album.png'" :alt="album.title">
            </div>
            <div class="album-details">
              <h4>{{ album.title }}</h4>
              <div class="album-meta">
                <div class="rating">
                  <span class="stars">{{ getStars(album.rating) }}</span>
                  <span class="rating-value">{{ album.rating }}/5</span>
                </div>
                <div v-if="album.weighted_rank_percentage" class="rank">
                  <span class="rank-label">Importance:</span>
                  <span class="rank-value">{{ album.weighted_rank_percentage }}%</span>
                </div>
              </div>
              <p v-if="album.comment" class="comment">{{ truncateText(album.comment, 100) }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Songs Section -->
      <div class="songs-section" v-if="songs && songs.length > 0">
        <div class="section-header">
          <h3>My Top Songs</h3>
        </div>
        
        <div class="songs-list">
          <div v-for="song in sortedSongs" :key="song.id" class="song-item">
            <div class="song-details">
              <h4>{{ song.title }}</h4>
              <p v-if="song.album_title" class="album-title">from {{ song.album_title }}</p>
              <div class="song-meta">
                <div class="rating">
                  <span class="stars">{{ getStars(song.rating) }}</span>
                  <span class="rating-value">{{ song.rating }}/5</span>
                </div>
                <div v-if="song.weighted_rank_percentage" class="rank">
                  <span class="rank-label">Importance:</span>
                  <span class="rank-value">{{ song.weighted_rank_percentage }}%</span>
                </div>
              </div>
              <p v-if="song.comment" class="comment">{{ truncateText(song.comment, 100) }}</p>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Share Section -->
      <div class="share-section">
        <button @click="generateShareLink" class="share-button" :disabled="isGeneratingLink">
          {{ isGeneratingLink ? 'Generating...' : 'Get Share Link' }}
        </button>
        
        <div v-if="shareLink" class="share-link-container">
          <p>Share your music curation with friends:</p>
          <div class="link-display">
            <input type="text" readonly :value="shareLink" ref="linkInput" class="link-input">
            <button @click="copyLink" class="copy-button">
              {{ copied ? 'Copied!' : 'Copy' }}
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { useSupabase } from '~/services/supabase';

export default {
  name: 'MusicCurationDisplay',
  props: {
    userId: {
      type: String,
      required: true
    }
  },
  data() {
    return {
      isLoading: true,
      error: null,
      artist: null,
      albums: [],
      songs: [],
      shareLink: null,
      isGeneratingLink: false,
      copied: false
    };
  },
  computed: {
    hasContent() {
      return this.artist || (this.albums && this.albums.length > 0) || (this.songs && this.songs.length > 0);
    },
    sortedAlbums() {
      return [...this.albums].sort((a, b) => {
        // Sort by weighted rank first (if available)
        if (a.weighted_rank_percentage && b.weighted_rank_percentage) {
          return b.weighted_rank_percentage - a.weighted_rank_percentage;
        }
        // Then by rating
        return b.rating - a.rating;
      });
    },
    sortedSongs() {
      return [...this.songs].sort((a, b) => {
        // Sort by weighted rank first (if available)
        if (a.weighted_rank_percentage && b.weighted_rank_percentage) {
          return b.weighted_rank_percentage - a.weighted_rank_percentage;
        }
        // Then by rating
        return b.rating - a.rating;
      });
    }
  },
  mounted() {
    this.loadCuration();
  },
  methods: {
    async loadCuration() {
      this.isLoading = true;
      this.error = null;
      
      try {
        const supabase = useSupabase();
        
        // Get user profile to find primary artist
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('*')
          .eq('id', this.userId)
          .single();
        
        if (profileError) throw profileError;
        
        // If user has a primary artist, load it
        if (profile.primary_artist_id) {
          const { data: artistData, error: artistError } = await supabase
            .from('artists')
            .select('*')
            .eq('id', profile.primary_artist_id)
            .single();
          
          if (artistError) throw artistError;
          this.artist = artistData;
        }
        
        // Load user's curated albums
        const { data: albumCurations, error: albumsError } = await supabase
          .from('user_curations')
          .select('*, albums(*)')
          .eq('user_id', this.userId)
          .eq('item_type', 'album');
        
        if (albumsError) throw albumsError;
        
        // Format album data
        this.albums = albumCurations.map(curation => ({
          id: curation.curated_item_id,
          title: curation.albums?.title || 'Unknown Album',
          image_url: curation.albums?.image_url,
          rating: curation.rating,
          comment: curation.comment,
          weighted_rank_percentage: curation.weighted_rank_percentage
        }));
        
        // Load user's curated songs
        const { data: songCurations, error: songsError } = await supabase
          .from('user_curations')
          .select('*, songs(*)')
          .eq('user_id', this.userId)
          .eq('item_type', 'song');
        
        if (songsError) throw songsError;
        
        // Format song data
        this.songs = await Promise.all(songCurations.map(async curation => {
          let albumTitle = 'Unknown Album';
          
          // Get album title if available
          if (curation.songs?.album_id) {
            const { data: albumData } = await supabase
              .from('albums')
              .select('title')
              .eq('id', curation.songs.album_id)
              .single();
            
            if (albumData) {
              albumTitle = albumData.title;
            }
          }
          
          return {
            id: curation.curated_item_id,
            title: curation.songs?.title || 'Unknown Song',
            album_title: albumTitle,
            rating: curation.rating,
            comment: curation.comment,
            weighted_rank_percentage: curation.weighted_rank_percentage
          };
        }));
      } catch (error) {
        console.error('Error loading music curation:', error);
        this.error = 'Failed to load your music curation. Please try again.';
      } finally {
        this.isLoading = false;
      }
    },
    
    getStars(rating) {
      const fullStars = Math.floor(rating);
      const halfStar = rating % 1 >= 0.5;
      const emptyStars = 5 - fullStars - (halfStar ? 1 : 0);
      
      let stars = '★'.repeat(fullStars);
      if (halfStar) stars += '½';
      stars += '☆'.repeat(emptyStars);
      
      return stars;
    },
    
    truncateText(text, maxLength) {
      if (!text) return '';
      if (text.length <= maxLength) return text;
      return text.substring(0, maxLength) + '...';
    },
    
    async generateShareLink() {
      if (!this.hasContent) return;
      
      this.isGeneratingLink = true;
      
      try {
        // In a real implementation, this would generate a unique link on the backend
        // For now, we'll simulate it with a placeholder
        
        // Generate a simple hash from the user ID
        const hash = btoa(this.userId).replace(/[^a-zA-Z0-9]/g, '').substring(0, 8);
        
        // Wait a moment to simulate API call
        await new Promise(resolve => setTimeout(resolve, 1000));
        
        this.shareLink = `https://musicbesties.app/share/${hash}`;
      } catch (error) {
        console.error('Error generating share link:', error);
      } finally {
        this.isGeneratingLink = false;
      }
    },
    
    copyLink() {
      if (!this.shareLink) return;
      
      const linkInput = this.$refs.linkInput;
      linkInput.select();
      document.execCommand('copy');
      
      this.copied = true;
      setTimeout(() => {
        this.copied = false;
      }, 2000);
    }
  }
};
</script>

<style scoped>
.music-curation-display {
  padding: 15px;
  background-color: white;
  border-radius: 12px;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
}

.loading-state, .error-state, .empty-state {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 200px;
  text-align: center;
  color: #6b7280;
}

.prompt-text {
  font-style: italic;
  font-size: 0.9rem;
  margin-top: 8px;
}

.retry-button {
  margin-top: 10px;
  padding: 6px 12px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.section-header {
  margin-bottom: 15px;
  border-bottom: 1px solid #e5e7eb;
  padding-bottom: 8px;
}

.section-header h3 {
  margin: 0;
  font-size: 1.2rem;
  color: #4f46e5;
}

/* Artist styles */
.artist-section {
  margin-bottom: 25px;
}

.artist-card {
  display: flex;
  align-items: center;
  padding: 12px;
  background-color: #f9fafb;
  border-radius: 8px;
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
  color: #6b7280;
}

/* Albums styles */
.albums-section {
  margin-bottom: 25px;
}

.albums-list {
  max-height: 300px;
  overflow-y: auto;
}

.album-item {
  display: flex;
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f3f4f6;
}

.album-image {
  width: 50px;
  height: 50px;
  border-radius: 4px;
  overflow: hidden;
  margin-right: 12px;
}

.album-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.album-details {
  flex: 1;
}

.album-details h4 {
  margin: 0 0 5px 0;
  font-size: 1rem;
}

.album-meta, .song-meta {
  display: flex;
  align-items: center;
  margin-bottom: 5px;
  font-size: 0.85rem;
}

.rating {
  display: flex;
  align-items: center;
  margin-right: 15px;
}

.stars {
  color: #fbbf24;
  margin-right: 5px;
}

.rating-value {
  color: #6b7280;
}

.rank {
  display: flex;
  align-items: center;
}

.rank-label {
  color: #6b7280;
  margin-right: 5px;
}

.rank-value {
  font-weight: bold;
  color: #4b5563;
}

.comment {
  font-size: 0.85rem;
  color: #6b7280;
  font-style: italic;
  margin: 5px 0 0 0;
}

/* Songs styles */
.songs-section {
  margin-bottom: 25px;
}

.songs-list {
  max-height: 300px;
  overflow-y: auto;
}

.song-item {
  margin-bottom: 15px;
  padding-bottom: 15px;
  border-bottom: 1px solid #f3f4f6;
}

.song-details h4 {
  margin: 0 0 2px 0;
  font-size: 1rem;
}

.album-title {
  font-size: 0.8rem;
  color: #6b7280;
  margin: 0 0 5px 0;
}

/* Share section */
.share-section {
  padding-top: 15px;
  border-top: 1px solid #e5e7eb;
}

.share-button {
  width: 100%;
  padding: 10px;
  background-color: #4f46e5;
  color: white;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-weight: bold;
}

.share-button:disabled {
  background-color: #9ca3af;
  cursor: not-allowed;
}

.share-link-container {
  margin-top: 15px;
}

.share-link-container p {
  margin: 0 0 8px 0;
  font-size: 0.9rem;
}

.link-display {
  display: flex;
}

.link-input {
  flex: 1;
  padding: 8px;
  border: 1px solid #d1d5db;
  border-radius: 4px 0 0 4px;
  font-size: 0.9rem;
}

.copy-button {
  padding: 8px 12px;
  background-color: #4b5563;
  color: white;
  border: none;
  border-radius: 0 4px 4px 0;
  cursor: pointer;
}
</style>
