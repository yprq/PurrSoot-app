FROM node:18-alpine

# Konteynır içinde çalışacağımız klasörü belirliyoruz
WORKDIR /usr/src/app

# Sadece paket listelerini önce kopyalıyoruz (Hızlı kurulum için)
COPY package*.json ./

# Kütüphaneleri yüklüyoruz
RUN npm install

# Geri kalan tüm kodları (server.js, src/db.js vb.) içeri alıyoruz
COPY . .

# Konteynırın 3000 portunu dış dünyaya açıyoruz
EXPOSE 3000

# Uygulamayı başlatıyoruz
CMD ["node", "server.js"]
