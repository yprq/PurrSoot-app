import SwiftUI

struct SignUpView: View {
    let onBackTap: () -> Void
    let onSignInTap: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isAgreed = false
    @State private var showAlert = false
    
    @StateObject var authManager = AuthManager()

    // MARK: - Şifre Kontrol Mantığı
    var hasLength: Bool { password.count >= 8 }
    var hasUppercase: Bool { password.rangeOfCharacter(from: .uppercaseLetters) != nil }
    var hasNumber: Bool { password.rangeOfCharacter(from: .decimalDigits) != nil }
    var hasSpecial: Bool { password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*(),.?\":{}|<>")) != nil }
    
    var isFormValid: Bool {
        !fullName.isEmpty && email.contains("@") && hasLength && hasUppercase && hasNumber && hasSpecial && isAgreed
    }

    var body: some View {
        ZStack {
            Color(red: 246/255, green: 246/255, blue: 246/255).ignoresSafeArea()

            VStack(spacing: 0) {
                // Header (Chevron ve Title aynı kalıyor)
                headerView

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        welcomeTexts

                        VStack(alignment: .leading, spacing: 18) {
                            // Full Name & Email (Aynı kalıyor)
                            inputSection
                            
                            // Password Section
                            Text("Password").font(.custom("Poppins-SemiBold", size: 20))
                            AuthSecureField(placeholder: "••••••", text: $password)
                            
                            // MARK: - Şifre Güvenlik Listesi
                            VStack(alignment: .leading, spacing: 8) {
                                validationRow(text: "At least 8 characters", isMet: hasLength)
                                validationRow(text: "At least one uppercase letter", isMet: hasUppercase)
                                validationRow(text: "At least one number", isMet: hasNumber)
                                validationRow(text: "At least one special character", isMet: hasSpecial)
                            }
                            .padding(.top, 4)

                            // Sunucu Hatası (Email zaten varsa kırmızı yazı burada çıkar)
                            if let serverError = authManager.serverErrorMessage {
                                Text(serverError)
                                    .foregroundColor(.red)
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .padding(.top, 4)
                            }

                            termsAndConditions
                        }
                        .padding(.horizontal, 36)
                        .padding(.top, 30)

                        signUpButton
                        
                        footerSection
                    }
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Successful!"), message: Text("Redirecting to login..."), dismissButton: .default(Text("Okay")) { onSignInTap() })
        }
    }

    // MARK: - Yardımcı Viewlar
    private func validationRow(text: String, isMet: Bool) -> some View {
        HStack {
            Image(systemName: isMet ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isMet ? .green : .gray.opacity(0.5))
            Text(text)
                .font(.custom("Poppins-Regular", size: 14))
                .foregroundColor(isMet ? .black : .gray)
        }
    }

    private var signUpButton: some View {
        Button(action: {
            authManager.signUp(username: fullName, email: email, password: password) { success in
                if success { showAlert = true }
            }
        }) {
            Text("Sign Up")
                .font(.custom("Poppins-SemiBold", size: 20))
                .foregroundColor(isFormValid ? Color.customDarkSage : .white)
                .frame(width: 285, height: 72)
                .background(isFormValid ? Color.clear : Color.gray.opacity(0.3))
                .overlay(Capsule().stroke(isFormValid ? Color.customDarkSage : Color.clear, lineWidth: 3))
                .clipShape(Capsule())
        }
        .disabled(!isFormValid)
        .padding(.top, 40)
    }
    
    // Header, welcomeTexts, termsAndConditions, footerSection gibi kısımları eski kodundan buraya kopyalayabilirsin...
    private var headerView: some View {
        HStack {
            Button(action: onBackTap) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.black.opacity(0.85))
                    .frame(width: 54, height: 54)
                    .overlay(Circle().stroke(Color.gray.opacity(0.35), lineWidth: 1.5))
            }
            Spacer()
            Text("Sign Up").font(.custom("Poppins-Regular", size: 20))
            Spacer()
            Color.clear.frame(width: 54, height: 54)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    private var welcomeTexts: some View {
        VStack {
            Text("Welcome").font(.custom("Poppins-Bold", size: 30)).padding(.top, 30)
            Text("Please enter your informations here").font(.custom("Poppins-Regular", size: 15)).foregroundColor(.gray)
        }
    }

    private var inputSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Full name").font(.custom("Poppins-SemiBold", size: 20))
            AuthTextField(placeholder: "George", text: $fullName)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            Text("Email").font(.custom("Poppins-SemiBold", size: 20))
            AuthTextField(placeholder: "example@gmail.com", text: $email)
                .textInputAutocapitalization(.never)
        }
    }

    private var termsAndConditions: some View {
        Button(action: { isAgreed.toggle() }) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1.6).frame(width: 24, height: 24)
                    if isAgreed { Image(systemName: "checkmark").font(.system(size: 14, weight: .bold)).foregroundColor(Color.customDarkSage) }
                }
                Text("I agree with terms & conditions").font(.custom("Poppins-Regular", size: 16)).foregroundColor(Color.customDarkSage)
                Spacer()
            }
        }.padding(.top, 18)
    }

    private var footerSection: some View {
        VStack {
            Text("Or Continue with").font(.custom("Poppins-Regular", size: 16)).foregroundColor(.gray).padding(.top, 42)
            HStack(spacing: 22) {
                socialCircle(imageName: "google_logo")
                socialCircle(imageName: "facebook_logo")
            }.padding(.top, 26)
            HStack(spacing: 6) {
                Text("Already have Account?").foregroundColor(.gray)
                Button(action: onSignInTap) { Text("Sign In").foregroundColor(Color.customDarkSage) }
            }.font(.custom("Poppins-Regular", size: 16)).padding(.top, 36).padding(.bottom, 24)
        }
    }

    @ViewBuilder
    private func socialCircle(imageName: String) -> some View {
        Button(action: {}) { Image(imageName).resizable().scaledToFit().frame(width: 74, height: 74) }
    }
}
