import SwiftUI

// --- MODELLER (Eksik olan veri yapıları) ---
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    var isVerified: Bool = false
}

// --- ANA EKRAN ---
struct ProfileView: View {
    var body: some View {
        ZStack {
            // Arka Plan (Assets'te "AppBackground" yoksa açık gri renk basar)
            Color("AppBackground")
                .overlay(Color.gray.opacity(0.05))
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Spacer()
                        Text("Profile")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Image(systemName: "slider.horizontal.3")
                    }
                    .padding(.horizontal)

                    ProfileHeaderCard()

                    StatisticsRow()

                    // Menü Grupları
                    VStack(spacing: 25) {
                        ProfileMenuSection(title: "Account security", items: [
                            MenuItem(icon: "person", text: "Profile Info"),
                            MenuItem(icon: "lock", text: "Forgot Password"),
                            MenuItem(icon: "arrow.counterclockwise", text: "Reset Password"),
                            MenuItem(icon: "checkmark.circle", text: "Phone Number Verification", isVerified: true)
                        ])
                        
                        ProfileMenuSection(title: "User Preferences", items: [
                            MenuItem(icon: "pawprint", text: "Pet Preferences"),
                            MenuItem(icon: "mappin.and.ellipse", text: "Location and Accessibility"),
                            MenuItem(icon: "person.2", text: "Volunteering")
                        ])
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
        }
    }
}

// --- BİLEŞENLER (Components) ---

struct ProfileHeaderCard: View {
    var body: some View {
        HStack(spacing: 15) {
            // James'in resmi yoksa diye placeholder koydum
            Image(systemName: "person.crop.circle.fill")
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .foregroundColor(.gray)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white.opacity(0.5), lineWidth: 2))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("James Parlor")
                    .font(.title3)
                    .fontWeight(.semibold)
                Text("jamesparlor@gmail.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1)) // CardGreen yerine şimdilik direkt renk
        .cornerRadius(25)
    }
}

struct StatisticsRow: View {
    var body: some View {
        HStack(spacing: 12) {
            StatBox(value: "3k+", title: "Donation", icon: "heart.fill")
            StatBox(value: "1", title: "Adopted", icon: "pawprint.fill")
            StatBox(value: "72", title: "Feeding", icon: "leaf.fill")
        }
    }
}

struct StatBox: View {
    let value: String
    let title: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 10))
                Text(title)
                    .font(.caption2)
            }
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct ProfileMenuSection: View {
    let title: String
    let items: [MenuItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(spacing: 18) {
                ForEach(items) { item in
                    MenuItemRow(item: item)
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(20)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    
    var body: some View {
        HStack {
            Text(item.text)
                .font(.system(size: 16))
            Spacer()
            if item.isVerified {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray)
            }
        }
    }
}

// --- PREVIEW ---
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
