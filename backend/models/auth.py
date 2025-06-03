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

async def get_current_user(credentials: Annotated[HTTPAuthorizationCredentials, Depends(security)]) -> User:
    """
    Dependency to get the current authenticated user
    
    Args:
        credentials: JWT token from the Authorization header
        
    Returns:
        User: The authenticated user
        
    Raises:
        HTTPException: If the token is invalid
    """
    # Check if we're in test mode and using the test token
    if TEST_MODE and credentials.credentials == TEST_TOKEN:
        # Return the test user without verifying the JWT
        test_user = get_test_user()
        return User(
            id=test_user.id,
            email=test_user.email,
            app_metadata=test_user.app_metadata,
            user_metadata=test_user.user_metadata,
            created_at=test_user.created_at
        )
    
    # Normal authentication flow
    try:
        user_data = verify_jwt(credentials.credentials)
        return User(
            id=user_data.id,
            email=user_data.email,
            app_metadata=user_data.app_metadata,
            user_metadata=user_data.user_metadata,
            created_at=user_data.created_at
        )
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e),
            headers={"WWW-Authenticate": "Bearer"}
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
