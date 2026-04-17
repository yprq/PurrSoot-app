//
//  RootView.swift
//  pursootapp-ios
//
//  Created by Seda Akdağ on 7.04.2026.
//

import SwiftUI

enum AuthScreen {
    case welcome
    case signIn
    case signUp
}

struct RootView: View {
    @State private var currentScreen: AuthScreen = .welcome

    var body: some View {
        Group {
            switch currentScreen {
            case .welcome:
                WelcomeView(
                    onSignInTap: { currentScreen = .signIn },
                    onSignUpTap: { currentScreen = .signUp }
                )
            case .signIn:
                SignInView(
                    onBackTap: { currentScreen = .welcome },
                    onSignUpTap: { currentScreen = .signUp }
                )
            case .signUp:
                SignUpView(
                    onBackTap: { currentScreen = .welcome },
                    onSignInTap: { currentScreen = .signIn }
                )
            }
        }
    }
}

#Preview {
    RootView()
}
