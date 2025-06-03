import { useRuntimeConfig } from 'nuxt/app';

/**
 * Service for interacting with external APIs for music data
 */

// Cache for API responses to avoid hitting rate limits
const cache = {
  spotify: new Map()
};

// Helper to get cached data or fetch new data
const getOrFetch = async (cacheKey, cacheName, fetchFn) => {
  const cacheStore = cache[cacheName];
  
  if (cacheStore.has(cacheKey)) {
    return cacheStore.get(cacheKey);
  }
  
  const data = await fetchFn();
  cacheStore.set(cacheKey, data);
  return data;
};

/**
 * Spotify API service
 */
export const spotifyApi = {
  // Get Spotify API token
  getToken: async () => {
    try {
      // Note: In a real implementation, this would use a server-side endpoint
      // to securely fetch a token using client credentials flow
      // For Phase 1, we'll assume the token is fetched from the backend
      
      const response = await fetch('/api/spotify/token', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        }
      });
      
      if (!response.ok) {
        throw new Error(`Failed to get Spotify token: ${response.status}`);
      }
      
      const data = await response.json();
      return data.access_token;
    } catch (error) {
      console.error('Error getting Spotify token:', error);
      throw error;
    }
  },
  
  // Search for artists
  searchArtists: async (query) => {
    return getOrFetch(`artist:${query}`, 'spotify', async () => {
      try {
        const token = await spotifyApi.getToken();
        
        const response = await fetch(`https://api.spotify.com/v1/search?q=${encodeURIComponent(query)}&type=artist&limit=10`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (!response.ok) {
          throw new Error(`Spotify API error: ${response.status}`);
        }
        
        const data = await response.json();
        return data.artists.items.map(artist => ({
          id: artist.id,
          name: artist.name,
          genre: artist.genres?.[0] || '',
          image_url: artist.images?.[0]?.url || '',
          spotify_id: artist.id
        }));
      } catch (error) {
        console.error('Error searching Spotify artists:', error);
        throw error;
      }
    });
  },
  
  // Get artist albums
  getArtistAlbums: async (artistId) => {
    return getOrFetch(`albums:${artistId}`, 'spotify', async () => {
      try {
        const token = await spotifyApi.getToken();
        
        const response = await fetch(`https://api.spotify.com/v1/artists/${artistId}/albums?include_groups=album&limit=50`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (!response.ok) {
          throw new Error(`Spotify API error: ${response.status}`);
        }
        
        const data = await response.json();
        return data.items.map(album => ({
          id: album.id,
          title: album.name,
          release_year: album.release_date ? parseInt(album.release_date.split('-')[0]) : null,
          image_url: album.images?.[0]?.url || '',
          spotify_id: album.id
        }));
      } catch (error) {
        console.error('Error getting artist albums:', error);
        throw error;
      }
    });
  },
  
  // Get album tracks
  getAlbumTracks: async (albumId) => {
    return getOrFetch(`tracks:${albumId}`, 'spotify', async () => {
      try {
        const token = await spotifyApi.getToken();
        
        const response = await fetch(`https://api.spotify.com/v1/albums/${albumId}/tracks?limit=50`, {
          method: 'GET',
          headers: {
            'Authorization': `Bearer ${token}`
          }
        });
        
        if (!response.ok) {
          throw new Error(`Spotify API error: ${response.status}`);
        }
        
        const data = await response.json();
        return data.items.map(track => ({
          id: track.id,
          title: track.name,
          duration: track.duration_ms ? Math.floor(track.duration_ms / 1000) : null,
          track_number: track.track_number,
          spotify_id: track.id
        }));
      } catch (error) {
        console.error('Error getting album tracks:', error);
        throw error;
      }
    });
  }
};

export default {
  spotify: spotifyApi
};
