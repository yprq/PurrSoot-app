//
//  WelcomeView.swift
//  pursootapp-ios
//
//  Created by Seda Akdağ on 7.04.2026.
//

import SwiftUI

struct WelcomeView: View {
    let onSignInTap: () -> Void
    let onSignUpTap: () -> Void

    var body: some View {
        ZStack {
            Color.customDarkSage
                .ignoresSafeArea()

            VStack {
                HStack {
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                Spacer()

                ZStack {
                    Image("frame_cat")
                    
                    Image("cat")
                }
                .overlay(alignment: .center) {
                    Image("location_icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .offset(x: 120, y: -160)
                }
                .overlay(alignment: .center) {
                    Image("bench")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80)
                        .offset(x: -120, y: 140)
                }
                .overlay(alignment: .center) {
                    Image("clouds")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .offset(x: -10 ,y: -110)
                }
                .overlay(alignment: .center) {
                    Image("clouds_frame")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200)
                        .offset(x: -10 ,y: -112)
                }

                Spacer()

                VStack(spacing: 22) {
                    Button(action: onSignInTap) {
                        Text("Sign In")
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white, lineWidth: 3)
                            )
                    }

                    Text("Don’t have an account?")
                        .font(Font.custom("Poppins-Regular", size: 16))
                        .foregroundColor(.white.opacity(0.9))

                    Button(action: onSignUpTap) {
                        Text("Sign Up")
                            .font(Font.custom("Poppins-Regular", size: 20))
                            .foregroundColor(Color.customDarkSage)
                            .frame(maxWidth: .infinity)
                            .frame(height: 72)
                            .background(Color.white.opacity(0.95))
                            .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 42)
                .padding(.bottom, 42)
            }
        }
    }
}

#Preview {
    WelcomeView(onSignInTap: {}, onSignUpTap: {})
}
