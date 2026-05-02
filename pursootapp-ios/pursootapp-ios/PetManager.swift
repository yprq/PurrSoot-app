import SwiftUI

class PetManager: ObservableObject {
    @Published var pets: [Pet] = []
    
    func fetchPets() {
        guard let url = URL(string: "http://127.0.0.1:8000/pets") else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data {
                // Konsola bak: Başında ve sonunda [ ] var mı?[cite: 3]
                print("GELEN JSON: \(String(data: data, encoding: .utf8) ?? "")")
                
                do {
                    let decoded = try JSONDecoder().decode([Pet].self, from: data)
                    DispatchQueue.main.async {
                        self.pets = decoded
                    }
                } catch {
                    print("DECODE HATASI: \(error)")
                }
            }
        }.resume()
    }
    
    func addPet(name: String, species: String, breed: String, age: String, gender: String, description: String) {
        guard let url = URL(string: "http://127.0.0.1:8000/pets/add") else { return }
        
        // Backend'in beklediği PetCreate modeliyle uyumlu body[cite: 3]
        let body: [String: Any] = [
            "owner_id": 1, // Şimdilik manuel James[cite: 5]
            "name": name,
            "species": species,
            "breed": breed,
            "age": Int(age) ?? 0,
            "gender": gender,
            "description": description,
            "latitude": 38.4120, // Şimdilik sabit konum
            "longitude": 27.1287
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, _ in
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                print("Başarıyla eklendi!")
                self.fetchPets() // Listeyi yenile[cite: 3]
            }
        }.resume()
    }
    
    func postPet(name: String, species: String, gender: String, age: String, size: String, description: String, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/pets/add") else { return }
        
        // Backend INTEGER beklediği için age'i sayıya çeviriyoruz[cite: 3, 5]
        let body: [String: Any] = [
            "owner_id": 1, // Şimdilik James Parlor[cite: 5]
            "name": name,
            "species": species,
            "breed": size, // Modelde breed yerine size da gönderebilirsin ya da ayırabilirsin
            "age": Int(age) ?? 1,
            "gender": gender,
            "description": description,
            "latitude": 38.412,
            "longitude": 27.1287
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.fetchPets() // Listeyi hemen güncelle ki yeni pet gözüksün!
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
