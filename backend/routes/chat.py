from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import os
import json
from datetime import datetime

# Import Supabase client
from utils.supabase import get_supabase_client
from models.auth import User, get_current_user

# Create router
router = APIRouter(
    prefix="/chat",
    tags=["chat"],
    responses={404: {"description": "Not found"}},
)

# Models
class ChatMessage(BaseModel):
    content: str
    sender: str
    timestamp: Optional[datetime] = None
    metadata: Optional[Dict[str, Any]] = None

class ChatRequest(BaseModel):
    message: str
    user_id: Optional[str] = None
    conversation_id: Optional[str] = None
    context: Optional[Dict[str, Any]] = None

class ChatResponse(BaseModel):
    message: ChatMessage
    suggested_actions: Optional[List[Dict[str, Any]]] = None
    context_modules: Optional[List[Dict[str, Any]]] = None
    sideboard_content: Optional[Dict[str, Any]] = None

# Routes
@router.post("/", response_model=ChatResponse)
async def process_chat_message(
    request: ChatRequest,
    current_user: User = Depends(get_current_user)
):
    """
    Process a chat message and return an AI response
    """
    # Get user ID from authenticated user or request
    user_id = current_user.id if current_user else request.user_id
    
    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required for chat"
        )
    
    # Get Supabase client
    supabase = get_supabase_client()
    
    # Get user profile information
    try:
        profile_response = supabase.table("profiles").select("*").eq("id", user_id).execute()
        profile = profile_response.data[0] if profile_response.data else None
    except Exception as e:
        print(f"Error fetching profile: {e}")
        profile = None
    
    # Process the message (in a real implementation, this would call an LLM)
    # For now, we'll use a simple rule-based approach
    user_message = request.message.lower()
    
    # Default response
    ai_response = "I'm your AI concierge for music curation. How can I help you today?"
    suggested_actions = []
    context_modules = []
    sideboard_content = None
    
    # Check if user has a primary artist
    has_primary_artist = profile and profile.get("primary_artist_id")
    
    # Handle different message intents
    if any(word in user_message for word in ["hello", "hi", "hey", "greetings"]):
        ai_response = f"Hello! Welcome to Music Besties. I'm here to help you curate your music obsession."
        
        if not has_primary_artist:
            ai_response += " Would you like to start by telling me about your favorite artist?"
            suggested_actions = [
                {"id": "start_curation", "label": "Start Music Curation", "action": "TRIGGER_MODULE", "module": "music_curation"}
            ]
    
    elif any(word in user_message for word in ["artist", "music", "favorite", "obsession"]):
        if "who" in user_message or "what" in user_message:
            if has_primary_artist:
                # Get artist information
                try:
                    artist_response = supabase.table("artists").select("*").eq("id", profile.get("primary_artist_id")).execute()
                    artist = artist_response.data[0] if artist_response.data else None
                    
                    if artist:
                        ai_response = f"Your current music obsession is {artist.get('name')}. Would you like to see your curated albums and songs?"
                        sideboard_content = {
                            "type": "music_curation",
                            "user_id": user_id
                        }
                    else:
                        ai_response = "I couldn't find information about your current music obsession. Would you like to set one?"
                        suggested_actions = [
                            {"id": "start_curation", "label": "Set Music Obsession", "action": "TRIGGER_MODULE", "module": "music_curation"}
                        ]
                except Exception as e:
                    print(f"Error fetching artist: {e}")
                    ai_response = "I encountered an error retrieving your music obsession. Would you like to set a new one?"
            else:
                ai_response = "You haven't set a music obsession yet. Would you like to do that now?"
                suggested_actions = [
                    {"id": "start_curation", "label": "Set Music Obsession", "action": "TRIGGER_MODULE", "module": "music_curation"}
                ]
        else:
            ai_response = "I'd love to help you curate your music obsession. Let's get started!"
            context_modules = [
                {
                    "id": "music_curation_module",
                    "type": "music_curation",
                    "title": "Music Curation",
                    "description": "Let's find your music obsession!"
                }
            ]
    
    elif any(word in user_message for word in ["profile", "view", "show", "see", "curation"]):
        if has_primary_artist:
            ai_response = "I've opened your music curation in the sideboard. Take a look!"
            sideboard_content = {
                "type": "music_curation",
                "user_id": user_id
            }
        else:
            ai_response = "You don't have any music curated yet. Would you like to start now?"
            suggested_actions = [
                {"id": "start_curation", "label": "Start Music Curation", "action": "TRIGGER_MODULE", "module": "music_curation"}
            ]
    
    elif any(word in user_message for word in ["help", "how", "what can you do"]):
        ai_response = """I can help you with the following:
1. Curate your music obsession by selecting your favorite artist, albums, and songs
2. View your music curation profile
3. Get recommendations based on your music taste
4. Find your music tribe (coming soon!)

What would you like to do?"""
        suggested_actions = [
            {"id": "start_curation", "label": "Curate Music", "action": "TRIGGER_MODULE", "module": "music_curation"},
            {"id": "view_profile", "label": "View Profile", "action": "SHOW_SIDEBOARD", "content_type": "music_curation"}
        ]
    
    # Create response
    response = ChatResponse(
        message=ChatMessage(
            content=ai_response,
            sender="ai",
            timestamp=datetime.now(),
            metadata={"processed_by": "rule_based_system"}
        ),
        suggested_actions=suggested_actions,
        context_modules=context_modules,
        sideboard_content=sideboard_content
    )
    
    # In a production system, we would store the conversation history in the database
    
    return response

@router.post("/init", response_model=ChatResponse)
async def initialize_chat(
    user_id: Optional[str] = None,
    current_user: User = Depends(get_current_user)
):
    """
    Initialize a new chat conversation
    """
    # Get user ID from authenticated user or request
    user_id = current_user.id if current_user else user_id
    
    # Create welcome message
    welcome_message = ChatMessage(
        content="👋 Hi there! I'm your AI concierge for Music Besties. I'm here to help you curate your music obsession and find your music tribe. What would you like to do today?",
        sender="ai",
        timestamp=datetime.now()
    )
    
    # Create suggested actions
    suggested_actions = [
        {"id": "start_curation", "label": "Curate Music", "action": "TRIGGER_MODULE", "module": "music_curation"},
        {"id": "view_profile", "label": "View Profile", "action": "SHOW_SIDEBOARD", "content_type": "music_curation"}
    ]
    
    # Create response
    response = ChatResponse(
        message=welcome_message,
        suggested_actions=suggested_actions
    )
    
    return response
