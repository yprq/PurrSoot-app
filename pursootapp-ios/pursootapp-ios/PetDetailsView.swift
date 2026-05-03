import SwiftUI
import MapKit

struct PetDetailsView: View {
    let pet: Pet
    @State private var isFavorite = false
    @State private var cameraPosition: MapCameraPosition
    
    init(pet: Pet) {
        self.pet = pet
        let center = CLLocationCoordinate2D(
            latitude: pet.latitude ?? 38.4237,
            longitude: pet.longitude ?? 27.1428
        )
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(
                center: center,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        ))
    }
    
    private let primaryGreen = Color.customDarkSage
    
    var body: some View {
        GeometryReader { geometry in
            let screenWidth = geometry.size.width
            
            ZStack {
                // Arka Plan
                Color(red: 246/255, green: 246/255, blue: 246/255)
                    .ignoresSafeArea()
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        // MARK: - Pet Image Section
                        ZStack(alignment: .topTrailing) {
                            ZStack {
                                Color.customLightSage.opacity(0.35)
                                petImageView
                            }
                            .frame(width: screenWidth - 40, height: 340) // Genişlik sabitlendi
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            
                            // Favori Butonu
                            Button { isFavorite.toggle() } label: {
                                ZStack {
                                    Circle().fill(primaryGreen)
                                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white)
                                }
                                .frame(width: 52, height: 52)
                            }
                            .padding(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        
                        // MARK: - Info Section
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pet.name)
                                    .font(.custom("Poppins-SemiBold", size: 24))
                                    .foregroundColor(.black)
                                
                                Text(pet.breed ?? "Unknown Breed")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 18)
                        
                        // MARK: - Bilgi Kutucukları (Grid yapısı genişlemeyi önler)
                        HStack(spacing: 14) {
                            DetailInfoBox(title: "Gender", value: pet.gender ?? "Unknown")
                            DetailInfoBox(title: "Age", value: pet.displayAge)
                            DetailInfoBox(title: "Species", value: pet.species ?? "Other")
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 14)
                        
                        ownerCard
                            .frame(width: screenWidth - 40) // Genişlik sabitlendi
                            .padding(.horizontal, 20)
                            .padding(.top, 22)
                        
                        // MARK: - About Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("About Pet")
                                .font(.custom("Poppins-SemiBold", size: 18))
                            
                            Text(pet.description ?? "No description provided.")
                                .font(.custom("Poppins-Regular", size: 15))
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 22)
                        
                        // MARK: - Location Section
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Location")
                                .font(.custom("Poppins-SemiBold", size: 18))
                            
                            Map(position: $cameraPosition) {
                                Marker(pet.name, coordinate: pet.coordinate)
                            }
                            .frame(height: 165)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 28)
                        .padding(.bottom, 120) // Alt kısımda boşluk
                    }
                    .frame(width: screenWidth) // VStack'in ekran dışına taşmasını engeller
                }
            }
        }
        .safeAreaInset(edge: .top) { headerView }
        .navigationBarBackButtonHidden(true)
    }
    
    @ViewBuilder
    private var petImageView: some View {
        if let imageSource = pet.pet_image {
            if imageSource.hasPrefix("http") {
                AsyncImage(url: URL(string: imageSource)) { phase in
                    if let image = phase.image {
                        image.resizable()
                            .scaledToFill()
                            .frame(height: 340)
                            .clipped()
                    } else {
                        placeholderImage
                    }
                }
            } else {
                // "pig-pic" ve diğer assetler
                Image(imageSource)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 340)
                    .clipped()
            }
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        Image("nophoto")
            .resizable()
            .scaledToFill()
            .frame(height: 340)
            .clipped()
    }
    
    private var headerView: some View {
        HStack {
            BackButtonView()
            Spacer()
            Text("Pet Details").font(.custom("Poppins-SemiBold", size: 20))
            Spacer()
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up").font(.system(size: 24))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 246/255, green: 246/255, blue: 246/255))
    }
    
    private var ownerCard: some View {
        HStack(spacing: 14) {
            Group {
                if let ownerImg = pet.owner_image, !ownerImg.isEmpty {
                    if ownerImg.hasPrefix("http") {
                        AsyncImage(url: URL(string: ownerImg)) { image in
                            image.resizable().scaledToFill()
                        } placeholder: { ProgressView() }
                    } else {
                        Image(ownerImg).resizable().scaledToFill()
                    }
                } else {
                    Image("owner").resizable().scaledToFill()
                }
            }
            .frame(width: 54, height: 54)
            .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(pet.owner_name ?? "Pet Owner").font(.custom("Poppins-Medium", size: 16))
                Text(pet.owner_role ?? "Community Member").font(.custom("Poppins-Regular", size: 15)).foregroundColor(.gray)
            }
            Spacer()
            HStack(spacing: 12) {
                CircleActionButton(systemName: "phone")
                CircleActionButton(systemName: "message")
            }
        }
        .padding(14)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.1), lineWidth: 1))
    }
}

// MARK: - Reusable Components (Fix: Genişleme Sorunu Giderildi)
struct DetailInfoBox: View {
    let title: String
    let value: String
    private let infoBoxColor = Color(red: 214/255, green: 220/255, blue: 205/255)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 13))
                .foregroundColor(.gray)
            
            Text(value)
                .font(.custom("Poppins-SemiBold", size: 15))
                .foregroundColor(.black)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading) // HStack içinde eşit dağılım sağlar
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(RoundedRectangle(cornerRadius: 8).fill(infoBoxColor))
    }
}

struct CircleActionButton: View {
    let systemName: String
    var body: some View {
        ZStack {
            Circle().stroke(Color.gray.opacity(0.3), lineWidth: 1)
            Image(systemName: systemName)
                .font(.system(size: 16))
                .foregroundColor(.black)
        }
        .frame(width: 40, height: 40)
    }
}

struct BackButtonView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.black)
        }
    }
}
