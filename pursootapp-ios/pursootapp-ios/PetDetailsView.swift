import SwiftUI
import MapKit

struct PetDetailsView: View {
    let pet: Pet // AdoptView'dan gelen dinamik pet nesnesi
    @State private var isFavorite = false

    // Harita pozisyonunu pet'in koordinatlarına göre ayarlıyoruz
    @State private var cameraPosition: MapCameraPosition

    init(pet: Pet) {
        self.pet = pet
        // Eğer koordinat yoksa varsayılan (örneğin İzmir) bir konum göster
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
        ZStack {
            Color(red: 246/255, green: 246/255, blue: 246/255).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    // MARK: - Pet Image Section
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Color.customLightSage.opacity(0.35)
                            Image(pet.pet_image ?? "dog-pic") // Veritabanındaki resim adı
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(16)
                        }
                        .frame(height: 340)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                        .padding([.top, .trailing], 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    // MARK: - Info Section
                    Text(pet.name)
                        .font(.custom("Poppins-SemiBold", size: 24))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)

                    HStack(spacing: 14) {
                        DetailInfoBox(title: "Gender", value: pet.gender ?? "Unknown")
                        DetailInfoBox(title: "Age", value: pet.age ?? "N/A")
                        DetailInfoBox(title: "Size", value: pet.size ?? "Med")
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    // MARK: - Owner Section (seed.sql'deki JOIN verisi)
                    ownerCard
                        .padding(.horizontal, 20)
                        .padding(.top, 22)

                    // MARK: - About Section
                    Text("About Pet")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .padding(.horizontal, 20)
                        .padding(.top, 22)

                    Text(pet.description ?? "No description provided.")
                        .font(.custom("Poppins-Regular", size: 15))
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    // MARK: - Location Section (Dinamik Harita)
                    Text("Location")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

                    ZStack(alignment: .bottomTrailing) {
                        Map(position: $cameraPosition) {
                            Marker(pet.name, coordinate: CLLocationCoordinate2D(
                                latitude: pet.latitude ?? 38.4237,
                                longitude: pet.longitude ?? 27.1428
                            ))
                        }
                        .frame(height: 165)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .safeAreaInset(edge: .top) { headerView }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Components
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
        HStack {
            HStack(spacing: 14) {
                Image(pet.owner_image ?? "owner") // seed.sql -> users.profile_image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.owner_name ?? "James Parlor")
                        .font(.custom("Poppins-Medium", size: 16))
                    Text(pet.owner_role ?? "Pet Owner")
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            HStack(spacing: 12) {
                CircleActionButton(systemName: "phone")
                CircleActionButton(systemName: "message")
            }
        }
        .padding(14)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.3), lineWidth: 1))
    }
}

struct DetailInfoBox: View {
    let title: String
    let value: String

    private let infoBoxColor = Color(
        red: 214/255,
        green: 220/255,
        blue: 205/255
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(.gray)

            Text(value)
                .font(.custom("Poppins-SemiBold", size: 16))
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity, minHeight: 78, alignment: .leading)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(infoBoxColor)
        )
    }
}

struct CircleActionButton: View {
    let systemName: String

    var body: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.7), lineWidth: 1)

                Image(systemName: systemName)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
            }
            .frame(width: 44, height: 44)
        }
    }
}

struct BackButtonView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Button(action: {
            dismiss()
        }) {
            Image(systemName: "chevron.left")
                .font(.system(size: 28, weight: .medium))
                .foregroundColor(.black)
        }
    }
}
