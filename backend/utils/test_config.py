"""
Test configuration module for The Music Besties backend
This provides test-specific settings and mock data for testing without real authentication
"""
import os
from typing import Dict, Any, Optional
from pydantic import BaseModel

# Test mode configuration
TEST_MODE = os.getenv("TEST_MODE", "false").lower() == "true"

# Test user data
TEST_USER_ID = "test-user-123"
TEST_USER_EMAIL = "test@example.com"
TEST_TOKEN = "test-token-for-development-only"

# Test artist data
TEST_ARTIST_ID = "spotify:artist:06HL4z0CvFAxyc27GXpf02"  # Taylor Swift
TEST_ARTIST_NAME = "Taylor Swift"

# Mock user profile data
TEST_USER_PROFILE = {
    "id": TEST_USER_ID,
    "username": "TestUser",
    "avatar_url": "https://example.com/avatar.png",
    "primary_artist_id": TEST_ARTIST_ID,
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
}

# Mock user data for authentication
TEST_USER_DATA = {
    "id": TEST_USER_ID,
    "email": TEST_USER_EMAIL,
    "app_metadata": {},
    "user_metadata": {"name": "Test User"},
    "created_at": "2025-01-01T00:00:00Z"
}

class TestUser(BaseModel):
    """Mock user class for testing"""
    id: str
    email: str
    app_metadata: Optional[Dict[str, Any]] = None
    user_metadata: Optional[Dict[str, Any]] = None
    created_at: Optional[str] = None

def get_test_user() -> TestUser:
    """
    Get a test user for authentication bypass
    
    Returns:
        TestUser: A mock user for testing
    """
    return TestUser(**TEST_USER_DATA)
