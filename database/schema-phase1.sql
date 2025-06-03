-- Music Besties Phase 1 Database Schema
-- This script creates the necessary tables for user profiles, artists, albums, songs, and user curations

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profiles table (extends auth.users)
CREATE TABLE IF NOT EXISTS profiles (
  id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  primary_artist_id UUID,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Artists table
CREATE TABLE IF NOT EXISTS artists (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name TEXT NOT NULL,
  genre TEXT,
  image_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Albums table
CREATE TABLE IF NOT EXISTS albums (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  artist_id UUID REFERENCES artists(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  release_year INTEGER,
  image_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Songs table
CREATE TABLE IF NOT EXISTS songs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  album_id UUID REFERENCES albums(id) ON DELETE CASCADE NOT NULL,
  title TEXT NOT NULL,
  duration INTEGER, -- in seconds
  track_number INTEGER,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User Curations table
CREATE TABLE IF NOT EXISTS user_curations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE NOT NULL,
  curated_item_id UUID NOT NULL,
  item_type TEXT NOT NULL CHECK (item_type IN ('album', 'song')),
  rating INTEGER CHECK (rating BETWEEN 1 AND 5),
  comment TEXT,
  weighted_rank_percentage INTEGER CHECK (weighted_rank_percentage BETWEEN 0 AND 100),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_albums_artist_id ON albums(artist_id);
CREATE INDEX IF NOT EXISTS idx_songs_album_id ON songs(album_id);
CREATE INDEX IF NOT EXISTS idx_user_curations_user_id ON user_curations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_curations_item_type ON user_curations(item_type);

-- Set up Row Level Security (RLS) policies

-- Profiles: Users can read all profiles but only update their own
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY profiles_select_policy ON profiles 
  FOR SELECT USING (true);

CREATE POLICY profiles_insert_policy ON profiles 
  FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY profiles_update_policy ON profiles 
  FOR UPDATE USING (auth.uid() = id);

-- User Curations: Users can read all curations but only create/update their own
ALTER TABLE user_curations ENABLE ROW LEVEL SECURITY;

CREATE POLICY user_curations_select_policy ON user_curations 
  FOR SELECT USING (true);

CREATE POLICY user_curations_insert_policy ON user_curations 
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY user_curations_update_policy ON user_curations 
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY user_curations_delete_policy ON user_curations 
  FOR DELETE USING (auth.uid() = user_id);

-- Create triggers for updated_at timestamps
CREATE OR REPLACE FUNCTION update_modified_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_modtime
BEFORE UPDATE ON profiles
FOR EACH ROW EXECUTE FUNCTION update_modified_column();

CREATE TRIGGER update_user_curations_modtime
BEFORE UPDATE ON user_curations
FOR EACH ROW EXECUTE FUNCTION update_modified_column();
