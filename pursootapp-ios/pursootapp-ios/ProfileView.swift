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

struct DonationRecord: Identifiable {
    let id = UUID()
    let shelterName: String
    let amount: String
    let date: String
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
    @State private var userLocation = ""
    @State private var isLocationVisible = true

    // Volunteering
    @State private var isVolunteeringActive = false

    // Pet Preferences (Filtreler)
    @State private var petType = "Hepsi"
    @State private var petAge = 1
    
    var body: some View {
            NavigationStack {
                ZStack {
                    // Arka Plan
                    Color(.systemGray6).ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header
                            headerView
                            
                            // 1. KISIM: Profil Kartı
                            ProfileHeaderCard(showOptions: $showOptions, profileImage: profileImage, name: userName, email: userEmail)
                            
                            // 2. KISIM: İstatistikler
                            StatisticsRow(donation: donationCount, adopted: adoptedCount, feeding: feedingCount)
                            
                            // 3. KISIM: Menü Grupları
                            VStack(spacing: 25) {
                                
                                // 1. Kutu: Account Security
                                ProfileMenuSection(title: "Account security") {
                                    NavigationLink(destination: ProfileInfoView(name: userName, email: userEmail)) {
                                        MenuItemRow(item: MenuItem(icon: "person", text: "Profile Info"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: ForgotPasswordView()) {
                                        MenuItemRow(item: MenuItem(icon: "lock", text: "Forgot Password"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: ResetPasswordView()) {
                                        MenuItemRow(item: MenuItem(icon: "arrow.counterclockwise", text: "Reset Password"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: PhoneVerificationView()) {
                                        MenuItemRow(item: MenuItem(icon: "phone", text: "Phone Number Verification", isVerified: true, status: false))
                                    }.buttonStyle(.plain)
                                }

                                // 2. Kutu: User Preferences
                                ProfileMenuSection(title: "User Preferences") {
                                    NavigationLink(destination: PetPreferencesView(type: $petType, age: $petAge)) {
                                        MenuItemRow(item: MenuItem(icon: "pawprint", text: "Pet Preferences"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: LocationSettingsView(location: $userLocation, isVisible: $isLocationVisible)) {
                                        MenuItemRow(item: MenuItem(icon: "mappin.and.ellipse", text: "Location and Accessibility"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: VolunteeringSettingsView(isActive: $isVolunteeringActive)) {
                                        MenuItemRow(item: MenuItem(icon: "heart.text.square", text: "Volunteering"))
                                    }.buttonStyle(.plain)
                                }
                                
                                // 3. Kutu: Donation
                                ProfileMenuSection(title: "Donation") {
                                    NavigationLink(destination: UPISettingsView()) {
                                        MenuItemRow(item: MenuItem(icon: "creditcard", text: "UPI Settings"))
                                    }.buttonStyle(.plain)
                                    
                                    NavigationLink(destination: DonationHistoryView()) {
                                        MenuItemRow(item: MenuItem(icon: "clock.arrow.circlepath", text: "Donation History"))
                                    }.buttonStyle(.plain)
                                }
                                
                                // 4. Kutu: Support
                                ProfileMenuSection(title: "Support") {
                                    NavigationLink(destination: SupportView()) {
                                        MenuItemRow(item: MenuItem(icon: "envelope.fill", text: "Contact Us"))
                                    }.buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 10)
                        }
                        .padding()
                    } // ScrollView sonu
                } // ZStack sonu
                .sheet(isPresented: $showSettings) {
                    EditProfileView(name: $userName, email: $userEmail)
                }
                .confirmationDialog("Profil Fotoğrafı", isPresented: $showOptions, titleVisibility: .visible) {
                    Button("Kamera") { showCamera = true }
                    Button("Galeri") { showGallery = true }
                    Button("İptal", role: .cancel) { }
                }
            } // NavigationStack sonu
            .photosPicker(isPresented: $showGallery, selection: $selectedItem, matching: .images)
            .fullScreenCover(isPresented: $showCamera) {
                CameraPlaceholderView(image: $profileImage)
            }
            .onChange(of: selectedItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                    }
                }
            }
        }

        // Küçük bir yardımcı: Header
        var headerView: some View {
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
        }}

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

struct ProfileMenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.leading, 5)
            
            VStack(spacing: 18) {
                content() // İçeriği dışarıdan alıp buraya basar
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

struct PhoneVerificationView:  View {
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var isCodeSent = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            if !isCodeSent {
                Section(header: Text("Telefon Numaranı Doğrula")) {
                    TextField("Telefon Numarası (Örn: 05xx)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onAppear {
                                // Sayfa açıldığında otomatik odaklanması için (Opsiyonel)
                            }
                    
                    
                    Button(action: { isCodeSent = true }) {
                        Text("Onay Kodu Gönder")
                            .fontWeight(.semibold)
                    }
                }
            } else {
                Section(header: Text("SMS Kodunu Gir"), footer: Text("\(phoneNumber) numarasına gönderilen 6 haneli kodu giriniz.")) {
                    TextField("Onay Kodu", text: $verificationCode)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        // Burada doğrulama mantığı çalışır
                        dismiss()
                    }) {
                        Text("Doğrula ve Bitir")
                            .fontWeight(.semibold)
                    }
                    
                    Button("Kodu Tekrar Gönder") {
                        // Yeniden gönderme fonksiyonu
                    }
                    .font(.caption)
                    .foregroundColor(.gray)
                }
            }
        }
        .navigationTitle("Phone Verification")
    }
}

// --- LOCATION & ACCESSIBILITY ---
struct LocationSettingsView: View {
    @Binding var location: String
    @Binding var isVisible: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Konum Bilgileri")) {
                TextField("Şehir/Semt Giriniz", text: $location)
                Toggle("Konumum Diğer Kullanıcılara Görünsün", isOn: $isVisible)
            }
        }
        .navigationTitle("Location")
    }
}

