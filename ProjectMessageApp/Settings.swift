import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct Settings: View {
    @AppStorage("selectedColorScheme") private var selectedColorScheme: String = ""
    @State private var showSignup = false
    @State private var isDeleted = false
    let db = Firestore.firestore()
    
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.init(hex: "#3632a8").ignoresSafeArea(edges: .top)
                    VStack(spacing: 4) {
                        Text("Settings")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Manage your account settings")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .frame(height: 80)
                
                NavigationStack {
                    VStack(spacing: 20) {
                        Picker("Appearance", selection: $selectedColorScheme) {
                            Text("Light Mode").tag("light")
                            Text("Dark Mode").tag("dark")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding()
                        
                        NavigationLink(destination: AppIcon()) {
                            HStack {
                                Text("Change App Icon")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            
                        }
                        
                        NavigationLink(destination: ChatBackground()) {
                            HStack {
                                Text("Change Wallpaper")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        NavigationLink(destination: GuidelinesView()) {
                            HStack {
                                Text("Chat Space guidelines")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                        
                        Button(action: logOut) {
                            Text("Logout")
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        NavigationLink(destination: DeleteAccount()) {
                            HStack {
                                Text("Delete Account")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        Spacer()
                    }
                    
                    .padding()
                    .navigationTitle("Settings")
                    
                    .navigationDestination(isPresented: $showSignup) {
                        SignupView()
                    }
                }
            }
        }
        
    }
    private func logOut() {
        do {
            try Auth.auth().signOut()
            showSignup = true
        } catch {
            print("Error logging out: \(error.localizedDescription)")
        }
    }
}
#Preview{
   Settings()
}
