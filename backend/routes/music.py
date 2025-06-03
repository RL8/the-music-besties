from fastapi import APIRouter, HTTPException, Depends, Request
from models.obsessions import Artist, Album, Song, MusicSearch, MusicSearchResult, UserArtist
from models.curations import CurationItem, CurationSubmission, CurationResponse
from utils.supabase_client import get_supabase_client
import logging
from typing import List

# Configure logging
logger = logging.getLogger(__name__)

# Initialize router
router = APIRouter(
    prefix="/music",
    tags=["music"],
    responses={404: {"description": "Not found"}},
)

# Get Supabase client
supabase = get_supabase_client()

# Helper function to get user ID from auth token
async def get_user_id(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
    
    token = auth_header.split(" ")[1]
    
    try:
        user_response = supabase.auth.get_user(token)
        if hasattr(user_response, 'error') and user_response.error:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        return user_response.user.id
    except Exception as e:
        logger.error(f"Error getting user ID: {str(e)}")
        raise HTTPException(status_code=401, detail="Authentication failed")

@router.post("/search", response_model=MusicSearchResult)
async def search_music(search: MusicSearch, user_id: str = Depends(get_user_id)):
    """
    Search for music artists from our database
    """
    try:
        logger.info(f"Searching for artists with query: {search.query}")
        
        # Search for artists in our database
        search_query = f"%{search.query}%"
        artists_response = supabase.table("artists").select("*").ilike("name", search_query).limit(10).execute()
        
        if hasattr(artists_response, 'error') and artists_response.error:
            logger.error(f"Database error: {artists_response.error}")
            raise HTTPException(status_code=500, detail="Database error")
        
        # Format the response
        artists = []
        for artist in artists_response.data:
            artists.append({
                "id": artist["id"],
                "name": artist["name"],
                "genre": artist.get("genre", ""),
                "image_url": artist.get("image_url", "")
            })
        
        return MusicSearchResult(items=artists)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error searching for music: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Search failed: {str(e)}")

@router.get("/artists/{artist_id}/albums", response_model=List[dict])
async def get_artist_albums(artist_id: str, user_id: str = Depends(get_user_id)):
    """
    Get albums for a specific artist from our database
    """
    try:
        logger.info(f"Getting albums for artist: {artist_id}")
        
        # Get albums from our database
        albums_response = supabase.table("albums").select("*").eq("artist_id", artist_id).execute()
        
        if hasattr(albums_response, 'error') and albums_response.error:
            logger.error(f"Database error: {albums_response.error}")
            raise HTTPException(status_code=500, detail="Database error")
        
        # Format the response
        albums = []
        for album in albums_response.data:
            albums.append({
                "id": album["id"],
                "title": album["title"],
                "release_year": album.get("release_year"),
                "image_url": album.get("image_url", "")
            })
        
        return albums
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting artist albums: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get albums: {str(e)}")

@router.get("/albums/{album_id}/tracks", response_model=List[dict])
async def get_album_tracks(album_id: str, user_id: str = Depends(get_user_id)):
    """
    Get tracks for a specific album from our database
    """
    try:
        logger.info(f"Getting tracks for album: {album_id}")
        
        # Get tracks from our database
        tracks_response = supabase.table("songs").select("*").eq("album_id", album_id).order("track_number").execute()
        
        if hasattr(tracks_response, 'error') and tracks_response.error:
            logger.error(f"Database error: {tracks_response.error}")
            raise HTTPException(status_code=500, detail="Database error")
        
        # Format the response
        tracks = []
        for track in tracks_response.data:
            tracks.append({
                "id": track["id"],
                "title": track["title"],
                "duration": track.get("duration"),
                "track_number": track.get("track_number")
            })
        
        return tracks
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting album tracks: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get tracks: {str(e)}")

@router.post("/set-primary-artist", response_model=dict)
async def set_primary_artist(user_artist: UserArtist, user_id: str = Depends(get_user_id)):
    """
    Set a user's primary artist obsession
    """
    try:
        logger.info(f"Setting primary artist for user: {user_id}")
        
        # Verify the user ID matches the authenticated user
        if user_id != user_artist.user_id:
            raise HTTPException(status_code=403, detail="You can only set your own primary artist")
        
        # Update profile
        profile_response = supabase.table("profiles").update({
            "primary_artist_id": user_artist.artist_id,
            "updated_at": "now()"
        }).eq("id", user_id).execute()
        
        if hasattr(profile_response, 'error') and profile_response.error:
            logger.error(f"Error updating profile: {profile_response.error}")
            raise HTTPException(status_code=500, detail="Error updating profile")
        
        return {"message": "Primary artist set successfully"}
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error setting primary artist: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to set primary artist: {str(e)}")

@router.post("/curate", response_model=CurationResponse)
async def curate_item(curation: CurationSubmission, user_id: str = Depends(get_user_id)):
    """
    Create or update a curation for an album or song
    """
    try:
        logger.info(f"Creating curation for user: {user_id}, item: {curation.item_id}, type: {curation.item_type}")
        
        # Verify item type is valid
        if curation.item_type not in ["album", "song"]:
            raise HTTPException(status_code=400, detail="Invalid item type. Must be 'album' or 'song'")
        
        # Check if curation already exists
        existing_curation = supabase.table("user_curations").select("*").eq("user_id", user_id).eq("curated_item_id", curation.item_id).eq("item_type", curation.item_type).execute()
        
        if hasattr(existing_curation, 'error') and existing_curation.error:
            logger.error(f"Error checking existing curation: {existing_curation.error}")
            raise HTTPException(status_code=500, detail="Error checking existing curation")
        
        curation_data = {
            "user_id": user_id,
            "curated_item_id": curation.item_id,
            "item_type": curation.item_type,
            "rating": curation.rating,
            "comment": curation.comment,
            "weighted_rank_percentage": curation.weighted_rank_percentage,
            "updated_at": "now()"
        }
        
        if existing_curation.data:
            # Update existing curation
            curation_id = existing_curation.data[0]["id"]
            response = supabase.table("user_curations").update(curation_data).eq("id", curation_id).execute()
            message = "Curation updated successfully"
        else:
            # Create new curation
            response = supabase.table("user_curations").insert(curation_data).execute()
            message = "Curation created successfully"
        
        if hasattr(response, 'error') and response.error:
            logger.error(f"Error saving curation: {response.error}")
            raise HTTPException(status_code=500, detail="Error saving curation")
        
        curation_id = response.data[0]["id"]
        
        return CurationResponse(
            id=curation_id,
            message=message,
            curation=CurationItem(
                id=curation_id,
                user_id=user_id,
                curated_item_id=curation.item_id,
                item_type=curation.item_type,
                rating=curation.rating,
                comment=curation.comment,
                weighted_rank_percentage=curation.weighted_rank_percentage
            )
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating curation: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to create curation: {str(e)}")

@router.get("/curations", response_model=List[CurationItem])
async def get_user_curations(user_id: str = Depends(get_user_id)):
    """
    Get all curations for the authenticated user
    """
    try:
        logger.info(f"Getting curations for user: {user_id}")
        
        response = supabase.table("user_curations").select("*").eq("user_id", user_id).execute()
        
        if hasattr(response, 'error') and response.error:
            logger.error(f"Error getting curations: {response.error}")
            raise HTTPException(status_code=500, detail="Error getting curations")
        
        return [CurationItem(**curation) for curation in response.data]
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting curations: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get curations: {str(e)}")
