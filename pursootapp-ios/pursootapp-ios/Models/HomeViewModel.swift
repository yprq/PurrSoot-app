//
//  HomeViewModel.swift
//  pursootapp-ios
//
//  Created by Yaprak Aslan on 1.05.2026.
//


import Foundation
import Observation

@Observable
class HomeViewModel {
    // Backend'den gelecek pet listesi
    var pets: [PurrPet] = []
    
    // Yükleme durumu (İstersen ekranda ProgressView göstermek için kullanabilirsin)
    var isLoading = false
    
    // Hata mesajı yönetimi
    var errorMessage: String?
    
    func fetchPets() async {
        // İşlem başladığında yükleme durumunu aktif et
        await MainActor.run {
            self.isLoading = true
            self.errorMessage = nil
        }
        
        // Simülatör için localhost (127.0.0.1) kullanıyoruz.
        // Docker-compose ile backend 8000 portunda çalıştığı için portu 8000 verdik.
        guard let url = URL(string: "http://127.0.0.1:8000/map/pets") else {
            await MainActor.run { self.errorMessage = "Geçersiz URL" }
            return
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // HTTP durum kodunu kontrol et (200 OK mi?)
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                let decodedPets = try JSONDecoder().decode([PurrPet].self, from: data)
                
                // UI güncellemelerini ana thread'e (MainActor) gönder
                await MainActor.run {
                    self.pets = decodedPets
                    self.isLoading = false
                    print("Veri başarıyla çekildi: \(self.pets.count) pet bulundu.")
                }
            } else {
                await MainActor.run {
                    self.errorMessage = "Sunucu hatası: \(response)"
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = "Bağlantı hatası: \(error.localizedDescription)"
                self.isLoading = false
                print("Fetch hatası: \(error)")
            }
        }
    }
}
