import SwiftUI

struct SignInView: View {
    let onBackTap: () -> Void
    let onSignUpTap: () -> Void
    let onSignInSuccess: () -> Void

    @State private var email = ""
    @State private var password = ""
    @StateObject var authManager = AuthManager()

    var body: some View {
        ZStack {
            Color(red: 246/255, green: 246/255, blue: 246/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: onBackTap) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.85))
                            .frame(width: 54, height: 54)
                            .overlay(Circle().stroke(Color.gray.opacity(0.35), lineWidth: 1.5))
                    }
                    Spacer()
                    Text("Sign In").font(.custom("Poppins-Regular", size: 20))
                    Spacer()
                    Color.clear.frame(width: 54, height: 54)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Text("Welcome back!")
                            .font(.custom("Poppins-Bold", size: 30))
                            .padding(.top, 30)

                        Image("signin_logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 110, height: 110)
                            .padding(.top, 26)

                        VStack(alignment: .leading, spacing: 18) {
                            Text("Email").font(.custom("Poppins-SemiBold", size: 20))
                            AuthTextField(placeholder: "becomecolorful@gmail.com", text: $email)
                                .textInputAutocapitalization(.never)

                            Text("Password").font(.custom("Poppins-SemiBold", size: 20))
                            AuthSecureField(placeholder: "••••••", text: $password)
                            
                            if let serverError = authManager.serverErrorMessage {
                                Text(serverError)
                                    .foregroundColor(.red)
                                    .font(.custom("Poppins-Regular", size: 14))
                                    .padding(.top, 8)
                                    .transition(.opacity) // Yumuşak bir geçiş için
                            }
                            
                            HStack {
                                Spacer()
                                Button("Forgot Password?") { }
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(Color.customDarkSage)
                                    .underline()
                            }.padding(.top, 10)
                        }
                        .padding(.horizontal, 36)
                        .padding(.top, 48)

                        // Sign In Butonu
                        Button(action: {
                            authManager.signIn(email: email, password: password) { success in
                                if success {
                                    onSignInSuccess()
                                }
                            }
                        }) {
                            Text("Sign In")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 285, height: 72)
                                .background(Color.customDarkSage)
                                .clipShape(Capsule())
                        }
                        .padding(.top, 48)

                        Text("Or Continue with")
                            .font(.custom("Poppins-Regular", size: 16))
                            .foregroundColor(.gray)
                            .padding(.top, 42)

                        HStack(spacing: 22) {
                            socialCircle(imageName: "google_logo")
                            socialCircle(imageName: "facebook_logo")
                        }
                        .padding(.top, 26)

                        HStack(spacing: 6) {
                            Text("Don’t have an account?").foregroundColor(.gray)
                            Button(action: onSignUpTap) {
                                Text("Sign Up").foregroundColor(Color.customDarkSage)
                            }
                        }
                        .font(.custom("Poppins-Regular", size: 16))
                        .padding(.top, 36)
                        .padding(.bottom, 24)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func socialCircle(imageName: String) -> some View {
        Button(action: {}) {
            Image(imageName).resizable().scaledToFit().frame(width: 74, height: 74)
        }
    }
}
