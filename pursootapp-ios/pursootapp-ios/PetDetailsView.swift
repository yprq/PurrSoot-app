import SwiftUI
import MapKit

struct PetDetailsView: View {
    let pet: Pet
    @State private var isFavorite = false

    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: 38.4237,
                longitude: 27.1428
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.01,
                longitudeDelta: 0.01
            )
        )
    )

    private let primaryGreen = Color.customDarkSage

    var body: some View {
        ZStack {
            Color(
                red: 246/255,
                green: 246/255,
                blue: 246/255
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ZStack(alignment: .topTrailing) {
                        ZStack {
                            Color.customLightSage.opacity(0.35)

                            Image(pet.imageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .padding(16)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 340)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Button {
                            isFavorite.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(primaryGreen)

                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22))
                                    .foregroundColor(.white)
                            }
                            .frame(width: 52, height: 52)
                        }
                        .padding(.top, 12)
                        .padding(.trailing, 12)

                        Capsule()
                            .fill(Color.gray.opacity(0.45))
                            .frame(width: 56, height: 20)
                            .overlay(
                                HStack(spacing: 4) {
                                    ForEach(0..<5, id: \.self) { _ in
                                        Circle()
                                            .fill(Color.white)
                                            .frame(width: 6, height: 6)
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                            .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)

                    Text(pet.name)
                        .font(.custom("Poppins-SemiBold", size: 20))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 18)

                    HStack(spacing: 14) {
                        DetailInfoBox(title: "Gender", value: pet.gender)
                        DetailInfoBox(title: "Age", value: pet.age)
                        DetailInfoBox(title: "Size", value: pet.size)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 14)

                    ownerCard
                        .padding(.horizontal, 20)
                        .padding(.top, 22)

                    Text("About Pet")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 22)

                    Text(pet.description)
                        .font(.custom("Poppins-Regular", size: 15))
                        .foregroundColor(.black)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                    Text("Location")
                        .font(.custom("Poppins-SemiBold", size: 18))
                        .foregroundColor(.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 28)

                    ZStack(alignment: .bottomTrailing) {
                        Map(position: $cameraPosition) {
                            Marker(
                                pet.name,
                                coordinate: CLLocationCoordinate2D(
                                    latitude: 38.4237,
                                    longitude: 27.1428
                                )
                            )
                        }
                        .frame(height: 165)
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                        ZStack {
                            Circle()
                                .fill(Color.white)

                            Image(systemName: "camera")
                                .font(.system(size: 22))
                                .foregroundColor(primaryGreen)
                        }
                        .frame(width: 54, height: 54)
                        .padding(.trailing, 18)
                        .padding(.bottom, 18)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .padding(.bottom, 8)
                .background(
                    Color(
                        red: 246/255,
                        green: 246/255,
                        blue: 246/255
                    )
                )
        }
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
    }

    private var header: some View {
        HStack {
            BackButtonView()

            Spacer()

            Text("Pet Details")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(.black)

            Spacer()

            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.black)
            }
        }
    }

    private var ownerCard: some View {
        HStack {
            HStack(spacing: 14) {
                Image(pet.ownerImageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 54, height: 54)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.ownerName)
                        .font(.custom("Poppins-Medium", size: 16))
                        .foregroundColor(.black)

                    Text(pet.ownerRole)
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
        .padding(.horizontal, 14)
        .padding(.vertical, 16)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.45), lineWidth: 1)
        )
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

#Preview {
    NavigationStack {
        PetDetailsView(
            pet: Pet(
                name: "Husky",
                imageName: "dog-pic",
                category: .dog,
                distance: "Distance 700m",
                gender: "Male",
                age: "2",
                size: "Medium",
                ownerName: "James Parlor",
                ownerRole: "Pet Owner",
                ownerImageName: "owner",
                description: "Friendly, energetic, and loves outdoor walks. Husky is playful, social, and gets along well with people."
            )
        )
    }
}
