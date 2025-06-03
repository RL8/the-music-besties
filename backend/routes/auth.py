from fastapi import APIRouter, HTTPException, Depends, Request
from models.auth import UserSignup, UserLogin, AuthResponse, UserProfile
from utils.supabase_client import get_supabase_client
import logging

# Configure logging
logger = logging.getLogger(__name__)

# Initialize router
router = APIRouter(
    prefix="/auth",
    tags=["authentication"],
    responses={404: {"description": "Not found"}},
)

# Get Supabase client
supabase = get_supabase_client()

@router.post("/signup", response_model=AuthResponse)
async def signup(user: UserSignup):
    """
    Register a new user with email, password, and username
    """
    try:
        logger.info(f"Attempting to register user with email: {user.email}")
        
        # Sign up user with Supabase
        auth_response = supabase.auth.sign_up({
            "email": user.email,
            "password": user.password,
            "options": {
                "data": {
                    "username": user.username
                }
            }
        })
        
        if auth_response.error:
            logger.error(f"Supabase signup error: {auth_response.error}")
            raise HTTPException(status_code=400, detail=auth_response.error.message)
        
        # Create profile record
        new_user = auth_response.user
        profile_data = {
            "id": new_user.id,
            "username": user.username,
            "updated_at": "now()"
        }
        
        profile_response = supabase.table("profiles").insert(profile_data).execute()
        
        if hasattr(profile_response, 'error') and profile_response.error:
            logger.error(f"Error creating profile: {profile_response.error}")
            # Continue anyway since the user is created
        
        # Return success response
        return AuthResponse(
            access_token=auth_response.session.access_token,
            refresh_token=auth_response.session.refresh_token,
            user=UserProfile(
                id=new_user.id,
                username=user.username
            ),
            message="User registered successfully"
        )
        
    except Exception as e:
        logger.error(f"Error during signup: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Registration failed: {str(e)}")

@router.post("/login", response_model=AuthResponse)
async def login(user: UserLogin):
    """
    Authenticate a user with email and password
    """
    try:
        logger.info(f"Attempting to login user with email: {user.email}")
        
        # Sign in user with Supabase
        auth_response = supabase.auth.sign_in_with_password({
            "email": user.email,
            "password": user.password
        })
        
        if auth_response.error:
            logger.error(f"Supabase login error: {auth_response.error}")
            raise HTTPException(status_code=401, detail="Invalid credentials")
        
        # Get user profile
        user_id = auth_response.user.id
        profile_response = supabase.table("profiles").select("*").eq("id", user_id).execute()
        
        if hasattr(profile_response, 'error') and profile_response.error:
            logger.error(f"Error fetching profile: {profile_response.error}")
            raise HTTPException(status_code=500, detail="Error fetching user profile")
        
        profile_data = profile_response.data[0] if profile_response.data else {}
        
        # Return success response
        return AuthResponse(
            access_token=auth_response.session.access_token,
            refresh_token=auth_response.session.refresh_token,
            user=UserProfile(
                id=user_id,
                username=profile_data.get("username", ""),
                avatar_url=profile_data.get("avatar_url"),
                primary_obsession_type=profile_data.get("primary_obsession_type"),
                primary_obsession_id=profile_data.get("primary_obsession_id"),
                created_at=profile_data.get("created_at"),
                updated_at=profile_data.get("updated_at")
            ),
            message="Login successful"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error during login: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Login failed: {str(e)}")

@router.post("/logout")
async def logout(request: Request):
    """
    Log out the current user
    """
    try:
        # Get JWT token from Authorization header
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
        
        token = auth_header.split(" ")[1]
        
        # Sign out user with Supabase
        supabase.auth.sign_out(token)
        
        return {"message": "Logged out successfully"}
        
    except Exception as e:
        logger.error(f"Error during logout: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Logout failed: {str(e)}")

@router.get("/me", response_model=UserProfile)
async def get_current_user(request: Request):
    """
    Get the current authenticated user's profile
    """
    try:
        # Get JWT token from Authorization header
        auth_header = request.headers.get("Authorization")
        if not auth_header or not auth_header.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Missing or invalid Authorization header")
        
        token = auth_header.split(" ")[1]
        
        # Get user from Supabase
        user_response = supabase.auth.get_user(token)
        
        if hasattr(user_response, 'error') and user_response.error:
            logger.error(f"Error getting user: {user_response.error}")
            raise HTTPException(status_code=401, detail="Invalid token")
        
        user_id = user_response.user.id
        
        # Get user profile
        profile_response = supabase.table("profiles").select("*").eq("id", user_id).execute()
        
        if hasattr(profile_response, 'error') and profile_response.error:
            logger.error(f"Error fetching profile: {profile_response.error}")
            raise HTTPException(status_code=500, detail="Error fetching user profile")
        
        if not profile_response.data:
            raise HTTPException(status_code=404, detail="User profile not found")
        
        profile_data = profile_response.data[0]
        
        return UserProfile(
            id=user_id,
            username=profile_data.get("username", ""),
            avatar_url=profile_data.get("avatar_url"),
            primary_artist_id=profile_data.get("primary_artist_id"),
            created_at=profile_data.get("created_at"),
            updated_at=profile_data.get("updated_at")
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting current user: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to get user: {str(e)}")