struct VolunteeringSettingsView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Gönüllülük Durumu")) {
                Toggle("Gönüllü Olmak İstiyorum", isOn: $isActive)
                    .tint(.green)
            }
        }
        .navigationTitle("Volunteering")
    }
}

// --- SADECE PET FİLTRELERİ ---
struct PetPreferencesView: View {
    @Binding var type: String
    @Binding var age: Int
    let petTypes = ["Kedi", "Köpek", "Kuş", "Hepsi"]
    
    var body: some View {
        Form {
            Section(header: Text("Filtre Tercihleriniz")) {
                Picker("Tercih Edilen Tür", selection: $type) {
                    ForEach(petTypes, id: \.self) { Text($0) }
                }
                
                Stepper("Yaş Tercihi: \(age)", value: $age, in: 1...20)
            }
        }
        .navigationTitle("Pet Preferences")
    }
}

struct UPISettingsView: View {
    @State private var upiID: String = "jamesparlor@upi"
    @State private var isFastPayEnabled: Bool = true
    @State private var showAddSheet: Bool = false
    @State private var newUpiID: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Mevcut Hesap")) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text(upiID)
                        .font(.body)
                }
            }
            
            Section(header: Text("Ayarlar"), footer: Text("Hızlı ödeme özelliği ile küçük bağışlar tek tıkla onaylanır.")) {
                Toggle("Hızlı Bağış", isOn: $isFastPayEnabled)
                    .tint(.green)
            }
            
            Section {
                Button(action: { showAddSheet = true }) {
                    Label("Yeni UPI Hesabı Ekle", systemImage: "plus.circle")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("UPI Settings")
        // Alttan açılan form
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form {
                    TextField("Yeni UPI ID (örn: ad@banka)", text: $newUpiID)
                        .autocapitalization(.none)
                    
                    Button("Kaydet") {
                        if !newUpiID.isEmpty {
                            upiID = newUpiID
                            newUpiID = ""
                            showAddSheet = false
                        }
                    }
                }
                .navigationTitle("Hesap Ekle")
                .toolbar {
                    Button("Kapat") { showAddSheet = false }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

class DonationViewModel: ObservableObject {
    @Published var donations: [DonationRecord] = [] // Backend'den gelince otomatik güncellenir
    @Published var isLoading = false // Veri yükleniyor animasyonu için
    
    // Backend'den verileri çeken fonksiyon (Şu an taslak)
    func fetchDonations() {
        self.isLoading = true
        // Burada URLSession ile backend API'ne istek atacağız
        // Örn: https://api.purrsoot.com/donations
        
        // Şimdilik test için boş gelsin veya mevcutları yükle
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.isLoading = false
            // Buraya gelen JSON verisi atanacak
        }
    }
}

struct DonationHistoryView: View {
    @StateObject var viewModel = DonationViewModel() // ViewModel bağlandı
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Bağışlar yükleniyor...") // Backend beklerken dönen simge
            } else if viewModel.donations.isEmpty {
                Text("Kayıt bulunamadı.")
            } else {
                ForEach(viewModel.donations) { item in
                    // ... Satır tasarımı aynı kalıyor ...
                    HStack {
                        VStack(alignment: .leading) {
                            Text(item.shelterName).fontWeight(.semibold)
                            Text(item.date).font(.caption).foregroundColor(.gray)
                        }
                        Spacer()
                        Text(item.amount).foregroundColor(.green).fontWeight(.bold)
                    }
                }
            }
        }
        .navigationTitle("Donation History")
        .onAppear {
            viewModel.fetchDonations() // Sayfa açılınca backend'i çağır
        }
    }
}
struct SupportView: View {
    let emailAddress = "support@purrsoot.com"
    
    var body: some View {
        Form {
            Section(header: Text("İletişim Bilgilerimiz"), footer: Text("Size en kısa sürede dönüş yapmaya çalışacağız.")) {
                HStack {
                    Image(systemName: "envelope.circle.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                    
                    VStack(alignment: .leading) {
                        Text("E-posta")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(emailAddress)
                            .fontWeight(.medium)
                    }
                    
                    Spacer()
                    
                    // Kopyalama butonu (Mühendis dokunuşu)
                    Button(action: {
                        UIPasteboard.general.string = emailAddress
                    }) {
                        Image(systemName: "doc.on.doc")
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 5)
            }
            
            Section {
                Button(action: {
                    // Cihazdaki mail uygulamasını açmaya çalışır
                    if let url = URL(string: "mailto:\(emailAddress)") {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Label("Mail Uygulamasını Aç", systemImage: "paperplane.fill")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("Support")
    }
}

// --- PREVIEWS ---
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
