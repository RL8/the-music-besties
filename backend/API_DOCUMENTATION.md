# The Music Besties API Documentation

This document provides details about the backend API endpoints for The Music Besties application.

## Base URL

For local development: `http://localhost:8000`

## Authentication

Most endpoints require authentication using a JWT token provided by Supabase. Include the token in the `Authorization` header:

```
Authorization: Bearer <your_jwt_token>
```

## Endpoints

### Health Check

```
GET /health
```

Check if the API is running.

**Response**:
```json
{
  "status": "healthy"
}
```

### Root

```
GET /
```

Basic information about the API.

**Response**:
```json
{
  "message": "Welcome to The Music Besties API"
}
```

## Authentication Endpoints

### Register User

```
POST /api/auth/register
```

Register a new user.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securepassword",
  "username": "username"
}
```

**Response**:
```json
{
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "user": {
    "id": "user_id",
    "username": "username",
    "avatar_url": null,
    "primary_artist_id": null,
    "created_at": "timestamp",
    "updated_at": "timestamp"
  },
  "message": "User registered successfully"
}
```

### Login User

```
POST /api/auth/login
```

Login an existing user.

**Request Body**:
```json
{
  "email": "user@example.com",
  "password": "securepassword"
}
```

**Response**:
```json
{
  "access_token": "jwt_token",
  "refresh_token": "refresh_token",
  "user": {
    "id": "user_id",
    "username": "username",
    "avatar_url": null,
    "primary_artist_id": null,
    "created_at": "timestamp",
    "updated_at": "timestamp"
  },
  "message": "Login successful"
}
```

### Get User Profile

```
GET /api/auth/profile
```

Get the current user's profile.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Response**:
```json
{
  "id": "user_id",
  "username": "username",
  "avatar_url": null,
  "primary_artist_id": null,
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### Update User Profile

```
PUT /api/auth/profile
```

Update the current user's profile.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Request Body**:
```json
{
  "username": "new_username",
  "avatar_url": "https://example.com/avatar.jpg"
}
```

**Response**:
```json
{
  "id": "user_id",
  "username": "new_username",
  "avatar_url": "https://example.com/avatar.jpg",
  "primary_artist_id": null,
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Music Endpoints

### Search Artists

```
GET /api/music/artists/search?query={query}
```

Search for artists by name.

**Parameters**:
- `query` (string): Search term

**Response**:
```json
[
  {
    "id": "artist_id",
    "name": "Artist Name",
    "genre": "Genre",
    "image_url": "https://example.com/artist.jpg",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
]
```

### Get Artist Details

```
GET /api/music/artists/{artist_id}
```

Get details for a specific artist.

**Parameters**:
- `artist_id` (string): ID of the artist

**Response**:
```json
{
  "id": "artist_id",
  "name": "Artist Name",
  "genre": "Genre",
  "image_url": "https://example.com/artist.jpg",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### Get Artist Albums

```
GET /api/music/artists/{artist_id}/albums
```

Get albums for a specific artist.

**Parameters**:
- `artist_id` (string): ID of the artist

**Response**:
```json
[
  {
    "id": "album_id",
    "title": "Album Title",
    "artist_id": "artist_id",
    "release_year": 2023,
    "image_url": "https://example.com/album.jpg",
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
]
```

### Get Album Details

```
GET /api/music/albums/{album_id}
```

Get details for a specific album.

**Parameters**:
- `album_id` (string): ID of the album

**Response**:
```json
{
  "id": "album_id",
  "title": "Album Title",
  "artist_id": "artist_id",
  "artist_name": "Artist Name",
  "release_year": 2023,
  "image_url": "https://example.com/album.jpg",
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

### Get Album Songs

```
GET /api/music/albums/{album_id}/songs
```

Get songs for a specific album.

**Parameters**:
- `album_id` (string): ID of the album

**Response**:
```json
[
  {
    "id": "song_id",
    "title": "Song Title",
    "album_id": "album_id",
    "artist_id": "artist_id",
    "track_number": 1,
    "duration": 180,
    "created_at": "timestamp",
    "updated_at": "timestamp"
  }
]
```

### Get Song Details

```
GET /api/music/songs/{song_id}
```

Get details for a specific song.

**Parameters**:
- `song_id` (string): ID of the song

**Response**:
```json
{
  "id": "song_id",
  "title": "Song Title",
  "album_id": "album_id",
  "album_title": "Album Title",
  "artist_id": "artist_id",
  "artist_name": "Artist Name",
  "track_number": 1,
  "duration": 180,
  "created_at": "timestamp",
  "updated_at": "timestamp"
}
```

## Curation Endpoints

### Set Primary Artist

```
POST /api/music/curations/set-primary-artist
```

Set a user's primary artist.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Request Body**:
```json
{
  "artist_id": "artist_id"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Primary artist set successfully"
}
```

### Rate Album

```
POST /api/music/curations/rate-album
```

Rate an album.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Request Body**:
```json
{
  "album_id": "album_id",
  "rating": 4.5,
  "comment": "Great album!",
  "weighted_rank_percentage": 85
}
```

**Response**:
```json
{
  "success": true,
  "message": "Album rated successfully",
  "curation_id": "curation_id"
}
```

### Rate Song

```
POST /api/music/curations/rate-song
```

Rate a song.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Request Body**:
```json
{
  "song_id": "song_id",
  "rating": 4.5,
  "comment": "Great song!",
  "weighted_rank_percentage": 90
}
```

**Response**:
```json
{
  "success": true,
  "message": "Song rated successfully",
  "curation_id": "curation_id"
}
```

### Get User Curation

```
GET /api/music/curations/user
```

Get a user's music curation.

**Headers**:
- `Authorization: Bearer <jwt_token>`

**Response**:
```json
{
  "artist": {
    "id": "artist_id",
    "name": "Artist Name",
    "genre": "Genre",
    "image_url": "https://example.com/artist.jpg"
  },
  "albums": [
    {
      "id": "album_id",
      "title": "Album Title",
      "image_url": "https://example.com/album.jpg",
      "rating": 4.5,
      "comment": "Great album!",
      "weighted_rank_percentage": 85
    }
  ],
  "songs": [
    {
      "id": "song_id",
      "title": "Song Title",
      "album_title": "Album Title",
      "rating": 4.5,
      "comment": "Great song!",
      "weighted_rank_percentage": 90
    }
  ]
}
```

## Chat Endpoints

### Initialize Chat

```
POST /api/chat/init
```

Initialize a new chat conversation.

**Headers**:
- `Authorization: Bearer <jwt_token>` (optional)

**Response**:
```json
{
  "message": {
    "content": "👋 Hi there! I'm your AI concierge for Music Besties. I'm here to help you curate your music obsession and find your music tribe. What would you like to do today?",
    "sender": "ai",
    "timestamp": "timestamp"
  },
  "suggested_actions": [
    {
      "id": "start_curation",
      "label": "Curate Music",
      "action": "TRIGGER_MODULE",
      "module": "music_curation"
    },
    {
      "id": "view_profile",
      "label": "View Profile",
      "action": "SHOW_SIDEBOARD",
      "content_type": "music_curation"
    }
  ]
}
```

### Send Chat Message

```
POST /api/chat
```

Send a message to the chat.

**Headers**:
- `Authorization: Bearer <jwt_token>` (optional)

**Request Body**:
```json
{
  "message": "I want to curate my music obsession",
  "user_id": "user_id",
  "conversation_id": "conversation_id",
  "context": {}
}
```

**Response**:
```json
{
  "message": {
    "content": "I'd love to help you curate your music obsession. Let's get started!",
    "sender": "ai",
    "timestamp": "timestamp"
  },
  "context_modules": [
    {
      "id": "music_curation_module",
      "type": "music_curation",
      "title": "Music Curation",
      "description": "Let's find your music obsession!"
    }
  ]
}
```

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request

```json
{
  "detail": "Invalid request parameters"
}
```

### 401 Unauthorized

```json
{
  "detail": "Not authenticated"
}
```

### 403 Forbidden

```json
{
  "detail": "Not authorized to access this resource"
}
```

### 404 Not Found

```json
{
  "detail": "Resource not found"
}
```

### 500 Internal Server Error

```json
{
  "detail": "Internal server error"
}
```
