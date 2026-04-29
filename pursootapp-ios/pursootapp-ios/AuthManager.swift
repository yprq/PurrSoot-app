import Foundation

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var token: String? = nil
    @Published var serverErrorMessage: String? = nil // Değişken ismimiz bu
    
    let baseURL = "http://localhost:8000/auth"
    
    func signUp(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        self.serverErrorMessage = nil
        guard let url = URL(string: "\(baseURL)/signup") else { return }
        
        let body: [String: Any] = ["username": username, "email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        completion(true)
                    } else {
                        if httpResponse.statusCode == 400 || httpResponse.statusCode == 500 {
                            self.serverErrorMessage = "This email is already registered."
                        } else {
                            self.serverErrorMessage = "Please enter a valid e-mail address."
                        }
                        completion(false)
                    }
                }
            }
        }.resume()
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        self.serverErrorMessage = nil // Giriş denemesinde de hataları temizle
        guard let url = URL(string: "\(baseURL)/login") else { return }
        
        let body: [String: Any] = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data, let decodedResponse = try? JSONDecoder().decode(AuthResponse.self, from: data) {
                        self.token = decodedResponse.access_token
                        self.isAuthenticated = true
                        completion(true)
                    }
                } else {
                    // BURAYI DÜZELTTİK: errorMessage -> serverErrorMessage
                    self.serverErrorMessage = "Invalid email or password!"
                    completion(false)
                }
            }
        }.resume()
    }
}
