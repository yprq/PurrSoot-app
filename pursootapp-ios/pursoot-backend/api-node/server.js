const express = require('express');
const db = require('./src/db'); // Az önce yazdığımız servisi çağırıyoruz
const app = express();

app.use(express.json());

// --- SEDA: Auth (Giriş/Kayıt) ---
app.post('/auth/signup', async (req, res) => {
    const { username, email, password } = req.body;
    try {
        const newUser = await db.query(
            'INSERT INTO users (username, email, password_hash) VALUES ($1, $2, $3) RETURNING *',
            [username, email, password] // Şimdilik plain text, ilerde hash'lenecek
        );
        res.status(201).json(newUser.rows[0]);
    } catch (err) {
        res.status(500).json({ error: "Kayıt sırasında hata oluştu" });
    }
});

// --- YAPRAK: Map (Hayvanları Listele) ---
app.get('/map/pets', async (req, res) => {
    try {
        const allPets = await db.query('SELECT name, latitude, longitude, species FROM pets');
        res.json(allPets.rows);
    } catch (err) {
        res.status(500).json({ error: "Pet listesi alınamadı" });
    }
});

// --- DILARA: Profile (Kullanıcı Bilgisi) ---
app.get('/profile/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const userProfile = await db.query('SELECT username, email, created_at FROM users WHERE id = $1', [id]);
        if (userProfile.rows.length === 0) return res.status(404).json({ error: "Kullanıcı bulunamadı" });
        res.json(userProfile.rows[0]);
    } catch (err) {
        res.status(500).json({ error: "Profil bilgisi alınamadı" });
    }
});

app.listen(3000, () => console.log('Backend 3000 portunda hazır!'));
