import Foundation
import CoreLocation

struct PurrPet: Codable, Identifiable {
    var id: String { name } // Şimdilik isim üzerinden ID
    let name: String
    let latitude: Double
    let longitude: Double
    let species: String
    
    // Arkadaşının UI'da beklediği ama backend'den (henüz) gelmeyen alanlar için opsiyonel tanımlama:
    var gender: String { "Unknown" }
    var age: String { "1" }
    var size: String { "Medium" }
    var description: String { "No description available." }
    var imageName: String { "dog-pic" } // Assetlerdeki resim adı
    var ownerName: String { "Community Member" }
    var ownerRole: String { "Volunteer" }
    var ownerImageName: String { "owner" } // Assetlerdeki resim adı

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
