import SwiftUI

struct Pet: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let imageName: String
    let category: PetCategory
    let distance: String
    let gender: String
    let age: String
    let size: String
    let ownerName: String
    let ownerRole: String
    let ownerImageName: String
    let description: String
}

enum PetCategory: String, CaseIterable {
    case all = "All"
    case dog = "Dog"
    case cat = "Cat"
    case others = "Others"
}

struct AdoptView: View {
    @State private var selectedCategory: PetCategory = .all

    private let primaryGreen = Color.customDarkSage
    private let lightGreenCard = Color.customLightSage

    private let pets: [Pet] = [
        Pet(
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
        ),
        Pet(
            name: "Max & Luna",
            imageName: "dog-pic",
            category: .dog,
            distance: "Distance 700m",
            gender: "Male",
            age: "1",
            size: "Small",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "A sweet bonded pair who enjoy attention and calm indoor environments."
        ),
        Pet(
            name: "Charlie",
            imageName: "cat-pic",
            category: .cat,
            distance: "Distance 700m",
            gender: "Male",
            age: "3",
            size: "Medium",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Charlie is calm, affectionate, and enjoys quiet spaces and cozy corners."
        ),
        Pet(
            name: "Daisy",
            imageName: "dog-pic",
            category: .dog,
            distance: "Distance 700m",
            gender: "Female",
            age: "2",
            size: "Large",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Daisy is elegant, gentle, and loves open spaces and long walks."
        ),
        Pet(
            name: "Rocky",
            imageName: "bird-pic",
            category: .others,
            distance: "Distance 700m",
            gender: "Male",
            age: "1",
            size: "Small",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Rocky is quiet, adorable, and easy to care for in a peaceful home."
        ),
        Pet(
            name: "Milo",
            imageName: "rabbit-pic",
            category: .others,
            distance: "Distance 700m",
            gender: "Male",
            age: "1",
            size: "Small",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Milo is curious and playful, with a lovable and silly personality."
        ),
        Pet(
            name: "Kiwi",
            imageName: "rabbit-pic",
            category: .others,
            distance: "Distance 700m",
            gender: "Male",
            age: "2",
            size: "Small",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Kiwi is bright, alert, and full of character."
        ),
        Pet(
            name: "Bella",
            imageName: "dog-pic",
            category: .dog,
            distance: "Distance 700m",
            gender: "Female",
            age: "2",
            size: "Medium",
            ownerName: "James Parlor",
            ownerRole: "Pet Owner",
            ownerImageName: "owner",
            description: "Bella is gentle, warm, and perfect for a loving family."
        )
    ]

    private var filteredPets: [Pet] {
        selectedCategory == .all ? pets : pets.filter { $0.category == selectedCategory }
    }

    private let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color(
                    red: 246/255,
                    green: 246/255,
                    blue: 246/255
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                        .padding(.bottom, 12)
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            categoryBar
                                .padding(.top, 22)

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

                            Spacer(minLength: 110)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(for: Pet.self) { pet in
                PetDetailsView(pet: pet)
            }
        }
    }

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

            Color.clear
                .frame(width: 28, height: 28)
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
                                .fill(
                                    selectedCategory == category
                                    ? primaryGreen
                                    : Color(red: 242/255, green: 235/255, blue: 231/255)
                                )
                        )
                }
            }

            Spacer()

            Button(action: {}) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black)
            }
        }
    }
}

struct PetCardView: View {
    let pet: Pet
    let cardColor: Color

    private let imageHeight: CGFloat = 145

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                cardColor.opacity(0.35)

                Image(pet.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            .frame(height: imageHeight)

            VStack(alignment: .leading, spacing: 3) {
                Text(pet.name)
                    .font(.custom("Poppins-Medium", size: 15))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Text(pet.distance)
                    .font(.custom("Poppins-Regular", size: 13))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
            .background(cardColor)
        }
        .frame(maxWidth: .infinity)
        .background(cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    AdoptView()
}
