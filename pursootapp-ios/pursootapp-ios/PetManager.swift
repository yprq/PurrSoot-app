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
    
    func postPet(name: String, species: String, breed: String, gender: String, age: String, description: String, imageData: Data?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/pets/add") else { return }
        
        // Yaş metnini sayıya çevirme
        let numericAge: Int
        if age == "<1" { numericAge = 0 }
        else if age == "5+" { numericAge = 5 }
        else { numericAge = Int(age) ?? 1 }

        var body: [String: Any] = [
            "owner_id": 2, // Buraya kendi user_id'ni koymalısın (Profilindeki ID)
            "name": name,
            "species": species,
            "breed": breed,
            "age": numericAge,
            "gender": gender,
            "description": description,
            "latitude": 38.412,
            "longitude": 27.1287
        ]
        
        if let data = imageData {
            body["pet_image"] = data.base64EncodedString()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, _ in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    self.fetchPets()
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }
}
