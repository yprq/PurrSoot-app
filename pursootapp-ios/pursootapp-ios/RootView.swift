import SwiftUI

enum AuthScreen {
    case welcome
    case signIn
    case signUp
}

enum AppScreen {
    case auth
    case home
}

struct RootView: View {
    @State private var currentScreen: AuthScreen = .welcome
    @State private var appScreen: AppScreen = .auth

    var body: some View {
        Group {
            switch appScreen {
            case .auth:
                switch currentScreen {
                case .welcome:
                    WelcomeView(
                        onSignInTap: { currentScreen = .signIn },
                        onSignUpTap: { currentScreen = .signUp }
                    )

                case .signIn:
                    SignInView(
                        onBackTap: { currentScreen = .welcome },
                        onSignUpTap: { currentScreen = .signUp },
                        onSignInSuccess: {
                            appScreen = .home
                        }
                    )

                case .signUp:
                    SignUpView(
                        onBackTap: { currentScreen = .welcome },
                        onSignInTap: { currentScreen = .signIn }
                    )
                }

            case .home:
                MainTabView()
            }
        }
    }
}

#Preview {
    RootView()
}
