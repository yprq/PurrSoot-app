-- Tabloları Oluşturalım
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

-- Örnek Veriler (Seed Data)
INSERT INTO users (username, email, password_hash) VALUES
('testuser', 'test@pursoot.com', 'hashed_password_buraya');

INSERT INTO pets (name, species, breed, latitude, longitude, description) VALUES
('Pamuk', 'Kedi', 'Ankara Kedisi', 38.4237, 27.1428, 'Çok oyuncu bir kedi.'),
('Dost', 'Köpek', 'Golden', 38.4120, 27.1287, 'Eğitimli ve uysal.');
