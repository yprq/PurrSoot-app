import SwiftUI

struct SignInView: View {
    let onBackTap: () -> Void
    let onSignUpTap: () -> Void

    @State private var email = ""
    @State private var password = ""

    private let primaryGreen = Color(
        red: 102/255,
        green: 123/255,
        blue: 104/255
    )

    var body: some View {
        ZStack {
            Color(red: 246/255, green: 246/255, blue: 246/255)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Button(action: onBackTap) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.black.opacity(0.85))
                            .frame(width: 54, height: 54)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray.opacity(0.35), lineWidth: 1.5)
                            )
                    }

                    Spacer()

                    Text("Sign In")
                        .font(.custom("Poppins-Regular", size: 20))

                    Spacer()

                    Color.clear
                        .frame(width: 54, height: 54)
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
                            Text("Email")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.black)

                            AuthTextField(
                                placeholder: "becomecolorful@gmail.com",
                                text: $email
                            )
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()

                            Text("Password")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.black)

                            AuthSecureField(
                                placeholder: "••••••",
                                text: $password
                            )

                            HStack {
                                Spacer()

                                Button("Forgot Password?") { }
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(primaryGreen)
                                    .underline()
                            }
                            .padding(.top, 10)
                        }
                        .padding(.horizontal, 36)
                        .padding(.top, 48)

                        Button(action: {}) {
                            Text("Sign In")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.white)
                                .frame(width: 285, height: 72)
                                .background(primaryGreen)
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
                            Text("Don’t have an account?")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.gray)

                            Button(action: onSignUpTap) {
                                Text("Sign Up")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(primaryGreen)
                            }
                        }
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
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 74, height: 74)
        }
    }
}

#Preview {
    SignInView(onBackTap: {}, onSignUpTap: {})
}
