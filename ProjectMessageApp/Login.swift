import SwiftUI
import FirebaseAuth

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage = ""


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

                    Text("Login")
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
                        
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                    }
                    
                    Button("Login") {
                        logIn()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.init(hex: "#041c54"))
                    .cornerRadius(8)
                   
                    .navigationDestination(isPresented: $isLoggedIn) {
                        MainTabView()
                    }
                    
                    NavigationLink(destination: SignupView()) {
                        Text("Don't have an account? Signup")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                    
                    NavigationLink(destination: PasswordResetView()) {
                        Text("Forgot Password?")
                            .foregroundColor(.white)
                            .padding(.top)
                    }
                }
                .padding()
                .padding(.top, -80)
                
            }
        }
    }
     
    func logIn() {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                errorMessage = "Error logging in: \(error.localizedDescription)"
            } else {
                isLoggedIn = true
                
                //print("User has logged in Successfully")
            }
        }
    }
}
#Preview {
    Login()
}

