import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SignupView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isSignedUp = false
    @State private var firstName = ""
    @State private var username = ""
    let db = Firestore.firestore()

    var body: some View {
        NavigationStack {
            ZStack {
               
                Color.init(hex: "#3632a8").ignoresSafeArea()

                VStack(spacing: 20) {
                   
                    Image("bluelogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                    
                    Text("Signup")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)

                    TextField("", text: $email, prompt: Text("Email").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    
                    SecureField("", text: $password, prompt: Text("Password").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    
                    TextField("" , text: $firstName,prompt: Text("Firstname").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    
                    TextField("", text: $username,prompt: Text("Username").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                        
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            
                    }

                    Button(action: signUpUser) {
                        Text("Sign Up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.init(hex: "#041c54"))
                            .cornerRadius(8)
                    }
                    
                    NavigationLink(destination: Login()) {
                        Text("Already have an account? Login")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
                .padding()
                .padding(.top, -80)
            }
        }
    }

    func signUpUser() {
        
        guard !email.isEmpty, !password.isEmpty, !firstName.isEmpty, !username.isEmpty else {
            errorMessage = "All fields are required."
            return
        }
        
        
       
        db.collection("users").whereField("username", isEqualTo: username.lowercased()).getDocuments { snapshot, error in
            if let error = error {
                errorMessage = "Error checking username: \(error.localizedDescription)"
                return
            }
            if let documents = snapshot?.documents, !documents.isEmpty {
                errorMessage = "Username is already taken."
                return
            }
            
            
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    errorMessage = "Error signing up: \(error.localizedDescription)"
                } else {
                    errorMessage = ""
                    saveUserDetails()
                    isSignedUp = true
                }
            }
            
        }
    }
    private func saveUserDetails() {
        let userEmail = email.lowercased()
        let userDetails: [String: Any] = [
            "email": userEmail,
            "firstName": firstName,
            "username": username.lowercased()
        ]

        db.collection("users").document(userEmail).setData(userDetails) { error in
            if let error = error {
                errorMessage = "Error saving details: \(error.localizedDescription)"
            } else {
                isSignedUp = true
                //print("User details saved")
            }
        }
    }

}

#Preview {
    SignupView()
}
