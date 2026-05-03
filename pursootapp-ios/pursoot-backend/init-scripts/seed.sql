
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
    '$2b$12$6k5E2uS0pP9Y.Gq5rKkMZeS6NqH5tE4R6fA2g7B8h9i0j1k2l3m4n', 
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
    '$2b$12$6k5E2uS0pP9Y.Gq5rKkMZeS6NqH5tE4R6fA2g7B8h9i0j1k2l3m4n', 
    'Pet Lover', 
    'Robert_Pattinson'
);

INSERT INTO users (id, username, email, password_hash, title, profile_image, donation_total, feeding_count) VALUES
(3, 'Dr. Emily Watson', 'emily@vet.com', 'hash456', 'Veterinarian', 'https://images.unsplash.com/photo-1559839734-2b71f1e3c770', '5k+', 120),
(4, 'Marcus Thorne', 'marcus@rescue.org', 'hash789', 'Rescue Volunteer', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d', '2k+', 89),
(5, 'Liam O’Sullivan', 'liam@farm.com', 'hash000', 'Farm Manager', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d', '800', 56),
(6, 'Yuki Tanaka', 'yuki@exotic.jp', 'hash555', 'Exotic Pet Expert', 'https://images.unsplash.com/photo-1527980965255-d3b416303d12', '2.5k', 95);

SELECT setval('users_id_seq', (SELECT MAX(id) FROM users));

-- Hayvanlar (Pets)
INSERT INTO pets (owner_id, name, species, breed, age, gender, description, latitude, longitude, pet_image) VALUES 
-- James & Alena'nın Hayvanları (Senin istediklerin)
(1, 'Dost', 'Dog', 'Golden Retriever', 2, 'Male', 'A very loyal and friendly companion.', 38.4120, 27.1287, 'dog-pic'),
(2, 'Luna', 'Dog', 'Siberian Husky', 2, 'Female', 'Energetic Husky who loves snow.', 38.4622, 27.1005, 'https://images.unsplash.com/photo-1537151608828-ea2b11777ee8'),

-- Yeni ve Değişik Hayvanlar
(3, 'Max', 'Dog', 'Golden Puppy', 0, 'Male', 'Recovering from a minor injury, looking for love.', 38.4500, 27.1100, 'https://images.unsplash.com/photo-1552053831-71594a27632d'),
(5, 'Barnaby', 'Others', 'Miniature Pig', 1, 'Male', 'Loves apples and belly rubs. Very clean.', 38.4800, 27.0800, 'https://images.unsplash.com/photo-1516467508483-a7212febe31a'),
(6, 'Iggy', 'Others', 'Green Iguana', 3, 'Male', 'Calm reptile, needs a specific heat setup.', 38.4400, 27.1800, 'https://images.unsplash.com/photo-1548366086-7f1b76106622'),
(4, 'Shadow', 'Dog', 'German Shepherd', 5, 'Male', 'Senior rescue dog looking for a quiet home.', 38.4700, 27.1300, 'https://images.unsplash.com/photo-15899446912fac-1ad3e08556c5'),
(3, 'Cleo', 'Cat', 'Egyptian Mau', 2, 'Female', 'Very intelligent and active indoor cat.', 38.4200, 27.1600, 'https://images.unsplash.com/photo-1513245535769-db992eaa393a'),
(6, 'Spike', 'Others', 'Hedgehog', 0, 'Male', 'Shy but sweet. Loves mealworms.', 38.4300, 27.1700, 'https://images.unsplash.com/photo-1505628346881-b72b27e84530');

-- Alena bir post paylaşmış olsun
INSERT INTO posts (owner_id, category, description, image_url, likes_count) 
VALUES (2, 'Adoption', 'I found this little kitten today. Needs a home!', 'cat_sample', 12);

-- James, Alena'yı takip etsin
INSERT INTO followers (follower_id, followed_id) VALUES (1, 2), (2, 3), (3, 1);

-- James için örnek postlar (user_id yerine owner_id, content yerine description)
INSERT INTO posts (owner_id, description, image_url) VALUES 
(1, 'Today we visited our friends at the shelter. They need a lot of love!', 'post_image_1'),
(5, 'Our first day with my new dog!', 'post_image_2');

-- Hayvan linklerini daha stabil olanlarla güncelle
UPDATE pets SET pet_image = 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?q=80&w=1000' WHERE name = 'Shadow';
UPDATE pets SET pet_image = 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?q=80&w=1000' WHERE name = 'Cleo';
UPDATE pets SET pet_image = 'https://images.unsplash.com/photo-1559190394-df5a28aab5c5?q=80&w=1000' WHERE name = 'Spike';
UPDATE pets SET pet_image = 'https://images.unsplash.com/photo-1552053831-71594a27632d?q=80&w=1000' WHERE name = 'Max';
UPDATE pets SET pet_image = 'pig-pic' WHERE name = 'Barnaby';