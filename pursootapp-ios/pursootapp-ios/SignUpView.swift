//
//  SignUpView.swift
//  pursootapp-ios
//
//  Created by Seda Akdağ on 7.04.2026.
//

import SwiftUI

struct SignUpView: View {
    let onBackTap: () -> Void
    let onSignInTap: () -> Void

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var isAgreed = false

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

                    Text("Sign Up")
                        .font(.custom("Poppins-Regular", size: 20))

                    Spacer()

                    Color.clear
                        .frame(width: 54, height: 54)
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Text("Welcome")
                            .font(.custom("Poppins-Bold", size: 30))
                            .padding(.top, 30)

                        Text("Please enter your informations here")
                            .font(.custom("Poppins-Regular", size: 15))
                            .foregroundColor(.gray)

                        VStack(alignment: .leading, spacing: 18) {
                            Text("Full name")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.black)

                            AuthTextField(placeholder: "George", text: $fullName)

                            Text("Email")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.black)

                            AuthTextField(placeholder: "becomecolorful@gmail.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()

                            Text("Password")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(.black)

                            AuthSecureField(placeholder: "••••••", text: $password)

                            Button(action: {
                                isAgreed.toggle()
                            }) {
                                HStack(spacing: 12) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .stroke(Color.gray, lineWidth: 1.6)
                                            .frame(width: 24, height: 24)

                                        if isAgreed {
                                            Image(systemName: "checkmark")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color(red: 110/255, green: 132/255, blue: 106/255))
                                        }
                                    }

                                    Text("I agree with terms & conditions")
                                        .font(.custom("Poppins-Regular", size: 16))
                                        .foregroundColor(Color(red: 54/255, green: 71/255, blue: 89/255))

                                    Spacer()
                                }
                            }
                            .padding(.top, 18)
                        }
                        .padding(.horizontal, 36)
                        .padding(.top, 48)

                        Button(action: {}) {
                            Text("Sign Up")
                                .font(.custom("Poppins-SemiBold", size: 20))
                                .foregroundColor(Color(
                                    red: 102/255,
                                    green: 123/255,
                                    blue: 104/255
                                ))
                                .frame(width: 285, height: 72)
                                .overlay(
                                    Capsule()
                                        .stroke(Color(
                                            red: 102/255,
                                            green: 123/255,
                                            blue: 104/255
                                        ), lineWidth: 3)
                                )
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
                            Text("Already have Account?")
                                .font(.custom("Poppins-Regular", size: 16))
                                .foregroundColor(.gray)

                            Button(action: onSignInTap) {
                                Text("Sign In")
                                    .font(.custom("Poppins-Regular", size: 16))
                                    .foregroundColor(Color(
                                        red: 102/255,
                                        green: 123/255,
                                        blue: 104/255
                                    ))
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

struct AuthTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.gray.opacity(0.8))
                .font(.custom("Poppins-Regular", size: 18))
        )
        .font(.custom("Poppins-Regular", size: 18))
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 236/255, green: 236/255, blue: 236/255))
        )
    }
}

struct AuthSecureField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        SecureField(
            "",
            text: $text,
            prompt: Text(placeholder)
                .foregroundColor(Color.gray.opacity(0.8))
                .font(.custom("Poppins-Regular", size: 18))
        )
        .font(.custom("Poppins-Regular", size: 18))
        .foregroundColor(.black)
        .padding(.horizontal, 24)
        .frame(height: 74)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(red: 236/255, green: 236/255, blue: 236/255))
        )
    }
}

#Preview {
    SignUpView(onBackTap: {}, onSignInTap: {})
}
