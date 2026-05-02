import SwiftUI

enum PetCategory: String, CaseIterable {
    case all = "All"
    case dog = "Dog"
    case cat = "Cat"
    case others = "Others"
}

struct AdoptView: View {
    @StateObject private var petManager = PetManager()
        @State private var selectedCategory: PetCategory = .all
        @State private var showAddPetSheet = false
        @State private var showFilterSheet = false
        
        // Filtreleme durumlarını tutan değişkenler
        @State private var currentFilters = FilterOptions()
        
        private let primaryGreen = Color.customDarkSage
        private let lightGreenCard = Color.customLightSage
        
        private let columns: [GridItem] = [
            GridItem(.flexible(), spacing: 14),
            GridItem(.flexible(), spacing: 14)
        ]
        
        var body: some View {
            NavigationStack {
                ZStack(alignment: .bottomTrailing) {
                    Color(red: 246/255, green: 246/255, blue: 246/255).ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        topBar.padding(.bottom, 12)
                        
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 0) {
                                categoryBar.padding(.top, 22)
                                
                                if petManager.pets.isEmpty {
                                    VStack(spacing: 20) {
                                        ProgressView()
                                        Text("No pets found with these filters.")
                                            .font(.custom("Poppins-Regular", size: 14))
                                            .foregroundColor(.gray)
                                    }
                                    .padding(.top, 50)
                                } else {
                                    LazyVGrid(columns: columns, spacing: 14) {
                                        ForEach(petManager.pets) { pet in // Filtreleme backend'de yapıldığı için direkt pets kullanıyoruz
                                            NavigationLink(value: pet) {
                                                PetCardView(pet: pet, cardColor: lightGreenCard)
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
                    addPetButton
                }
                .navigationDestination(for: Pet.self) { pet in
                    PetDetailsView(pet: pet)
                }
                .sheet(isPresented: $showFilterSheet) {
                    FilterSheetView(filters: $currentFilters) {
                        // Detaylı filtreleme uygulandığında backend'e istek at
                        petManager.fetchPets(
                            species: selectedCategory.rawValue,
                            gender: currentFilters.selectedGender,
                            age: currentFilters.selectedAge
                        )
                    }
                }
                .onAppear {
                    petManager.fetchPets()
                }
            }
        }
        
        private var categoryBar: some View {
            HStack(spacing: 12) {
                ForEach(PetCategory.allCases, id: \.self) { category in
                    Button {
                        selectedCategory = category
                        // Kategori değiştiğinde backend'e istek at
                        petManager.fetchPets(species: category.rawValue)
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
                // Filtre Butonu
                Button(action: { showFilterSheet = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.black)
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
                // Üst kısım: Resim
                ZStack {
                    cardColor.opacity(0.35)
                    
                    if let base64String = pet.pet_image,
                       let data = Data(base64Encoded: base64String),
                       let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width - 54) / 2, height: 145) // Genişliği sabitledik
                            .clipped()
                    } else {
                        Image("nophoto")
                            .resizable()
                            .scaledToFill()
                            .frame(width: (UIScreen.main.bounds.width - 54) / 2, height: 145)
                            .clipped()
                    }
                }
                .frame(height: 145) // ZStack yüksekliğini sabitledik
                
                // Alt kısım: Metin alanı
                VStack(alignment: .leading, spacing: 3) {
                    Text(pet.name)
                        .font(.custom("Poppins-Medium", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    Text(pet.displayDistance)
                        .font(.custom("Poppins-Regular", size: 13))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading) // Metin kutusunu yaydık
                .padding(12)
                .background(cardColor)
            }
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
    }
}
