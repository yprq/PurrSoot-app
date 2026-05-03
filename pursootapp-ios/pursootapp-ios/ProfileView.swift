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
    @StateObject var profileService = ProfileService()

    @State private var showOptions = false
    @State private var showGallery = false
    @State private var showCamera = false
    @State private var showSettings = false
   
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    
    // Form durumları (Filtreler ve ayarlar için)
    @State private var userLocation = ""
    @State private var isLocationVisible = true
    @State private var isVolunteeringActive = false
    @State private var petType = "All"
    @State private var petAge = 1
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray6).ignoresSafeArea()
                
                if let user = profileService.user {
                    ScrollView {
                        VStack(spacing: 20) {
                            headerBar
                            
                            // 1. KISIM: Profil Kartı (Dinamik PFP ve İsim)[cite: 9]
                            ProfileHeaderCard(
                                showOptions: $showOptions,
                                profileImage: profileImage,
                                name: user.username,
                                email: user.email,
                                serverImageName: user.profile_image
                            )
                            
                            // 2. KISIM: İstatistikler (Backend'den gelen veriler)[cite: 9]
                            StatisticsRow(
                                donation: user.donation_total,
                                adopted: "\(user.adopted_count ?? 0)",
                                feeding: "\(user.feeding_count)"
                            )
                            
                            // 3. KISIM: Menü Grupları (Bölümlere ayırarak derleyiciyi rahatlattık)
                            Group {
                                securityMenu(user: user)
                                preferencesMenu()
                                donationAndSupportMenu()
                            }
                        }
                        .padding()
                    }
                } else {
                    ProgressView("Loading Profile...")
                        .padding(.top, 100)
                }
            }
            .onAppear {
                // Giriş yapan kullanıcının ID'sini UserDefaults'tan çekiyoruz[cite: 11]
                let loggedInUserId = UserDefaults.standard.integer(forKey: "current_user_id")
                if loggedInUserId != 0 {
                    profileService.fetchProfile(userId: loggedInUserId)
                }
            }
            .confirmationDialog("Profile Photo", isPresented: $showOptions, titleVisibility: .visible) {
                Button("Camera") { showCamera = true }
                Button("Gallery") { showGallery = true }
                Button("Cancel", role: .cancel) { }
            }
        }
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
}

// MARK: - Menü Bölümleri (Subviews)
extension ProfileView {
    
    private var headerBar: some View {
        HStack {
            Spacer()
            Text("Profile").font(.headline).fontWeight(.bold)
            Spacer()
            Button(action: { showSettings = true }) {
                Image(systemName: "slider.horizontal.3").foregroundColor(.primary)
            }
        }
        .padding(.horizontal)
    }

    private func securityMenu(user: UserProfile) -> some View {
        ProfileMenuSection(title: "Account security") {
            NavigationLink(destination: ProfileInfoView(name: user.username, email: user.email)) {
                MenuItemRow(item: MenuItem(icon: "person", text: "Profile Info"))
            }.buttonStyle(.plain)
            
            NavigationLink(destination: ForgotPasswordView()) {
                MenuItemRow(item: MenuItem(icon: "lock", text: "Forgot Password"))
            }.buttonStyle(.plain)
            
            NavigationLink(destination: ResetPasswordView()) {
                MenuItemRow(item: MenuItem(icon: "arrow.counterclockwise", text: "Reset Password"))
            }.buttonStyle(.plain)
        }
    }

    private func preferencesMenu() -> some View {
        ProfileMenuSection(title: "User Preferences") {
            NavigationLink(destination: PetPreferencesView(type: $petType, age: $petAge)) {
                MenuItemRow(item: MenuItem(icon: "pawprint", text: "Pet Preferences"))
            }.buttonStyle(.plain)
            
            NavigationLink(destination: VolunteeringSettingsView(isActive: $isVolunteeringActive)) {
                MenuItemRow(item: MenuItem(icon: "heart.text.square", text: "Volunteering"))
            }.buttonStyle(.plain)
        }
    }

    private func donationAndSupportMenu() -> some View {
        ProfileMenuSection(title: "Support & Donation") {
            NavigationLink(destination: DonationHistoryView()) {
                MenuItemRow(item: MenuItem(icon: "clock.arrow.circlepath", text: "Donation History"))
            }.buttonStyle(.plain)
            
            NavigationLink(destination: SupportView()) {
                MenuItemRow(item: MenuItem(icon: "envelope.fill", text: "Contact Us"))
            }.buttonStyle(.plain)
        }
    }
}

// MARK: - Dinamik Bileşenler

struct ProfileHeaderCard: View {
    @Binding var showOptions: Bool
    let profileImage: Image?
    let name: String
    let email: String
    let serverImageName: String?
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                if let image = profileImage {
                    image.resizable().scaledToFill()
                } else {
                    ProfileImageView(imageName: serverImageName)
                }
            }
            .frame(width: 70, height: 70)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
            .onTapGesture { showOptions = true }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name).font(.custom("Poppins-SemiBold", size: 18))
                Text(email).font(.custom("Poppins-Regular", size: 14)).foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(25)
    }
}

struct ProfileImageView: View {
    let imageName: String?
    
    var body: some View {
        Group {
            // Sadece nil değil, aynı zamanda boş string ("") olup olmadığını da kontrol ediyoruz
            if let imgName = imageName, !imgName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                if imgName.hasPrefix("http") {
                    AsyncImage(url: URL(string: imgName)) { image in
                        image.resizable().scaledToFill()
                    } placeholder: { ProgressView() }
                } else if let data = Data(base64Encoded: imgName), let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage).resizable().scaledToFill()
                } else {
                    // Eğer asset adı olarak gönderildiyse[cite: 1]
                    Image(imgName)
                        .resizable()
                        .scaledToFill()
                }
            } else {
                // Backend verisi boşsa veya nil ise direkt bu asseti bas[cite: 1]
                Image("nopfp")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 70, height: 70)
        .clipped()
    }
}

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
        .padding(12).background(Color.green.opacity(0.1)).cornerRadius(20)
    }
}

