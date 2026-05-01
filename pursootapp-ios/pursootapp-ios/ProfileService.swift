import Foundation

// --- MODELLER (Class dışında olmalı) ---
struct UserProfile: Codable, Equatable {
    let id: Int
    let username: String
    let email: String
    let profile_image: String
    let follower_count: Int
    let following_count: Int
    let post_count: Int
    let adopted_count: Int
    let donation_total: String  // Backend'den "3k+" gibi geliyorsa String
    let feeding_count: Int      // Backend'den sayı geliyorsa Int
    let title: String           // Genelde Alena/James altında "Pet Owner" yazan kısım
    }


struct Post: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let content: String
    let image_url: String
}

// --- SERVİS (Class içinde olmalı) ---
class ProfileService: ObservableObject {
    @Published var user: UserProfile?
    @Published var posts: [Post] = [] // Hata buradaydı, class'ın içinde olmalı

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
        // Not: Backend'de bu endpoint'in olduğundan emin ol (Örn: /user/1/posts)
        guard let url = URL(string: "http://127.0.0.1:8000/user/\(userId)/posts") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                if let decodedPosts = try? JSONDecoder().decode([Post].self, from: data) {
                    DispatchQueue.main.async {
                        self.posts = decodedPosts
                    }
                }
            }
        }.resume()
    }
}
