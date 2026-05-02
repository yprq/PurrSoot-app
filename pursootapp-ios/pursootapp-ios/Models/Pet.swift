import Foundation
import CoreLocation

struct Pet: Identifiable, Codable, Hashable {
    // MARK: - Backend Fields
    let id: Int
    let name: String
    let species: String?
    let breed: String?
    let description: String?
    let latitude: Double?
    let longitude: Double?
    let pet_image: String? // Base64 string veya asset adı
    
    // JOIN ile gelen kullanıcı verileri[cite: 1, 3]
    let owner_name: String?
    let owner_role: String?
    let owner_image: String?
    
    // Backend'den integer olarak dönecek alanlar
    let age: Int?
    let gender: String?
    
    // MARK: - UI Helpers
    
    // Yaşın ekranda <1 veya 5+ görünmesini sağlayan mantık
    var displayAge: String {
        guard let a = age else { return "N/A" }
        if a == 0 { return "<1" }
        if a >= 5 { return "5+" }
        return "\(a)"
    }
    
    // Eğer breed nil gelirse "Unknown" yazdırıyoruz
    var displayBreed: String {
        breed ?? "Unknown Breed"
    }
    
    // Statik değerleri buraya fallback (yedek) olarak koyabiliriz
    var size: String { "Medium" }
    var displayDistance: String { "700m away" }
    
    // MARK: - Map Logic
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 38.4237, // İzmir varsayılanı
            longitude: longitude ?? 27.1428
        )
    }
    
    // Hashable protokolü için (NavigationPath vb. kullanırken gerekli)
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Pet, rhs: Pet) -> Bool {
        lhs.id == rhs.id
    }
}
