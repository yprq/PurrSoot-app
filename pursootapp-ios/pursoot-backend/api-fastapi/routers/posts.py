from fastapi import APIRouter, HTTPException
from database import query_db
from pydantic import BaseModel
from typing import Optional

router = APIRouter(prefix="/posts", tags=["Posts"])

# --- GET: Akışı Getir (Kategori Filtreli) ---
@router.get("/feed")
def get_feed(category: str = "All"):
    if category == "All":
        query = "SELECT p.*, u.username, u.profile_image FROM posts p JOIN users u ON p.owner_id = u.id ORDER BY p.created_at DESC"
        return query_db(query)
    
    query = "SELECT p.*, u.username, u.profile_image FROM posts p JOIN users u ON p.owner_id = u.id WHERE p.category = %s ORDER BY p.created_at DESC"
    return query_db(query, (category,))

# --- GET: Sadece Bir Kullanıcının Postlarını Getir ---
@router.get("/user/{user_id}")
def get_user_posts(user_id: int):
    query = "SELECT * FROM posts WHERE owner_id = %s ORDER BY created_at DESC"
    return query_db(query, (user_id,))

# --- POST: Yeni Gönderi Paylaş (CreatePostView) ---
@router.post("/")
def create_new_post(user_id: int, description: str, category: str = "All", image_url: str = None):
    query = "INSERT INTO posts (owner_id, description, category, image_url) VALUES (%s, %s, %s, %s) RETURNING *"
    return query_db(query, (user_id, description, category, image_url), one=True)

# --- DELETE: Gönderi Sil (MyProfileView) ---
@router.delete("/{post_id}")
def delete_post(post_id: int):
    query_db("DELETE FROM posts WHERE id = %s", (post_id,))
    return {"message": "Post başarıyla silindi"}

# --- POST: Beğeni At/Çek ---
@router.post("/{post_id}/like")
def toggle_like(post_id: int):
    query = "UPDATE posts SET likes_count = likes_count + 1 WHERE id = %s RETURNING likes_count"
    result = query_db(query, (post_id,), one=True)
    return result