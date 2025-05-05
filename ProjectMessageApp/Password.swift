//
//  Password.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 19/01/2025.
//
import SwiftUI
import FirebaseAuth

struct PasswordResetView: View {
    @State private var email = ""
    @State private var message = ""

    var body: some View {
        NavigationStack {
            ZStack {
                Color.init(hex: "#3632a8").ignoresSafeArea()
        
                VStack(spacing: 20) {
                    Image(systemName:"envelope.circle.fill")
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(.blue)
                    
                    Text("Reset Password")
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                    
                    TextField("", text: $email, prompt: Text("Enter Email").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                    
                    Button("Send Reset Link") {
                        resetPassword()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 50)
                    .background(Color.init(hex: "#041c54"))
                    .cornerRadius(8)
                    
                    if !message.isEmpty {
                        Text(message)
                            .padding()
                            .foregroundColor(message.contains("Error:") ? .red : .green)
                            
                    }
                    NavigationLink(destination: Login()) {
                        Text("Go back to login")
                            .foregroundColor(.white)
                            .padding(.top).underline()
                    }
                    Spacer()
                }
                .padding()
            }
        }
    }
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
            } else {
                message = "Password reset link sent to \(email)"
                
            }
        }
    }
}
#Preview {
    PasswordResetView()
}
