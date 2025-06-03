import os
from typing import Optional, Dict, Any, List, Union
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Import test configuration
from utils.test_config import TEST_MODE, TEST_USER_PROFILE, TEST_USER_DATA, get_test_user

# Get Supabase credentials from environment variables
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

# Singleton instances of the clients
_supabase_client: Optional[Client] = None
_mock_supabase_client: Optional['MockSupabaseClient'] = None

class MockSupabaseResponse:
    """Mock response class for Supabase operations"""
    def __init__(self, data: List[Dict[str, Any]] = None, error: Dict[str, Any] = None):
        self.data = data or []
        self.error = error
        
    def execute(self):
        """Mock execute method that returns self"""
        return self

class MockSupabaseTable:
    """Mock table class for Supabase operations"""
    def __init__(self, table_name: str):
        self.table_name = table_name
        
    def select(self, *args):
        """Mock select method"""
        return self
        
    def eq(self, field: str, value: Any):
        """Mock equals filter method"""
        if self.table_name == "profiles" and field == "id" and value == TEST_USER_DATA["id"]:
            return MockSupabaseResponse(data=[TEST_USER_PROFILE])
        return MockSupabaseResponse(data=[])
        
    def execute(self):
        """Mock execute method"""
        if self.table_name == "profiles":
            return MockSupabaseResponse(data=[TEST_USER_PROFILE])
        return MockSupabaseResponse(data=[])

class MockSupabaseClient:
    """Mock Supabase client for testing"""
    def __init__(self):
        self.auth = MockSupabaseAuth()
        
    def table(self, table_name: str):
        """Mock table method"""
        return MockSupabaseTable(table_name)

class MockSupabaseAuth:
    """Mock Supabase auth for testing"""
    def get_user(self, jwt: str):
        """Mock get_user method"""
        if jwt == "test-token-for-development-only":
            return TEST_USER_DATA
        raise ValueError("Invalid JWT token")

def get_supabase_client() -> Union[Client, MockSupabaseClient]:
    """
    Get or create a Supabase client instance
    
    Returns:
        Client or MockSupabaseClient: Real or mock Supabase client instance based on TEST_MODE
    """
    global _supabase_client, _mock_supabase_client
    
    # Return mock client in test mode
    if TEST_MODE:
        if _mock_supabase_client is None:
            _mock_supabase_client = MockSupabaseClient()
        return _mock_supabase_client
    
    # Return real client in normal mode
    if _supabase_client is None:
        if not SUPABASE_URL or not SUPABASE_KEY:
            raise ValueError("Supabase URL and Key must be set in environment variables")
        
        _supabase_client = create_client(SUPABASE_URL, SUPABASE_KEY)
    
    return _supabase_client

def verify_jwt(token: str) -> dict:
    """
    Verify a JWT token from Supabase
    
    Args:
        token (str): JWT token to verify
        
    Returns:
        dict: User data if token is valid
        
    Raises:
        ValueError: If token is invalid
    """
    supabase = get_supabase_client()
    
    try:
        # Verify the token
        response = supabase.auth.get_user(token)
        return response.user
    except Exception as e:
        raise ValueError(f"Invalid token: {str(e)}")
