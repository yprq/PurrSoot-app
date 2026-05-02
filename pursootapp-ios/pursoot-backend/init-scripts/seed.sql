
-- 1. Önce Mevcut Tabloları Silelim (Sıralama Önemli: Foreign Key hatalarını önlemek için)
DROP TABLE IF EXISTS followers;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS pets;
DROP TABLE IF EXISTS users;

-- 2. İnsanlar (Users) Tablosu
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    title VARCHAR(50) DEFAULT 'Pet Owner',
    profile_image TEXT DEFAULT 'James_Profile',
    donation_total TEXT DEFAULT '0',
    feeding_count INTEGER DEFAULT 0,
    is_volunteering BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Hayvanlar (Pets) Tablosu
CREATE TABLE pets (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50),
    breed VARCHAR(50),
    age INTEGER,
    gender VARCHAR(10),
    is_adoptable BOOLEAN DEFAULT TRUE,
    pet_image TEXT,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Gönderiler (Posts) Tablosu
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50) DEFAULT 'All',
    image_url TEXT,
    description TEXT,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Yorumlar (Comments) Tablosu
CREATE TABLE comments (
    id SERIAL PRIMARY KEY,
    post_id INTEGER REFERENCES posts(id) ON DELETE CASCADE,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Takipçi (Followers) Tablosu
CREATE TABLE followers (
    follower_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    followed_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    PRIMARY KEY (follower_id, followed_id)
);

-- 7. Örnek Veriler (Seed Data)
-- James Parlor'ı (ID: 1) Ekliyoruz
INSERT INTO users (username, email, password_hash, title, profile_image, donation_total, feeding_count) 
VALUES (
    'James Parlor', 
    'jamesparlor@gmail.com', 
    'hashed_password_buraya', 
    'Pet Owner', 
    'James_Profile', 
    '3k+', 
    72
);

-- Bir tane de Alena (ID: 2) ekleyelim ki takipçi testlerini yapasın
INSERT INTO users (username, email, password_hash, title, profile_image) 
VALUES (
    'Alena Parlor', 
    'alena@gmail.com', 
    'hash123', 
    'Pet Lover', 
    'Robert_Pattinson'
);

-- James'e bir köpek ekleyelim (Swift'teki Adopted sayısı için)
INSERT INTO pets (owner_id, name, species, breed, description, latitude, longitude) 
VALUES (1, 'Dost', 'Köpek', 'Golden', 'Çok uysal bir dost.', 38.4120, 27.1287);

-- Alena bir post paylaşmış olsun
INSERT INTO posts (owner_id, category, description, image_url, likes_count) 
VALUES (2, 'Adoption', 'Bu tatlı kediye yuva arıyoruz.', 'cat_sample', 12);

-- James, Alena'yı takip etsin
INSERT INTO followers (follower_id, followed_id) VALUES (1, 2);