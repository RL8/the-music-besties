"""
Simplified FastAPI backend for The Music Besties
This version focuses on the core API functionality without external dependencies
"""
from fastapi import FastAPI, HTTPException, Depends, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os
import logging
from typing import Optional

# Import routes
from routes.auth import router as auth_router
from routes.music import router as music_router
from routes.chat import router as chat_router

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI()

# Get environment variables
port = int(os.getenv("PORT", 8000))
frontend_url = os.getenv("FRONTEND_URL", "http://localhost:3000")
supabase_url = os.getenv("SUPABASE_URL")
supabase_key = os.getenv("SUPABASE_KEY")
openai_api_key = os.getenv("OPENAI_API_KEY")

# Log startup information
logger.info(f"Starting server on port {port}")
logger.info(f"Frontend URL: {frontend_url}")
logger.info(f"Supabase URL is {'set' if supabase_url else 'not set'}")
logger.info(f"Supabase Key is {'set' if supabase_key else 'not set'}")
logger.info(f"OpenAI API Key is {'set' if openai_api_key else 'not set'}")

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        frontend_url,
        "https://the-music-besties.vercel.app",
        "https://the-music-besties-git-main.vercel.app",
        "https://the-music-besties-*.vercel.app"
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth_router, prefix="/api")
app.include_router(music_router, prefix="/api")
app.include_router(chat_router, prefix="/api")

# Define routes
@app.get("/")
async def read_root():
    return {"message": "Welcome to The Music Besties API"}

@app.get("/health")
async def health_check():
    logger.info("Health check endpoint called")
    return {"status": "healthy"}

if __name__ == "__main__":
    import uvicorn
    logger.info("Starting server")
    uvicorn.run("main_simplified:app", host="0.0.0.0", port=8000, reload=True)
