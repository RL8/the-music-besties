from pydantic import BaseModel, Field
from typing import Optional, List

class CurationItem(BaseModel):
    id: Optional[str] = None
    user_id: str
    curated_item_id: str
    item_type: str  # 'album' or 'song'
    rating: Optional[int] = Field(None, ge=1, le=5)
    comment: Optional[str] = None
    weighted_rank_percentage: Optional[int] = Field(None, ge=0, le=100)

class CurationSubmission(BaseModel):
    item_id: str
    item_type: str  # 'album' or 'song'
    rating: int = Field(..., ge=1, le=5)
    comment: Optional[str] = None
    weighted_rank_percentage: Optional[int] = Field(None, ge=0, le=100)

class CurationResponse(BaseModel):
    id: str
    message: str
    curation: CurationItem

class UserCurationSummary(BaseModel):
    user_id: str
    username: str
    artist_name: str
    top_items: List[dict]  # List of curated items with details
