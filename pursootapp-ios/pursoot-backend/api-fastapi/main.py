from fastapi import FastAPI, HTTPException
from database import query_db  # database.py dosyasından çekiyoruz
from auth_utils import hash_password
import re
from pydantic import BaseModel, EmailStr, field_validator
from auth_utils import hash_password, verify_password, create_access_token
from typing import Optional

app = FastAPI()

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
        query = "SELECT * FROM pets WHERE 1=1"
        params = []
        
        if species and species != "All":
            query += " AND species = %s"
            params.append(species)
            
        if gender and gender != "All":
            query += " AND gender = %s"
            params.append(gender)
            
        if age is not None:
            query += " AND age = %s"
            params.append(age)
            
        query += " ORDER BY created_at DESC"
        
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

# --- DILARA: Profile (Kullanıcı Bilgisi) ---
@app.get("/profile/{user_id}")
def get_profile(user_id: int):
    user = query_db("SELECT username, email, created_at FROM users WHERE id = %s", (user_id,), one=True)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user