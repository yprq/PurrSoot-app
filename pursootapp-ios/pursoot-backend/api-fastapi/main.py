from fastapi import FastAPI, HTTPException
from database import query_db  # database.py dosyasından çekiyoruz
from auth_utils import hash_password
import re
from pydantic import BaseModel, EmailStr, field_validator
from auth_utils import hash_password, verify_password, create_access_token
from typing import Optional
from routers import profile, posts  


app = FastAPI()


app.include_router(profile.router)
app.include_router(posts.router)

#Sign Up
class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str

    @field_validator('password')
    @classmethod
    def password_complexity(cls, v: str) -> str:
        if len(v) < 8:
            raise ValueError('Şifre en az 8 karakter olmalıdır.')
        if not re.search(r"[A-Z]", v):
            raise ValueError('Şifre en az bir büyük harf içermelidir.')
        if not re.search(r"[a-z]", v):
            raise ValueError('Şifre en az bir küçük harf içermelidir.')
        if not re.search(r"\d", v):
            raise ValueError('Şifre en az bir rakam içermelidir.')
        if not re.search(r"[!@#$%^&*(),.?\":{}|<>]", v):
            raise ValueError('Şifre en az bir özel karakter içermelidir.')
        return v

@app.post("/auth/signup")
def signup(user: UserCreate): # user artık bir sözlük değil, nesne
    try:
        # Şifreyi modelden çekiyoruz: user.password
        hashed_pwd = hash_password(user.password)

        query = "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) RETURNING id, username, email"
        new_user = query_db(query, (user.username, user.email, hashed_pwd), one=True)
        return {"message": "Kayıt başarılı!", "user": new_user}
    except Exception as e:
        print(f"HATA: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
#Login
class UserLogin(BaseModel):
    email: str
    password: str

from typing import Optional 

class FeedingCreate(BaseModel):
    pet_id: Optional[int] = None 
    food_type: str
    latitude: float
    longitude: float
    user_id: int

@app.post("/auth/login")
def login(user_credentials: UserLogin):
    query = "SELECT id, username, email, password_hash FROM users WHERE email = %s"
    user = query_db(query, (user_credentials.email,), one=True)
    
    if not user or not verify_password(user_credentials.password, user['password_hash']):
        raise HTTPException(status_code=401, detail="E-posta veya şifre hatalı!")

    # ANAHTAR OLUŞTURULUYOR
    access_token = create_access_token(data={"sub": user['email'], "user_id": user['id']})

    return {
        "access_token": access_token,
        "token_type": "bearer",
        "user": {
            "id": user['id'],
            "username": user['username'],
            "email": user['email']
        }
    }

#Pet Data
@app.get("/pets")
def get_all_pets(species: Optional[str] = None, gender: Optional[str] = None, age: Optional[int] = None):
    try:
        # Sorguyu JOIN ile güncelledik
        query = """
            SELECT 
                p.*, 
                u.username as owner_name, 
                u.title as owner_role, 
                u.profile_image as owner_image
            FROM pets p
            LEFT JOIN users u ON p.owner_id = u.id
            WHERE 1=1
        """
        params = []
        
        if species and species != "All":
            query += " AND p.species = %s"
            params.append(species)
            
        if gender and gender != "All":
            query += " AND p.gender = %s"
            params.append(gender)
            
        if age is not None:
            query += " AND p.age = %s"
            params.append(age)
            
        query += " ORDER BY p.created_at DESC"
        
        pets = query_db(query, tuple(params))
        return pets if pets else []
    except Exception as e:
        print(f"Backend Filtreleme Hatası: {e}")
        return []

#Pet Details
@app.get("/pets/{pet_id}")
def get_pet_details(pet_id: int):
    query = """
        SELECT 
            p.*, 
            u.username as owner_name, 
            u.title as owner_role, 
            u.profile_image as owner_image
        FROM pets p
        LEFT JOIN users u ON p.owner_id = u.id
        WHERE p.id = %s
    """
    pet = query_db(query, (pet_id,), one=True)
    if not pet:
        raise HTTPException(status_code=404, detail="Pet bulunamadı")
    return pet

class PetCreate(BaseModel):
    owner_id: int
    name: str
    species: str
    breed: str
    age: int  # 0: <1 yaş, 5: 5+ yaş anlamında
    gender: str
    description: str
    latitude: float
    longitude: float
    pet_image: Optional[str] = None # Base64 string olarak gelecek

@app.post("/pets/add")
def add_new_pet(pet: PetCreate):
    try:
        # SQL sorgusunda pet_image sütununun TEXT olduğundan emin olmalısın
        query = """
            INSERT INTO pets (owner_id, name, species, breed, age, gender, description, latitude, longitude, pet_image)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s) RETURNING id
        """
        params = (pet.owner_id, pet.name, pet.species, pet.breed, pet.age, 
                  pet.gender, pet.description, pet.latitude, pet.longitude, pet.pet_image)
        
        result = query_db(query, params, one=True)
        return {"message": "Dostun başarıyla eklendi!", "id": result['id']}
    except Exception as e:
        # Docker loglarında hatayı net görmek için:
        print(f"VERITABANI HATASI: {str(e)}") 
        raise HTTPException(status_code=500, detail=f"Database Error: {str(e)}")

# --- YAPRAK: Map (Hayvanları Listele) ---
@app.get("/map/pets")
def get_pets():
    try:
        # SQL'e description ve breed ekledik (Database'de bu kolonlar zaten var)
        pets = query_db("SELECT name, latitude, longitude, species, description, breed FROM pets")
        return pets
    except Exception:
        raise HTTPException(status_code=500, detail="Pet listesi alınamadı")

@app.post("/map/feed")
def save_feeding(feeding: FeedingCreate):
    try:
        # SQL sorgusu feedings tablosuna kayıt atar
        query = "INSERT INTO feedings (pet_id, user_id, food_type, latitude, longitude) VALUES (%s, %s, %s, %s, %s) RETURNING id"
        new_feeding = query_db(query, (feeding.pet_id, feeding.user_id, feeding.food_type, feeding.latitude, feeding.longitude), one=True)
        return {"message": "Feeding activity saved!", "id": new_feeding['id']}
    except Exception as e:
        print(f"Besleme Hatası: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/feeds/all")
def get_all_feeds():
    try:
        # SQL View üzerinden tüm aktiviteleri (besleme + varsa diğerleri) çekiyoruz
        query = "SELECT * FROM all_activity_feed ORDER BY created_at DESC"
        feeds = query_db(query)
        return feeds
    except Exception as e:
        print(f"Feed Çekme Hatası: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
@app.get("/tips")
def get_all_tips():
    try:
        # Veritabanından tüm ipuçlarını çekiyoruz
        tips = query_db("SELECT id, title, subtitle, image_name FROM tips")
        return tips if tips else []
    except Exception as e:
        print(f"Tips Çekme Hatası: {e}")
        return []
    
# --- DILARA: Profile (Kullanıcı Bilgisi) ---
@app.get("/profile/{user_id}")
def get_profile(user_id: int):
    # Swift tarafındaki ProfileService'in beklediği tüm sütunları ekledik
    query = """
        SELECT id, username, email, title, profile_image, 
               follower_count, following_count, post_count, 
               adopted_count, donation_total, feeding_count 
        FROM users WHERE id = %s
    """
    user = query_db(query, (user_id,), one=True)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user

# --- BU YENİ FONKSİYONU DOSYANIN EN ALTINA EKLE ---
# {user_id} süslü parantez içinde olmalı ki linkin bir parçası olsun
@app.get("/user/{user_id}/posts")
def get_user_posts(user_id: int):
    try:
        # Sorguyu tam olarak tablo yapına göre güncelledik:
        # owner_id -> senin tablon
        # description -> senin tablon
        query = "SELECT id, owner_id AS user_id, description AS content, image_url FROM posts WHERE owner_id = %s"
        posts = query_db(query, (user_id,))
        return posts if posts else []
    except Exception as e:
        print(f"HATA: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
# main.py içine ekle
class PostCreate(BaseModel):
    owner_id: int
    description: str
    image_url: str
    category: str = "All"

@app.post("/posts")
def create_post(post: PostCreate):
    try:
        query = """
            INSERT INTO posts (owner_id, description, image_url, category) 
            VALUES (%s, %s, %s, %s) 
            RETURNING id, created_at
        """
        params = (post.owner_id, post.description, post.image_url, post.category)
        new_post = query_db(query, params, one=True)
        return {"message": "Gönderi başarıyla oluşturuldu!", "post_id": new_post['id']}
    except Exception as e:
        print(f"POST EKLEME HATASI: {e}")
        raise HTTPException(status_code=500, detail=str(e))
    
    