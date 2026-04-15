import SwiftUI
import PhotosUI

// --- MODELLER ---
struct MenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let text: String
    var isVerified: Bool = false
    var status: Bool = true
}

// --- ANA EKRAN ---
struct ProfileView: View {
    @State private var showOptions = false             // Menüyü açan anahtar
    @State private var showGallery = false             // Galeriyi açan anahtar
    @State private var showCamera = false
    // Kamerayı açan anahtar
    @State private var showSettings = false
    @State private var userName = "James Parlor"
    @State private var userEmail = "jamesparlor@gmail.com"
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = Image("Robert_Pattinson")
    @State private var donationCount = "3k+"
    @State private var adoptedCount = "1"
    @State private var feedingCount = "72"
    
    var body: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Spacer()
                        Text("Profile").font(.headline).fontWeight(.bold)
                        Spacer()
                        Button(action: { showSettings = true }) {
                            Image(systemName: "slider.horizontal.3")
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 1. KISIM: Profil Kartı
                    ProfileHeaderCard(showOptions: $showOptions, profileImage: profileImage, name: userName, email: userEmail)
                    
                    // 2. KISIM: İstatistikler
                    StatisticsRow(donation: donationCount, adopted: adoptedCount, feeding: feedingCount)
                    
                    // 3. KISIM: Menü Grupları
                    VStack(spacing: 25) {
                        ProfileMenuSection(title: "Account security", items: [
                            MenuItem(icon: "person", text: "Profile Info"),
                            MenuItem(icon: "lock", text: "Forgot Password"),
                            MenuItem(icon: "checkmark.circle", text: "Phone Number Verification", isVerified: true)
                        ])
                        
                        ProfileMenuSection(title: "User Preferences", items: [
                            MenuItem(icon: "pawprint", text: "Pet Preferences"),
                            MenuItem(icon: "mappin.and.ellipse", text: "Location and Accessibility")
                        ])
                    }
                    .padding(.top, 10)
                }
                .padding()
                .sheet(isPresented: $showSettings) {
                    EditProfileView(name: $userName, email: $userEmail)
                }
            }
        }
        // SEÇENEK MENÜSÜ (Confirmation Dialog)
        .confirmationDialog("Profil Fotoğrafı", isPresented: $showOptions, titleVisibility: .visible) {
            Button("Kamera ile Çek") {
                showCamera = true
            }
            Button("Galeriden Seç") {
                showGallery = true
            }
            if profileImage != nil {
                Button("Fotoğrafı Kaldır", role: .destructive) {
                    profileImage = nil
                    selectedItem = nil
                }
            }
            Button("İptal", role: .cancel) { }
        }
        // GALERİ TETİKLEYİCİ
        .photosPicker(isPresented: $showGallery, selection: $selectedItem, matching: .images)
        // KAMERA TETİKLEYİCİ (Not: SwiftUI'da hazır kamera yoktur, aşağıda basit bir çözüm ekledim)
        .fullScreenCover(isPresented: $showCamera) {
            CameraPlaceholderView(image: $profileImage)
        }
        // Galeri seçimi sonrası resmi yükleme
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    profileImage = Image(uiImage: uiImage)
                }
            }
        }
    }
}

// --- BİLEŞENLER ---

struct ProfileHeaderCard: View {
    @Binding var showOptions: Bool
    let profileImage: Image?
    let name: String  // Bunu ekle
    let email: String
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                if let image = profileImage {
                    image.resizable().scaledToFill()
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .onTapGesture { showOptions = true }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                Text(email)
            }
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(25)
    }
}

// Kamera için Geçici Görünüm (Gerçek kamera için UIViewControllerRepresentable gerekir)
struct CameraPlaceholderView: View {
    @Binding var image: Image?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Kamera Modülü").font(.title)
            Text("Simülatörde kamera çalışmaz, gerçek cihaz gerekir.")
                .multilineTextAlignment(.center).padding()
            Button("Kapat") { dismiss() }
                .padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
        }
    }
}

// --- DİĞER BİLEŞENLER (StatisticsRow, StatBox, MenuSection aynen kalıyor) ---
struct StatisticsRow: View {
    let donation: String
    let adopted: String
    let feeding: String
    
