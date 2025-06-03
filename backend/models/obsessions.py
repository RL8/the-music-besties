from pydantic import BaseModel
from typing import Optional, List

class Artist(BaseModel):
    id: Optional[str] = None
    name: str
    genre: Optional[str] = None
    image_url: Optional[str] = None

class Album(BaseModel):
    id: Optional[str] = None
    artist_id: str
    title: str
    release_year: Optional[int] = None
    image_url: Optional[str] = None

class Song(BaseModel):
    id: Optional[str] = None
    album_id: str
    title: str
    duration: Optional[int] = None  # in seconds
    track_number: Optional[int] = None

class MusicSearch(BaseModel):
    query: str

class MusicSearchResult(BaseModel):
    items: List[dict]  # List of artists

class UserArtist(BaseModel):
    user_id: str
    artist_id: str
