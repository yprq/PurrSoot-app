import SwiftUI


enum Tab {
    case home, adopt, map, chat, profile
}

struct MainTabView: View {
    
    @State private var selectedTab: Tab = .home
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.customLightSage)

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        ZStack {
            VStack{
            
            // TAB VIEW
                TabView(selection: $selectedTab) {
                    
                    HomeView()
                        .tag(Tab.home)
                        .tabItem {
                            Image(selectedTab == .home ? "home" : "home-2")
                        }
                    
                        AdoptView()
                        .tag(Tab.adopt)
                        .tabItem {
                            Image(selectedTab == .adopt ? "favorite" : "pawprint_bos 1")
                        }
                    Spacer()
                    
                    ChatView()
                        .tag(Tab.chat)
                        .tabItem {
                            Image(selectedTab == .chat ? "chat_bubble-3" : "chat_bubble-2")
                        }
                    
                    ProfileView()
                        .tag(Tab.profile)
                        .tabItem {
                            Image(selectedTab == .profile ? "person-2" : "person")
                            
                        }
                   
                }
                
                
            }
            
            
         
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        selectedTab = .map
                    }) {
                        Image("map outline black1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 35, height: 35)
                        //boyutu değiştirebiliriz büyük olunca pixelli oluyor
                            .padding()
                            .background(Color.customMediumSage)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, y: 4)
                    }
                    
                    Spacer()
                }
                
            }
        }
    }
}

#Preview {
    MainTabView()
}
