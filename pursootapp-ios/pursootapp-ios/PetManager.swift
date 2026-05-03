import SwiftUI

class PetManager: ObservableObject {
    @Published var pets: [Pet] = []
    
    func fetchPets(species: String? = nil, gender: String? = nil, age: String? = nil) {
        var urlString = "http://127.0.0.1:8000/pets?"
        if let species = species, species != "All" { urlString += "species=\(species)&" }
        if let gender = gender, gender != "All" { urlString += "gender=\(gender)&" }
        if let age = age, age != "All" {
            let numericAge = age == "<1" ? "0" : age.replacingOccurrences(of: "+", with: "")
            urlString += "age=\(numericAge)&"
        }
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([Pet].self, from: data)
                    DispatchQueue.main.async { self.pets = decoded }
                } catch {
                    print("Filtreleme Decode Hatası: \(error)")
                    DispatchQueue.main.async { self.pets = [] }
                }
            }
        }.resume()
    }
    
    // --- BU FONKSİYONU GÜNCELLEDİK ---
    func postPet(owner_id: Int, name: String, species: String, breed: String, gender: String, age: String, description: String, imageData: Data?, completion: @escaping (Bool) -> Void) {
        guard let url = URL(string: "http://127.0.0.1:8000/pets/add") else { return }
        
        let numericAge: Int
        if age == "<1" { numericAge = 0 }
        else if age == "5+" { numericAge = 5 }
        else { numericAge = Int(age) ?? 1 }

        var body: [String: Any] = [
            "owner_id": owner_id, // Artık dışarıdan geliyor
            "name": name,
            "species": species,
            "breed": breed,
            "age": numericAge,
            "gender": gender,
            "description": description,
            "latitude": 38.441, // Örnek koordinat
            "longitude": 27.142
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
