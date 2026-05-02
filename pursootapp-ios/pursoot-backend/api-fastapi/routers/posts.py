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




# --- DELETE: Gönderi Sil (MyProfileView) ---
@router.delete("/{post_id}")
def delete_post(post_id: int):
    query_db("DELETE FROM posts WHERE id = %s", (post_id,))
    return {"message": "Post başarıyla silindi"}



# posts.py içinde bu kısmı güncelle:

class PostCreate(BaseModel):
    owner_id: int
    description: str
    image_url: Optional[str] = None
    category: str = "All"

@router.post("/")
def create_new_post(post: PostCreate): # Veriyi 'post' objesi olarak alıyoruz
    try:
        query = """
            INSERT INTO posts (owner_id, description, category, image_url) 
            VALUES (%s, %s, %s, %s) 
            RETURNING id, created_at
        """
        # post.owner_id şeklinde modelden çekiyoruz
        params = (post.owner_id, post.description, post.category, post.image_url)
        new_post = query_db(query, params, one=True)
        return {"message": "Post başarıyla oluşturuldu", "post": new_post}
    except Exception as e:
        print(f"HATA: {e}")
        raise HTTPException(status_code=500, detail="Veritabanı hatası")


# --- LIKE İŞLEMİ ---
@router.post("/{post_id}/like")
def toggle_like(post_id: int):
    try:
        # Mevcut likes_count'u 1 artır ve yeni sayıyı geri döndür
        query = "UPDATE posts SET likes_count = likes_count + 1 WHERE id = %s RETURNING likes_count"
        result = query_db(query, (post_id,), one=True)
        
        if not result:
            raise HTTPException(status_code=404, detail="Post bulunamadı")
            
        return result # Örn: {"likes_count": 5}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# --- GÖNDERİLERİ GETİRME (Sıralama Önemli!) ---
@router.get("/user/{user_id}")
def get_user_posts(user_id: int):
    # 'ORDER BY id DESC' ekledik ki postlar zıplamasın
    query = """
        SELECT id, owner_id AS user_id, description AS content, 
               image_url, likes_count 
        FROM posts 
        WHERE owner_id = %s 
        ORDER BY id DESC
    """
    posts = query_db(query, (user_id,))
    return posts if posts else []

class CommentCreate(BaseModel):
    user_id: int
    content: str

# Bir posta yorum yapma
@router.post("/{post_id}/comments")
def add_comment(post_id: int, comment: CommentCreate):
    try:
        query = "INSERT INTO comments (post_id, user_id, content) VALUES (%s, %s, %s) RETURNING id"
        new_comment = query_db(query, (post_id, comment.user_id, comment.content), one=True)
        return {"message": "Yorum eklendi", "id": new_comment['id']}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Bir postun yorumlarını getirme
@router.get("/{post_id}/comments")
def get_comments(post_id: int):
    query = """
        SELECT c.content, u.username 
        FROM comments c 
        JOIN users u ON c.user_id = u.id 
        WHERE c.post_id = %s 
        ORDER BY c.created_at ASC
    """
    return query_db(query, (post_id,))