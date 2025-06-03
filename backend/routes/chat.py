from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import os
import json
from datetime import datetime

# Import Supabase client and LLM integration
from utils.supabase import get_supabase_client
from utils.llm import generate_response, LLMResponse
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
    message: str
    suggested_actions: Optional[List[Dict[str, Any]]] = None
    context_modules: Optional[List[Dict[str, Any]]] = None
    sideboard_content: Optional[Dict[str, Any]] = None
    component_trigger: Optional[Dict[str, Any]] = None

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
    
    # Get conversation history (simplified - in a real app, you'd fetch from a database)
    conversation_history = request.context.get("conversation_history") if request.context else []
    
    # Generate response using LLM
    llm_response = generate_response(
        message=request.message,
        user_profile=profile,
        conversation_history=conversation_history
    )
    
    # Create response
    response = ChatResponse(
        message=llm_response.message,
        suggested_actions=llm_response.suggested_actions,
        context_modules=llm_response.context_modules,
        sideboard_content=llm_response.sideboard_content,
        component_trigger=None  # Add component triggers if needed
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
    
    # Get Supabase client
    supabase = get_supabase_client()
    
    # Get user profile information if user is authenticated
    profile = None
    if user_id:
        try:
            profile_response = supabase.table("profiles").select("*").eq("id", user_id).execute()
            profile = profile_response.data[0] if profile_response.data else None
        except Exception as e:
            print(f"Error fetching profile: {e}")
    
    # Generate welcome message using LLM
    llm_response = generate_response(
        message="start_conversation",  # Special trigger for welcome message
        user_profile=profile,
        conversation_history=[]
    )
    
    # Create response
    response = ChatResponse(
        message=llm_response.message,
        suggested_actions=llm_response.suggested_actions,
        context_modules=llm_response.context_modules,
        sideboard_content=llm_response.sideboard_content,
        component_trigger=None
    )
    
    return response
