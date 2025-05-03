import SwiftUI

struct MainTabView: View {
    var body: some View {
        NavigationStack {
            TabView {
                Homepage()
                    .tabItem {
                        Image(systemName: "house.fill")
                        Text("Home")
                    }

                ProfileView()
                    .tabItem {
                        Image(systemName: "person.circle")
                        Text("Profile")
                    }

                Settings()
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                        Text("Settings")
                    }
            }
        }
        
    }
}
