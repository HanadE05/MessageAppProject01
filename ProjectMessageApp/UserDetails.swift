import SwiftUI
import FirebaseFirestore

struct UserDetails: View {
    var email="" 
    @State private var firstName = ""
    @State private var surname = ""
    @State private var username = ""
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var navigateToHomepage = false
    
    private let db = Firestore.firestore()

    var body: some View {
        NavigationView {
            ZStack{
                Color.blue.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .foregroundColor(.white)
                        .padding()
                    
                    Text("Enter Your Details")
                        .font(.largeTitle)
                        .bold()
                    
                    TextField("" , text: $firstName,prompt: Text("Firstname").foregroundColor(.gray))
                        .padding()
                        .foregroundStyle(Color.init(hex: "#050c57"))
                        .background(Color.white)
                        .cornerRadius(8)
                       
                    
                    TextField("", text: $surname,prompt: Text("Surname").foregroundColor(.gray))
                        .padding()
                        .foregroundStyle(Color.init(hex: "#050c57"))
                        .background(Color.white) // Set background to white
                        .cornerRadius(8)
                        
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                    
                    Button("Save Details") {
                        saveUserDetails()
                    }
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.init(hex: "#041c54"))
                    .cornerRadius(8)
                    
                    .navigationDestination(isPresented: $navigateToHomepage) {
                        MainTabView()
                    }

                }
                .padding()
                .padding(.top, -80)
                
            }
        }
    }
   
    private func saveUserDetails() {
        guard !firstName.isEmpty, !surname.isEmpty else {
            errorMessage = "All fields are required."
            showAlert = true
            return
        }

        let userDetails: [String: Any] = [
            "email": email.lowercased(),
            "firstName": firstName,
            "surname": surname
        ]

        db.collection("users").document(email.lowercased()).setData(userDetails) { error in
            if let error = error {
                errorMessage = "Error saving details: \(error.localizedDescription)"
                showAlert = true
            } else {
                errorMessage = ""
                navigateToHomepage = true
                print("Your are details saved to database")
            }
        }
    }
}
#Preview {
    UserDetails()
}

