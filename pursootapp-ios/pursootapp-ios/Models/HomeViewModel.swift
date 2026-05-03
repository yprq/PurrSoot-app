import Foundation
import Observation

@Observable
class HomeViewModel {
    
    // Ham Veri Listeleri
    var pets: [Pet] = []
    var tips: [Tip] = []
    
    // Arama Metni
    var searchText: String = ""
    var isLoading = false
    
    // MARK: - Global Arama Sonuçları
    // Arama çubuğunun altında çıkacak "Suggestion" listesi
    var searchResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }
        
        var results: [SearchResult] = []
        let query = searchText.lowercased()
        
        // 1. Hayvanlar (Tıklayınca Haritaya veya Detaya Gidebilir)
        let matchedPets = pets.filter {
            $0.name.localizedCaseInsensitiveContains(query) ||
            ($0.species?.localizedCaseInsensitiveContains(query) ?? false)
        }
        results.append(contentsOf: matchedPets.map {
            SearchResult(title: $0.name, subtitle: "Pet • See on Map", type: .map)
        })
        
        // 2. İpuçları (Tıklayınca İpucu Detayına Gidebilir)
        let matchedTips = tips.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
        results.append(contentsOf: matchedTips.map {
            SearchResult(title: $0.title, subtitle: "Tip • View Details", type: .tip(tip: $0))
        })
        
        // 3. Statik Navigasyon Önerileri (Profil, Harita vs.)
        if "profile".contains(query) || "account".contains(query) {
            results.append(SearchResult(title: "My Profile", subtitle: "User settings and stats", type: .profile))
        }
        
        if "map".contains(query) || "feeding".contains(query) {
            results.append(SearchResult(title: "Feeding Map", subtitle: "Find spots near you", type: .map))
        }
        
        return results
    }
    
    // MARK: - Veri Çekme (Aynı Kaldı)
    func fetchData() async {
        await MainActor.run { self.isLoading = true }
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchPets() }
            group.addTask { await self.fetchTips() }
        }
        await MainActor.run { self.isLoading = false }
    }
    
    func fetchPets() async {
        guard let url = URL(string: "http://127.0.0.1:8000/pets") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Pet].self, from: data)
            await MainActor.run { self.pets = decoded }
        } catch { print("Pets Hatası: \(error)") }
    }
    
    func fetchTips() async {
        guard let url = URL(string: "http://127.0.0.1:8000/tips") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode([Tip].self, from: data)
            await MainActor.run { self.tips = decoded }
        } catch { print("Tips Hatası: \(error)") }
    }
}

// MARK: - Search Models
struct SearchResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let type: ResultType
    
    enum ResultType {
        case map
        case tip(tip: Tip)
        case profile
    }
}
