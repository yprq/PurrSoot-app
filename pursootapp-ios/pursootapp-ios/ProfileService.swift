import Foundation

// --- MODELLER (Class dışında kalabilir, sorun yok) ---
struct UserProfile: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let profile_image: String
    let follower_count: Int
    let following_count: Int
    let post_count: Int
    let adopted_count: Int
    let donation_total: String
    let feeding_count: Int
    let title: String
}

// ProfileService.swift içindeki Post struct'ını bununla değiştir:
// ProfileService.swift içindeki Post struct'ını bununla tamamen değiştir:
// ProfileService.swift içindeki Post struct'ını bununla tamamen değiştir:
struct Post: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let content: String // Backend'den gelen asıl veri
    let image_url: String
    var likes_count: Int? = 0
    var isLiked: Bool? = false
    var selectedImageData: Data? = nil
    var petImage: String? { return nil }
    
    // Hata 261:42 çözümü: Swift tarafında 'description' ismini kullanabilmen için köprü
    var description: String {
        return content
    }
    
    var userName: String { "James Parlor" }
    var userTitle: String { "Pet Owner" }
}

// --- SERVİS ---
class ProfileService: ObservableObject {
    @Published var user: UserProfile?
    @Published var posts: [Post] = []

    func fetchProfile(userId: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/profile/\(userId)") else { return }
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
                    DispatchQueue.main.async {
                        self.user = decoded
                    }
                }
            }
        }.resume()
    }

    func fetchUserPosts(userId: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/user/\(userId)/posts") else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Network Error: \(error.localizedDescription)")
                return
            }
            if let data = data {
                do {
                    let decodedPosts = try JSONDecoder().decode([Post].self, from: data)
                    DispatchQueue.main.async {
                        self.posts = decodedPosts
                    }
                } catch {
                    print("Decoding Error: \(error)")
                }
            }
        }.resume()
    }

    func uploadPost(userId: Int, description: String, imageUrl: String) {
        // URL'deki son slash'i kaldırıp backend rotasıyla tam eşliyoruz
        guard let url = URL(string: "http://127.0.0.1:8000/posts") else { return }
        
        // Backend modelindeki isimlerle (owner_id, description vb.) birebir aynı yapıyoruz
        let body: [String: Any] = [
            "owner_id": userId,
            "description": description,
            "image_url": imageUrl,
            "category": "All"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // JSON oluştururken hata riskini minimize ediyoruz
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Hata durumunda backend'in ne dediğini görmek için log ekliyoruz
            if let data = data, let responseString = String(data: data, encoding: .utf8) {
                 print("BACKEND NE DİYOR: \(responseString)")
            }

            DispatchQueue.main.async {
                self.fetchUserPosts(userId: userId)
            }
        }.resume()
    }
    
    func toggleLike(postId: Int) {
        guard let url = URL(string: "http://127.0.0.1:8000/posts/\(postId)/like") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Like hatası: \(error.localizedDescription)")
                return
            }
            // Başarılı olduğunda terminalde log görebilirsin
            print("Like başarılı (200 OK)")
        }.resume()
    }
    
    func updateLocalLike(postId: Int) {
        // 1. Dizide tıkladığımız postun sırasını (index) buluyoruz
        if let index = self.posts.firstIndex(where: { $0.id == postId }) {
            
            // 2. Mevcut durumun tersini alıyoruz (Beğenilmişse beğenilmedi yap)
            let currentStatus = self.posts[index].isLiked ?? false
            self.posts[index].isLiked = !currentStatus
            
            // 3. Sayıyı artır veya azalt
            let currentLikes = self.posts[index].likes_count ?? 0
            self.posts[index].likes_count = currentLikes + (currentStatus ? -1 : 1)
            
            // 4. SwiftUI'a "Hey, veri değişti ekranı tazele!" diyoruz
            self.objectWillChange.send()
        }
    }
} // Class burada bitti.
