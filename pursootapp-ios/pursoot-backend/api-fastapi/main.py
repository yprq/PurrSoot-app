from fastapi import FastAPI, HTTPException
from database import query_db  # database.py dosyasından çekiyoruz

app = FastAPI()

# --- SEDA: Auth (Giriş/Kayıt) ---
@app.post("/auth/signup")
def signup(user: dict):
    try:
        # Node.js'teki INSERT sorgusunun aynısı
        query = "INSERT INTO users (username, email, password_hash) VALUES (%s, %s, %s) RETURNING *"
        new_user = query_db(query, (user['username'], user['email'], user['password']), one=True)
        return new_user
    except Exception as e:
        raise HTTPException(status_code=500, detail="Kayıt sırasında hata oluştu")

# --- YAPRAK: Map (Hayvanları Listele) ---
@app.get("/map/pets")
def get_pets():
    try:
        pets = query_db("SELECT name, latitude, longitude, species FROM pets")
        return pets
    except Exception:
        raise HTTPException(status_code=500, detail="Pet listesi alınamadı")

# --- DILARA: Profile (Kullanıcı Bilgisi) ---
@app.get("/profile/{user_id}")
def get_profile(user_id: int):
    user = query_db("SELECT username, email, created_at FROM users WHERE id = %s", (user_id,), one=True)
    if not user:
        raise HTTPException(status_code=404, detail="Kullanıcı bulunamadı")
    return user