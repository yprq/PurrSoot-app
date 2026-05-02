import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    searchSection
                    categoriesSection
                    adopteesSection
                    tipsSection
                }
                .padding(.top)
            }
            .background(Color(.systemGroupedBackground))
            .task {
                await viewModel.fetchPets()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Sub-Views & Helper Functions
extension HomeView {
    
    func convertToFriendPet(from purrPet: PurrPet) -> Pet {
        return Pet(
            name: purrPet.name,
            imageName: "dog-pic",
            category: purrPet.species.lowercased() == "kedi" ? .cat : .dog,
            distance: "700m away",
            gender: "Male",
            age: "2",
            size: "Medium",
            ownerName: "PurrSoot User",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Bu can dostumuz sistemimizde kayıtlıdır. Koordinatları: \(purrPet.latitude), \(purrPet.longitude)"
        )
    }
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Hello name!")
                    .font(.subheadline)
                    .fontWeight(.thin)
                Text("Ready to Feed?")
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Spacer()
            Image(systemName: "bell.badge").font(.title2).frame(width: 40, height: 40)
        }
        .padding(.horizontal)
    }
    
    private var searchSection: some View {
        CustomSearchBar(text: $searchText).padding(.horizontal)
    }
    
    private var categoriesSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                NavigationLink(destination: AdoptView()) {
                    CategoryCard(title: "Adopt a Pet", subtitle: "Browse animals", iconName: "faw-full-white", bgColor: .customLightSage, iconBgColor: .customDarkSage)
                }
                
                NavigationLink(destination: MapView(isPresented: .constant(true))) {
                    CategoryCard(title: "Places to Feed", subtitle: "Find spots", iconName: "map (1) 1", bgColor: .customLightSage, iconBgColor: .customDarkSage)
                }
            }
            NavigationLink(destination: FeedsView()) {
                WideCategoryCard(title: "Community", subtitle: "Share your knowledge and make friends!", iconName: "chat_bubble 1", bgColor: .customLightSage, iconBgColor: .customDarkSage)
            }
        }
        .padding(.horizontal)
        .buttonStyle(.plain)
    }
    
    private var adopteesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Adoptees near you").font(.headline)
                Spacer()
                Text("see all").font(.subheadline).foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.pets) { pet in
                        NavigationLink(destination: PetDetailsView(pet: convertToFriendPet(from: pet))) {
                            VStack(alignment: .leading) {
                                Image("dog-pic")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 140, height: 140)
                                    .cornerRadius(12)
                                
                                Text(pet.name)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.black)
                                
                                Text(pet.species)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 140)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tips and tricks").font(.headline)
                Spacer()
                Text("see all").font(.subheadline).foregroundColor(.gray)
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(0..<5) { index in
                        VStack(alignment: .leading) {
                            Image("Frame 19")
                                .resizable()
                                .frame(width: 140, height: 140)
                                .cornerRadius(12)
                            Text("Feeding \(index + 1)").fontWeight(.semibold)
                            Text("How to feed").font(.caption).foregroundColor(.gray)
                        }
                        .frame(width: 140)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Reusable Components (Hizalamalar Güncellendi)
struct CategoryCard: View {
    let title: String; let subtitle: String; let iconName: String
    let bgColor: Color; let iconBgColor: Color
    
    var body: some View {
        ZStack(alignment: .topLeading) { // Sol üst hizalama
            RoundedRectangle(cornerRadius: 15)
                .fill(bgColor)
                .frame(height: 160)
            
            VStack(alignment: .leading, spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBgColor)
                        .frame(width: 40, height: 40)
                    Image(iconName)
                        .resizable()
                        .frame(width: 20, height: 20)
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                
                Text(subtitle)
                    .font(.system(size: 10))
                    .fontWeight(.light)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer() // İçeriği yukarı itmesi için alta eklendi
            }
            .padding(15)
        }
    }
}

struct WideCategoryCard: View {
    let title: String; let subtitle: String; let iconName: String
    let bgColor: Color; let iconBgColor: Color
    
    var body: some View {
        ZStack(alignment: .leading) {
            RoundedRectangle(cornerRadius: 15)
                .fill(bgColor)
                .frame(height: 90)
            
            HStack(spacing: 15) {
                VStack { // İkonu sol üstte tutmak için
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(iconBgColor)
                            .frame(width: 45, height: 45)
                        Image(iconName)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Spacer(minLength: 0)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .fontWeight(.light)
                        .foregroundColor(.black)
                    Spacer()
                }
            }
            .padding(15)
        }
    }
}

#Preview {
    HomeView()
}
