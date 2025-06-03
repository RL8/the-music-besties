from pydantic import BaseModel, EmailStr
from typing import Optional, Annotated
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from utils.supabase import verify_jwt
from utils.test_config import TEST_MODE, TEST_TOKEN, get_test_user

# Security scheme for JWT authentication
security = HTTPBearer()

class UserSignup(BaseModel):
    email: EmailStr
    password: str
    username: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class User(BaseModel):
    id: str
    email: EmailStr
    app_metadata: Optional[dict] = None
    user_metadata: Optional[dict] = None
    created_at: Optional[str] = None

class UserProfile(BaseModel):
    id: str
    username: str
    avatar_url: Optional[str] = None
    primary_artist_id: Optional[str] = None
    created_at: Optional[str] = None
    updated_at: Optional[str] = None

class AuthResponse(BaseModel):
    access_token: Optional[str] = None
    refresh_token: Optional[str] = None
    user: Optional[UserProfile] = None
    message: Optional[str] = None

async def get_current_user(credentials: Annotated[Optional[HTTPAuthorizationCredentials], Depends(security)] = None) -> User:
    """
    Dependency to get a default user (no authentication required)
    
    Args:
        credentials: Optional JWT token from the Authorization header (not used)
        
    Returns:
        User: A default user
    """
    # Return a default user without authentication
    default_user = get_test_user()
    return User(
        id=default_user.id,
        email=default_user.email,
        app_metadata=default_user.app_metadata,
        user_metadata=default_user.user_metadata,
        created_at=default_user.created_at
    )

async def get_optional_user(credentials: Annotated[Optional[HTTPAuthorizationCredentials], Depends(security)]) -> Optional[User]:
    """
    Dependency to get the current user if authenticated, or None if not
    
    Args:
        credentials: JWT token from the Authorization header (optional)
        
    Returns:
        Optional[User]: The authenticated user or None
    """
    # In test mode, we can return the test user directly if no credentials are provided
    if TEST_MODE and (not credentials or credentials.credentials == TEST_TOKEN):
        test_user = get_test_user()
        return User(
            id=test_user.id,
            email=test_user.email,
            app_metadata=test_user.app_metadata,
            user_metadata=test_user.user_metadata,
            created_at=test_user.created_at
        )
        
    if not credentials:
        return None
        
    try:
        return await get_current_user(credentials)
    except HTTPException:
        return None