    var body: some View {
        HStack(spacing: 10) {
            StatBox(value: donation, title: "Donation", icon: "volunteer_activism")
            Divider().frame(height: 30)
            StatBox(value: adopted, title: "Adopted", icon: "pets")
            Divider().frame(height: 30)
            StatBox(value: feeding, title: "Feeding", icon: "gift")
        }
        .padding(12)
        .background(Color.green.opacity(0.1))
        .cornerRadius(20)
    }
}

struct StatBox: View {
    let value: String; let title: String; let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(.headline).fontWeight(.bold)
            HStack(spacing: 4) {
                Image(icon) // systemName: kısmını sildik
                        .resizable() // Boyutlandırılabilir yaptık
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .padding(8) // İkon ile kare kenarı arasındaki boşluk
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.green.opacity(0.5)) // Biraz daha koyu yeşil (opaklığı artırabilirsin)
                                        )
                    
                    Text(title).font(.caption2)
            }
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10).background(Color.white).cornerRadius(15).shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct EditProfileView: View {
    @Binding var name: String   // Ana sayfadaki userName'e bağlı
    @Binding var email: String  // Ana sayfadaki userEmail'e bağlı
    @Environment(\.dismiss) var dismiss // Sayfayı kapatmak için
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Kullanıcı Bilgileri")) {
                    TextField("Ad Soyad", text: $name)
                    TextField("E-posta", text: $email)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarItems(trailing: Button("Bitti") { dismiss() })
        }
    }
}

struct ProfileMenuSection: View {
    let title: String; let items: [MenuItem]
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.subheadline).foregroundColor(.gray).padding(.leading, 5)
            VStack(spacing: 18) {
                ForEach(items) { item in
                    MenuItemRow(item: item)
                }
            }
            .padding().background(Color.green.opacity(0.05)).cornerRadius(20)
        }
    }
}

struct MenuItemRow: View {
    let item: MenuItem
    var body: some View {
        HStack {
            Image(systemName: item.icon).foregroundColor(.green.opacity(0.7)).frame(width: 25)
            Text(item.text).font(.system(size: 16))
            Spacer()
            if item.isVerified {
                Image(systemName: item.status ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .foregroundColor(item.status ? .green : .red)
            } else {
                Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
            }
        }
    }
}

// --- ŞİFRE SIFIRLAMA EKRANI ---
struct ResetPasswordView: View {
    @State private var oldPass = ""
    @State private var newPass = ""
    @State private var confirmPass = ""
    
    var body: some View {
        Form {
            Section(header: Text("Şifre Değiştir")) {
                SecureField("Eski Şifre", text: $oldPass)
                SecureField("Yeni Şifre", text: $newPass)
                SecureField("Yeni Şifre (Tekrar)", text: $confirmPass)
            }
            Button("Güncelle") { /* Güncelleme mantığı */ }
        }
        .navigationTitle("Reset Password")
    }
}

// --- ŞİFREMİ UNUTTUM EKRANI ---
struct ForgotPasswordView: View {
    @State private var email = ""
    
    var body: some View {
        Form {
            Section(header: Text("E-posta adresinize sıfırlama linki gönderilecek")) {
                TextField("E-posta", text: $email)
            }
            Button("Gönder") { /* Mail atma mantığı */ }
        }
        .navigationTitle("Forgot Password")
    }
}

// --- PROFİL BİLGİLERİ EKRANI ---
struct ProfileInfoView: View {
    // Buraya ne koyacağını bilemediğin için: Genellikle kullanıcı adı, e-posta,
    // katılım tarihi ve varsa "Bio" kısmı gösterilir.
    let name: String
    let email: String
    
    var body: some View {
        List {
            LabeledContent("Ad Soyad", value: name)
            LabeledContent("E-posta", value: email)
            LabeledContent("Üyelik Tipi", value: "Premium")
            LabeledContent("Katılım", value: "Nisan 2026")
        }
        .navigationTitle("Profile Info")
    }
}

// --- PREVIEWS ---
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
