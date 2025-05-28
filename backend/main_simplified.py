"""
Simplified FastAPI backend for The Music Besties
This version focuses on the core API functionality without external dependencies
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional, Dict, Any
import logging

# Configure logging
logging.basicConfig(
    level=logging.DEBUG,  # Set to DEBUG for more detailed logs
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="Music Besties API (Simplified)",
    description="Simplified backend API for The Music Besties application",
    version="0.1.0"
)

# Add CORS middleware with specific origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",
        "https://the-music-besties.vercel.app",
        "https://the-music-besties-git-main-rl8s-projects.vercel.app",
        "https://the-music-besties-rl8s-projects.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Request models
class ChatMessage(BaseModel):
    message: str

class NameSubmission(BaseModel):
    name: str

# Response models
class ChatResponse(BaseModel):
    message: str
    component_trigger: Optional[Dict[str, Any]] = None

# Routes
@app.get("/")
async def root():
    """Root endpoint for health checks"""
    logger.info("Root endpoint called")
    return {"status": "ok", "message": "Music Besties Simplified API is running"}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    logger.info("Health check endpoint called")
    return {"status": "healthy", "version": "0.1.0"}

@app.post("/api/chat")
async def chat(chat_message: ChatMessage):
    """
    Process a chat message from the user and return an AI response.
    Simplified version with static responses.
    """
    user_message = chat_message.message.lower()
    logger.info(f"Chat endpoint called with message: {user_message}")
    
    # Simple greeting detection
    greetings = ["hello", "hi", "hey", "greetings", "howdy"]
    if any(greeting in user_message for greeting in greetings):
        logger.info("Greeting detected, returning name input form")
        return {
            "message": "I'd like to get to know you better. What's your name?",
            "component_trigger": {
                "component_type": "name_input_form",
                "data": {
                    "title": "Tell me about yourself",
                    "description": "To personalize your experience, I need to know a bit about you.",
                    "label": "Your First Name",
                    "placeholder": "Enter your name"
                }
            }
        }
    else:
        logger.info("No greeting detected, returning default response")
        return {
            "message": "I'm your AI concierge. To get started, just say hello!"
        }

@app.post("/api/submit-name")
async def submit_name(submission: NameSubmission):
    """
    Process a name submission from the user and return a personalized response.
    Simplified version with static responses.
    """
    name = submission.name
    logger.info(f"Submit name endpoint called with name: {name}")
    
    return {
        "message": f"Nice to meet you, {name}! I've prepared a welcome message for you in the sideboard.",
        "component_trigger": {
            "component_type": "sideboard_welcome_display",
            "data": {
                "name": name
            }
        }
    }

if __name__ == "__main__":
    import uvicorn
    logger.info("Starting server")
    uvicorn.run("main_simplified:app", host="0.0.0.0", port=8000, reload=True)
