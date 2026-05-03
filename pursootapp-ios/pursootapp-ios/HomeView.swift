import SwiftUI

struct HomeView: View {
    @State private var viewModel = HomeViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                ScrollView {
                    VStack(spacing: 20) {
                        headerSection
                        searchSection
                        categoriesSection
                        
                        if viewModel.searchText.isEmpty {
                            adopteesSection
                            tipsSection
                        } else if viewModel.searchResults.isEmpty {
                            ContentUnavailableView.search(text: viewModel.searchText)
                        } else {
                            // Arama yapılırken arka planı hafif flu yapıyoruz
                            adopteesSection.opacity(0.2)
                            tipsSection.opacity(0.2)
                        }
                    }
                    .padding(.top)
                }
                .background(Color(.systemGroupedBackground))
            }
            .task {
                await viewModel.fetchData()
            }.onAppear {
                // Sayfaya her geri dönüldüğünde verileri tazeler
                Task {
                    await viewModel.fetchData()
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

// MARK: - Sub-Views Extension
extension HomeView {
    
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("Hello James!")
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
        VStack(spacing: 0) {
            CustomSearchBar(text: $viewModel.searchText)
                .padding(.horizontal)
            
            // GLOBAL SEARCH OVERLAY
            if !viewModel.searchText.isEmpty && !viewModel.searchResults.isEmpty {
                VStack(spacing: 0) {
                    ForEach(viewModel.searchResults) { result in
                        NavigationLink(destination: destinationView(for: result.type)) {
                            HStack(spacing: 15) {
                                Image(systemName: iconName(for: result.type))
                                    .foregroundColor(.customDarkSage)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading) {
                                    Text(result.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.primary)
                                    Text(result.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            .background(Color.white)
                        }
                        Divider().padding(.leading, 60)
                    }
                }
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .padding(.top, 5)
                .zIndex(100)
            }
        }
    }
    
    @ViewBuilder
    private func destinationView(for type: SearchResult.ResultType) -> some View {
        switch type {
        case .map:
            MapView(isPresented: .constant(true))
        case .tip(let tip):
            TipDetailsView(tip: tip)
        case .profile:
            ProfileView() // Kendi profil view adınla değiştir
        }
    }
    
    private func iconName(for type: SearchResult.ResultType) -> String {
        switch type {
        case .map: return "map.fill"
        case .tip: return "lightbulb.fill"
        case .profile: return "person.crop.circle.fill"
        }
    }

    private var categoriesSection: some View {
        VStack(spacing: 15) {
            HStack(spacing: 15) {
                NavigationLink(destination: AdoptView().toolbar(.hidden, for: .navigationBar)) {
                    CategoryCard(title: "Adopt a Pet", subtitle: "Browse animals", iconName: "faw-full-white", bgColor: .customLightSage, iconBgColor: .customDarkSage)
                }
                NavigationLink(destination: MapView(isPresented: .constant(true)).toolbar(.hidden, for: .navigationBar)) {
                    CategoryCard(title: "Places to Feed", subtitle: "Find spots", iconName: "map (1) 1", bgColor: .customLightSage, iconBgColor: .customDarkSage)
                }
            }
            NavigationLink(destination: FeedsView().toolbar(.hidden, for: .navigationBar)) {
                WideCategoryCard(title: "Community", subtitle: "Share your knowledge!", iconName: "chat_bubble 1", bgColor: .customLightSage, iconBgColor: .customDarkSage)
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
                        NavigationLink(destination: PetDetailsView(pet: pet).toolbar(.hidden, for: .navigationBar)) {
                            VStack(alignment: .leading) {
                                // --- DİNAMİK RESİM ALANI ---
                                Group {
                                    if let imageSource = pet.pet_image, !imageSource.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        if imageSource.hasPrefix("http") {
                                            AsyncImage(url: URL(string: imageSource)) { phase in
                                                switch phase {
                                                case .success(let image):
                                                    image.resizable().scaledToFill()
                                                case .failure(_), .empty:
                                                    // Görsel yüklenemezse veya boşsa nophoto göster
                                                    Image("nophoto")
                                                        .resizable()
                                                        .scaledToFill()
                                                @unknown default:
                                                    EmptyView()
                                                }
                                            }
                                        } else if let data = Data(base64Encoded: imageSource),
                                                  let uiImage = UIImage(data: data) {
                                            Image(uiImage: uiImage).resizable().scaledToFill()
                                        } else {
                                            // Asset içinde bu isimde bir resim varsa onu basar
                                            Image(imageSource).resizable().scaledToFill()
                                        }
                                    } else {
                                        // pet_image nil veya boş string ise buraya düşer
                                        Image("nophoto")
                                            .resizable()
                                            .scaledToFill()
                                    }
                                }
                                .frame(width: 140, height: 140)
                                .background(Color.gray.opacity(0.1)) // Resim yoksa bile alanı belirginleştirir
                                .cornerRadius(12)
                                .clipped()
                                
                                Text(pet.name).fontWeight(.semibold).foregroundColor(.black)
                                Text(pet.species ?? "Unknown").font(.caption).foregroundColor(.gray)
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
                    ForEach(viewModel.tips) { tip in
                        NavigationLink(destination: TipDetailsView(tip: tip)) {
                            VStack(alignment: .leading) {
                                Image(tip.image_name ?? "Frame 19")
                                    .resizable()
                                    .frame(width: 140, height: 140)
                                    .cornerRadius(12)
                                Text(tip.title).fontWeight(.semibold).foregroundColor(.black)
                                Text(tip.subtitle).font(.caption).foregroundColor(.gray).lineLimit(1)
                            }
                            .frame(width: 140)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

// MARK: - Reusable Components (MUTLAKA DOSYADA OLMALI)
struct CategoryCard: View {
    let title: String; let subtitle: String; let iconName: String
    let bgColor: Color; let iconBgColor: Color
    
    var body: some View {
        ZStack(alignment: .topLeading) {
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
                
                Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                Text(subtitle).font(.system(size: 10)).fontWeight(.light).foregroundColor(.black)
                
                Spacer()
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
            RoundedRectangle(cornerRadius: 15).fill(bgColor).frame(height: 90)
            HStack(spacing: 15) {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(iconBgColor).frame(width: 45, height: 45)
                        Image(iconName).resizable().frame(width: 24, height: 24)
                    }
                    Spacer()
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(.system(size: 16, weight: .bold)).foregroundColor(.black)
                    Text(subtitle).font(.system(size: 12)).fontWeight(.light).foregroundColor(.black)
                    Spacer()
                }
            }
            .padding(15)
        }
    }
}

// MARK: - Preview
#Preview {
    HomeView()
}
