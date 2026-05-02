import SwiftUI

struct Pet: Identifiable, Codable, Hashable {
    let id: Int
    let name: String
    let species: String?
    let breed: String?
    let description: String?
    let latitude: Double?
    let longitude: Double?
    let pet_image: String? // Postman'de null gelse bile opsiyonel olduğu için sorun çıkarmaz[cite: 5]
    
    // JOIN ile gelen alanlar
    let owner_name: String?
    let owner_role: String?
    let owner_image: String?
    
    // UI için yardımcı alanlar (Postman'de olmayanları burada uyduruyoruz)
    var gender: String { "Male" }
    var age: String { "2" }
    var size: String { "Medium" }
    var displayDistance: String { "Distance 700m" }
}

enum PetCategory: String, CaseIterable {
    case all = "All"
    case dog = "Dog"
    case cat = "Cat"
    case others = "Others"
}

struct AdoptView: View {
    @StateObject private var petManager = PetManager() // Backend bağlantısı için manager
    @State private var selectedCategory: PetCategory = .all
    @State private var showAddPetSheet = false
    
    private let primaryGreen = Color.customDarkSage
    private let lightGreenCard = Color.customLightSage
    
    // Filtreleme mantığı: Backend'den gelen 'species' kolonuna bakar
    private var filteredPets: [Pet] {
        if selectedCategory == .all {
            return petManager.pets
        } else {
            return petManager.pets.filter { pet in
                pet.species?.lowercased() == selectedCategory.rawValue.lowercased()
            }
        }
    }
    
    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) { // FAB butonu için alignment ekledik
                Color(red: 246/255, green: 246/255, blue: 246/255)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    topBar
                        .padding(.bottom, 12)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            categoryBar
                                .padding(.top, 22)
                            
                            if petManager.pets.isEmpty {
                                ProgressView("Loading pets...")
                                    .padding(.top, 50)
                            } else {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(filteredPets) { pet in
                                        NavigationLink(value: pet) {
                                            PetCardView(
                                                pet: pet,
                                                cardColor: lightGreenCard
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.top, 18)
                            }
                            
                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                
                // Sağ alt köşedeki Yuvarlak + Butonu
                addPetButton
            }
            .navigationDestination(for: Pet.self) { pet in
                PetDetailsView(pet: pet)
            }
            .onAppear {
                petManager.fetchPets() // Sayfa açıldığında verileri çek[cite: 1]
            }
        }
    }
    
    // MARK: - Components
    private var topBar: some View {
        HStack {
            Button(action: {}) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(.black)
            }
            Spacer()
            Text("Adopt a pet")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(.black)
            Spacer()
            Color.clear.frame(width: 28, height: 28)
        }
        .padding(.horizontal, 20)
        .padding(.top, 22)
    }
    
    private var categoryBar: some View {
        HStack(spacing: 12) {
            ForEach(PetCategory.allCases, id: \.self) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category.rawValue)
                        .font(.custom("Poppins-Regular", size: 16))
                        .foregroundColor(selectedCategory == category ? .white : .black)
                        .padding(.horizontal, 18)
                        .frame(height: 42)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(selectedCategory == category ? primaryGreen : Color(red: 242/255, green: 235/255, blue: 231/255))
                        )
                }
            }
            Spacer()
            Button(action: { /* Filtreleme sayfası açılabilir */ }) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
    
    private var addPetButton: some View {
        Button(action: {
            showAddPetSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(primaryGreen)
                    .frame(width: 64, height: 64)
                    .shadow(color: primaryGreen.opacity(0.4), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(.white)
            }
        }
        // Sheet'i butona veya ana ZStack'e bağlayabilirsin
        .sheet(isPresented: $showAddPetSheet) {
            AddPetView(viewModel: petManager)
        }
        .padding(.trailing, 24)
        .padding(.bottom, 24)
    }
    
    struct PetCardView: View {
        let pet: Pet
        let cardColor: Color
        
        var body: some View {
            VStack(spacing: 0) {
                ZStack {
                    cardColor.opacity(0.35)
                    // Asset içindeki veya URL'deki resmi yükle
                    Image(pet.pet_image ?? "dog-pic")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: 145)
                        .clipped()
                }
                .frame(height: 145)
                
                VStack(alignment: .leading, spacing: 3) {
                    Text(pet.name)
                        .font(.custom("Poppins-Medium", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(pet.displayDistance)
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(cardColor)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