struct StatBox: View {
    let value: String; let title: String; let icon: String
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(value).font(.headline).fontWeight(.bold)
            HStack(spacing: 4) {
                Image(icon).resizable().scaledToFit().frame(width: 12, height: 12).padding(8)
                    .background(RoundedRectangle(cornerRadius: 8).fill(Color.green.opacity(0.5)))
                Text(title).font(.caption2)
            }.foregroundColor(.gray)
        }.frame(maxWidth: .infinity, alignment: .leading).padding(10).background(Color.white).cornerRadius(15).shadow(color: Color.black.opacity(0.05), radius: 5)
    }
}

struct ProfileMenuSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.subheadline).foregroundColor(.gray).padding(.leading, 5)
            VStack(spacing: 18) { content() }.padding().background(Color.green.opacity(0.05)).cornerRadius(20)
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
            Image(systemName: "chevron.right").font(.system(size: 14, weight: .bold)).foregroundColor(.gray)
        }
    }
}

struct CameraPlaceholderView: View {
    @Binding var image: Image?
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack(spacing: 20) {
            Text("Camera Module").font(.title)
            Button("Close") { dismiss() }.padding().background(Color.blue).foregroundColor(.white).cornerRadius(10)
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
            Section(header: Text("Change Password")) {
                SecureField("Old Password", text: $oldPass)
                SecureField("New Password", text: $newPass)
                SecureField("Confirm New Password", text: $confirmPass)
            }
            Button("Update") { /* Güncelleme mantığı */ }
        }
        .navigationTitle("Reset Password")
    }
}

// --- ŞİFREMİ UNUTTUM EKRANI ---
struct ForgotPasswordView: View {
    @State private var email = ""
    
    var body: some View {
        Form {
            Section(header: Text("A reset link will be sent to your email")) {
                TextField("Email", text: $email)
            }
            Button("Send") { /* Mail atma mantığı */ }
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
            LabeledContent("Full Name", value: name)
            LabeledContent("Email", value: email)
            LabeledContent("Membership Type", value: "Premium")
            LabeledContent("Joined", value: "April 2026")
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
                Section(header: Text("Verify Your Phone Number")) {
                    TextField("Phone Number (e.g., 05xx)", text: $phoneNumber)
                        .keyboardType(.phonePad)
                        .onAppear {
                                // Sayfa açıldığında otomatik odaklanması için (Opsiyonel)
                            }
                    
                    
                    Button(action: { isCodeSent = true }) {
                        Text("Send Verification Code")
                            .fontWeight(.semibold)
                    }
                }
            } else {
                Section(header: Text("Enter SMS Code"), footer: Text("Enter the 6-digit code sent to \(phoneNumber).")) {
                    TextField("Verification Code", text: $verificationCode)
                        .keyboardType(.numberPad)
                    
                    Button(action: {
                        // Burada doğrulama mantığı çalışır
                        dismiss()
                    }) {
                        Text("Verify and Finish")
                            .fontWeight(.semibold)
                    }
                    
                    Button("Resend Code") {
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
            Section(header: Text("Location Details")) {
                TextField("Enter City/District", text: $location)
                Toggle("Show My Location to Other Users", isOn: $isVisible)
            }
        }
        .navigationTitle("Location")
    }
}

struct VolunteeringSettingsView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Form {
            Section(header: Text("Volunteering Status")) {
                Toggle("I want to be a volunteer", isOn: $isActive)
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
    let petTypes = ["Cat", "Dog", "Bird", "All"]
    
    var body: some View {
        Form {
            Section(header: Text("Your Filter Preferences")) {
                Picker("Preferred Type", selection: $type) {
                    ForEach(petTypes, id: \.self) { Text($0) }
                }
                
                Stepper("Age Preferencei: \(age)", value: $age, in: 1...20)
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
            Section(header: Text("Current Account")) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text(upiID)
                        .font(.body)
                }
            }
            
            Section(header: Text("Settings"), footer: Text("With the fast payment feature, small donations are approved with one click.")) {
                Toggle("Fast Donation", isOn: $isFastPayEnabled)
                    .tint(.green)
            }
            
            Section {
                Button(action: { showAddSheet = true }) {
                    Label("Add New UPI Account", systemImage: "plus.circle")
                        .foregroundColor(.green)
                }
            }
        }
        .navigationTitle("UPI Settings")
        // Alttan açılan form
        .sheet(isPresented: $showAddSheet) {
            NavigationStack {
                Form {
                    TextField("New UPI ID (e.g., name@bank)", text: $newUpiID)
                        .autocapitalization(.none)
                    
                    Button("Save") {
                        if !newUpiID.isEmpty {
                            upiID = newUpiID
                            newUpiID = ""
                            showAddSheet = false
                        }
                    }
                }
                .navigationTitle("Add Account")
                .toolbar {
                    Button("Close") { showAddSheet = false }
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
                ProgressView("Donations are loading...") // Backend beklerken dönen simge
            } else if viewModel.donations.isEmpty {
                Text("No records found.")
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
            Section(header: Text("Contact Information"), footer: Text("We will try to get back to you as soon as possible.")) {
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
                    Label("Open Mail App", systemImage: "paperplane.fill")
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
