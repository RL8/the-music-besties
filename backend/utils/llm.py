"""
LLM integration module for The Music Besties chat functionality
"""
import os
from typing import Dict, Any, List, Optional
import openai
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Get OpenAI API key from environment variables
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

# Check if we're in test mode
from utils.test_config import TEST_MODE

class LLMResponse:
    """Response from LLM with message and additional data"""
    def __init__(self, 
                 message: str, 
                 suggested_actions: Optional[List[Dict[str, Any]]] = None,
                 context_modules: Optional[List[Dict[str, Any]]] = None,
                 sideboard_content: Optional[Dict[str, Any]] = None):
        self.message = message
        self.suggested_actions = suggested_actions or []
        self.context_modules = context_modules or []
        self.sideboard_content = sideboard_content

def get_openai_client():
    """
    Get the OpenAI client
    
    Returns:
        OpenAI client instance
    """
    if not OPENAI_API_KEY and not TEST_MODE:
        raise ValueError("OpenAI API Key must be set in environment variables")
    
    # Configure OpenAI with API key
    openai.api_key = OPENAI_API_KEY
    return openai

def generate_response(
    message: str, 
    user_profile: Optional[Dict[str, Any]] = None,
    conversation_history: Optional[List[Dict[str, Any]]] = None
) -> LLMResponse:
    """
    Generate a response using OpenAI's GPT model
    
    Args:
        message: User's message
        user_profile: User profile data from Supabase
        conversation_history: Previous messages in the conversation
        
    Returns:
        LLMResponse: Response from the LLM
    """
    # In test mode, use a mock response
    if TEST_MODE:
        return _generate_test_response(message, user_profile)
    
    try:
        # Create system message with context about the app and user
        system_message = _create_system_message(user_profile)
        
        # Format conversation history
        formatted_history = _format_conversation_history(conversation_history)
        
        # Add the current user message
        messages = [
            {"role": "system", "content": system_message},
            *formatted_history,
            {"role": "user", "content": message}
        ]
        
        # Get OpenAI client
        client = get_openai_client()
        
        # Call OpenAI API
        response = client.chat.completions.create(
            model="gpt-3.5-turbo",  # You can change to a different model if needed
            messages=messages,
            temperature=0.7,
            max_tokens=500,
            top_p=1.0,
            frequency_penalty=0.0,
            presence_penalty=0.0
        )
        
        # Extract the response text
        response_text = response.choices[0].message.content
        
        # Parse for any special actions or content
        # This is a simplified version - you might want to implement a more robust parser
        suggested_actions, context_modules, sideboard_content = _parse_special_content(response_text)
        
        return LLMResponse(
            message=response_text,
            suggested_actions=suggested_actions,
            context_modules=context_modules,
            sideboard_content=sideboard_content
        )
    except Exception as e:
        print(f"Error generating LLM response: {e}")
        # Fallback to a simple response
        return LLMResponse(
            message="I'm having trouble connecting to my brain right now. Can you try again in a moment?"
        )

def _create_system_message(user_profile: Optional[Dict[str, Any]]) -> str:
    """Create a system message with context about the app and user"""
    system_message = """
    You are the AI assistant for Music Besties, an app that helps users curate their music obsessions.
    Your role is to help users discover music, organize their favorite artists, and engage with their music interests.
    
    Keep your responses friendly, concise, and focused on music curation.
    """
    
    # Add user-specific context if available
    if user_profile:
        username = user_profile.get("username", "the user")
        primary_artist_id = user_profile.get("primary_artist_id")
        
        system_message += f"\n\nYou are speaking with {username}."
        
        if primary_artist_id:
            system_message += f" Their primary music obsession is associated with artist ID: {primary_artist_id}."
    
    return system_message

def _format_conversation_history(conversation_history: Optional[List[Dict[str, Any]]]) -> List[Dict[str, str]]:
    """Format conversation history for OpenAI API"""
    if not conversation_history:
        return []
    
    formatted_history = []
    for message in conversation_history:
        role = "assistant" if message.get("sender") == "ai" else "user"
        content = message.get("content", "")
        formatted_history.append({"role": role, "content": content})
    
    return formatted_history

