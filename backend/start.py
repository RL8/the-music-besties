"""
Railway startup script for The Music Besties API
This script handles the PORT environment variable correctly
"""
import os
import uvicorn

if __name__ == "__main__":
    # Get port from environment variable or use default
    port = int(os.getenv("PORT", 8000))
    print(f"Starting server on port {port}")
    
    # Run the application
    uvicorn.run("main:app", host="0.0.0.0", port=port)
