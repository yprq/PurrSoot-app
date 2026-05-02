-- 1. Kullanıcılar Tablosu
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Hayvanlar Tablosu
CREATE TABLE IF NOT EXISTS pets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50),
    breed VARCHAR(50),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    description TEXT,
    owner_id INTEGER REFERENCES users(id)
);

-- 3. Besleme Aktiviteleri Tablosu (YENİ)
CREATE TABLE IF NOT EXISTS feedings (
    id SERIAL PRIMARY KEY,
    pet_id INTEGER REFERENCES pets(id), 
    user_id INTEGER REFERENCES users(id), 
    food_type VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Örnek Veriler (Seed Data)
INSERT INTO users (username, email, password_hash) VALUES
('testuser', 'test@pursoot.com', 'hashed_password_buraya');

INSERT INTO pets (name, species, breed, latitude, longitude, description) VALUES
('Pamuk', 'Kedi', 'Ankara Kedisi', 38.4237, 27.1428, 'Çok oyuncu bir kedi.'),
('Dost', 'Köpek', 'Golden', 38.4120, 27.1287, 'Eğitimli ve uysal.');

-- 5. Beslemeleri Otomatik 'Feed' Olarak Görecek Sanal Görünüm (View)
-- Bu sayede FeedsView koduna dokunmadan verileri tek bir yerden çekebilirsin
CREATE OR REPLACE VIEW all_activity_feed AS
SELECT 
    u.username AS "userName",
    'Pet Lover' AS "userTitle",
    'Robert_Pattinson' AS "userProfileImage", -- Default profil resmi
    CASE 
        WHEN p.name IS NOT NULL THEN p.name || ' isimli dostumuzu ' || f.food_type || ' ile besledi! 🐾'
        ELSE 'Bir sokak hayvanını ' || f.food_type || ' ile besledi! 🐾'
    END AS "description",
    'Feeding' AS "category",
    f.created_at AS "created_at"
FROM feedings f
JOIN users u ON f.user_id = u.id
LEFT JOIN pets p ON f.pet_id = p.id

UNION ALL

-- Eğer ileride bir 'posts' tablon olursa buraya eklenir, 
-- Şimdilik sadece beslemeleri birer 'post' gibi döndürüyoruz.
SELECT 
    'Sistem' AS "userName",
    'Duyuru' AS "userTitle",
    'Robert_Pattinson' AS "userProfileImage",
    'PurrSoot topluluğuna hoş geldiniz!' AS "description",
    'News' AS "category",
    NOW() AS "created_at";