def _parse_special_content(response_text: str) -> tuple:
    """
    Parse the response text for any special actions or content
    This is a simplified version - you might want to implement a more robust parser
    """
    # Default values
    suggested_actions = []
    context_modules = []
    sideboard_content = None
    
    # Simple parsing logic - in a real implementation, you might want to use a more robust approach
    # For example, you could have the LLM return JSON or use a specific format
    
    # Check for music curation trigger
    if "music curation" in response_text.lower() or "favorite artist" in response_text.lower():
        suggested_actions.append({
            "id": "start_curation", 
            "label": "Start Music Curation", 
            "action": "TRIGGER_MODULE", 
            "module": "music_curation"
        })
    
    # Check for artist information request
    if "artist information" in response_text.lower() or "tell me about" in response_text.lower():
        context_modules.append({
            "id": "artist_info",
            "type": "artist_information",
            "action": "LOAD_MODULE"
        })
    
    return suggested_actions, context_modules, sideboard_content

def _generate_test_response(message: str, user_profile: Optional[Dict[str, Any]]) -> LLMResponse:
    """Generate a test response for development and testing"""
    message_lower = message.lower()
    
    # Handle special start_conversation trigger
    if message == "start_conversation":
        response = "👋 Hi there! I'm your AI concierge for Music Besties. I'm here to help you curate your music obsession and find your music tribe. What would you like to do today?"
        suggested_actions = [
            {"id": "start_curation", "label": "Curate Music", "action": "TRIGGER_MODULE", "module": "music_curation"},
            {"id": "view_profile", "label": "View Profile", "action": "SHOW_SIDEBOARD", "content_type": "music_curation"}
        ]
        return LLMResponse(
            message=response,
            suggested_actions=suggested_actions
        )
    
    # Default response
    response = "I'm your AI concierge for music curation. How can I help you today?"
    suggested_actions = []
    context_modules = []
    sideboard_content = None
    
    # Simple rule-based responses for testing
    if any(word in message_lower for word in ["hello", "hi", "hey", "greetings"]):
        response = "Hello! Welcome to Music Besties. I'm here to help you curate your music obsession."
        
        if user_profile and not user_profile.get("primary_artist_id"):
            response += " Would you like to start by telling me about your favorite artist?"
            suggested_actions = [
                {"id": "start_curation", "label": "Start Music Curation", "action": "TRIGGER_MODULE", "module": "music_curation"}
            ]
    
    elif any(word in message_lower for word in ["artist", "music", "favorite", "obsession"]):
        if user_profile and user_profile.get("primary_artist_id"):
            artist_name = "Taylor Swift"  # Mock artist name for testing
            response = f"Your current music obsession is {artist_name}. Would you like to see your curated albums and songs?"
            sideboard_content = {
                "type": "music_curation",
                "artist_id": user_profile.get("primary_artist_id"),
                "artist_name": artist_name
            }
        else:
            response = "You haven't set a primary artist yet. Would you like to explore some popular artists?"
            suggested_actions = [
                {"id": "explore_artists", "label": "Explore Artists", "action": "TRIGGER_MODULE", "module": "artist_explorer"}
            ]
    
    elif "recommend" in message_lower or "suggestion" in message_lower:
        response = "Based on your music taste, I think you might enjoy these artists: The National, Phoebe Bridgers, and Bon Iver."
        context_modules = [
            {"id": "recommendations", "type": "artist_recommendations", "action": "LOAD_MODULE"}
        ]
    
    else:
        # Generic responses for other queries
        responses = [
            "I'm here to help with your music obsessions. What would you like to know about your favorite artists?",
            "Music is my passion! Ask me about artists, albums, or let me help you curate your collection.",
            "I can help you discover new music based on your current obsessions. What are you in the mood for?",
            "Let's talk music! I can help you organize your favorite artists and tracks."
        ]
        import random
        response = random.choice(responses)
    
    return LLMResponse(
        message=response,
        suggested_actions=suggested_actions,
        context_modules=context_modules,
        sideboard_content=sideboard_content
    )
