-- 0. Mevcut Tabloları Temizle (Bağımlılık sırasına göre)
DROP TABLE IF EXISTS followers CASCADE;
DROP TABLE IF EXISTS posts CASCADE;
DROP TABLE IF EXISTS feedings CASCADE;
DROP TABLE IF EXISTS pets CASCADE;
DROP TABLE IF EXISTS tips CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- 1. Kullanıcılar Tablosu
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    title VARCHAR(100),
    profile_image TEXT,
    donation_total VARCHAR(20) DEFAULT '0',
    feeding_count INTEGER DEFAULT 0,
    adopted_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Bilgi Kartları (Tips) Tablosu
CREATE TABLE tips (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    subtitle TEXT,
    image_name VARCHAR(100)
);

-- 3. Hayvanlar Tablosu
CREATE TABLE pets (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    species VARCHAR(50),
    breed VARCHAR(50),
    age INTEGER,
    gender VARCHAR(20),
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    description TEXT,
    pet_image TEXT,
    owner_id INTEGER REFERENCES users(id) ON DELETE CASCADE, -- Virgül buradaydı, düzeltildi
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Besleme Aktiviteleri Tablosu
CREATE TABLE feedings (
    id SERIAL PRIMARY KEY,
    pet_id INTEGER REFERENCES pets(id) ON DELETE CASCADE, 
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE, 
    food_type VARCHAR(50) NOT NULL,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Postlar Tablosu
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    owner_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    category VARCHAR(50),
    description TEXT,
    image_url TEXT,
    likes_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. Takipçiler Tablosu
CREATE TABLE followers (
    id SERIAL PRIMARY KEY,
    follower_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    followed_id INTEGER REFERENCES users(id) ON DELETE CASCADE
);

-- --- ÖRNEK VERİLER (SEED DATA) ---

-- Kullanıcılar
INSERT INTO users (id, username, email, password_hash, title, profile_image, donation_total, feeding_count) VALUES
(1, 'James Parlor', 'jamesparlor@gmail.com', '$2b$12$6k5E2uS0pP9Y.Gq5rKkMZeS6NqH5tE4R6fA2g7B8h9i0j1k2l3m4n', 'Pet Owner', 'James_Profile', '3k+', 72),
(2, 'Alena Parlor', 'alena@gmail.com', '$2b$12$6k5E2uS0pP9Y.Gq5rKkMZeS6NqH5tE4R6fA2g7B8h9i0j1k2l3m4n', 'Pet Lover', 'Robert_Pattinson', '500', 12),
(3, 'Dr. Emily Watson', 'emily@vet.com', 'hash456', 'Veterinarian', 'https://images.unsplash.com/photo-1559839734-2b71f1e3c770', '5k+', 120),
(4, 'Marcus Thorne', 'marcus@rescue.org', 'hash789', 'Rescue Volunteer', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', '2k+', 89),
(5, 'Liam O’Sullivan', 'liam@farm.com', 'hash000', 'Farm Manager', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d', '800', 56),
(6, 'Yuki Tanaka', 'yuki@exotic.jp', 'hash555', 'Exotic Pet Expert', 'https://images.unsplash.com/photo-1527980965255-d3b416303d12', '2.5k', 95);

-- Tips (Bilgi Kartları)
INSERT INTO tips (title, subtitle, image_name) VALUES
('How to Feed?', 'Learn the basics of stray feeding', 'Frame 19'),
('Summer Care', 'Keep them hydrated and cool', 'Frame 20'),
('Safe Foods', 'What can dogs eat safely?', 'Frame 21');

-- Hayvanlar
INSERT INTO pets (owner_id, name, species, breed, age, gender, description, latitude, longitude, pet_image) VALUES 
(1, 'Dost', 'Dog', 'Golden Retriever', 2, 'Male', 'A very loyal and friendly companion.', 38.4120, 27.1287, 'dog-pic'),
(2, 'Luna', 'Dog', 'Siberian Husky', 2, 'Female', 'Energetic Husky who loves snow.', 38.4622, 27.1005, 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8'),
(3, 'Max', 'Dog', 'Golden Puppy', 0, 'Male', 'Recovering from a minor injury, looking for love.', 38.4500, 27.1100, 'https://images.unsplash.com/photo-1552053831-71594a27632d'),
(5, 'Barnaby', 'Others', 'Miniature Pig', 1, 'Male', 'Loves apples and belly rubs. Very clean.', 38.4800, 27.0800, 'pig-pic'),
(6, 'Iggy', 'Others', 'Green Iguana', 3, 'Male', 'Calm reptile, needs a specific heat setup.', 38.4400, 27.1800, 'https://images.unsplash.com/photo-1548366086-7f1b76106622'),
(4, 'Shadow', 'Dog', 'German Shepherd', 5, 'Male', 'Senior rescue dog looking for a quiet home.', 38.4700, 27.1300, 'https://images.unsplash.com/photo-15899446912fac-1ad3e08556c5'),
(3, 'Cleo', 'Cat', 'Egyptian Mau', 2, 'Female', 'Very intelligent and active indoor cat.', 38.4200, 27.1600, 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000'),
(6, 'Spike', 'Others', 'Hedgehog', 0, 'Male', 'Shy but sweet. Loves mealworms.', 38.4300, 27.1700, 'https://images.unsplash.com/photo-1559190394-df5a28aab5c5?q=80&w=1000');

-- Takipçiler ve Postlar
INSERT INTO followers (follower_id, followed_id) VALUES (1, 2), (2, 3), (3, 1);
INSERT INTO posts (owner_id, category, description, image_url, likes_count) VALUES (2, 'Adoption', 'I found this little kitten today. Needs a home!', 'cat_sample', 12);
INSERT INTO posts (owner_id, description, image_url) VALUES (1, 'Today we visited our friends at the shelter. They need a lot of love!', 'post_image_1');

-- ID Senkronizasyonu (Yeni kayıtlar için şart)
SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));
SELECT setval('pets_id_seq', (SELECT MAX(id) FROM pets));