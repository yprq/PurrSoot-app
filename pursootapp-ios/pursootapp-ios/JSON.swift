import Foundation

// Backend'den gelen cevabın kalıbı
struct AuthResponse: Codable {
    let access_token: String
    let token_type: String
    let user: UserData
}

struct UserData: Codable {
    let id: Int
    let username: String
    let email: String
}
