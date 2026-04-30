from fastapi import APIRouter, HTTPException
from database import query_db

router = APIRouter(prefix="/profile", tags=["Profile"])

@router.get("/{user_id}")
def get_user_profile(user_id: int):
    """Kullanıcının profil bilgilerini ve istatistiklerini getirir."""
    query = """
        SELECT 
            u.id, u.username, u.email, u.title, u.profile_image,
            u.donation_total, u.feeding_count,
            (SELECT COUNT(*) FROM posts WHERE owner_id = u.id) as post_count,
            (SELECT COUNT(*) FROM followers WHERE followed_id = u.id) as follower_count,
            (SELECT COUNT(*) FROM followers WHERE follower_id = u.id) as following_count,
            (SELECT COUNT(*) FROM pets WHERE owner_id = u.id) as adopted_count
        FROM users u 
        WHERE u.id = %s
    """
    user = query_db(query, (user_id,), one=True)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user

@router.patch("/{user_id}/update")
def update_profile(user_id: int, data: dict):
    """Profil bilgilerini günceller (Seda'nın yapacağı Auth ile entegre çalışır)."""
    query = "UPDATE users SET title = %s, profile_image = %s WHERE id = %s RETURNING *"
    updated = query_db(query, (data.get('title'), data.get('profile_image'), user_id), one=True)
    return updated