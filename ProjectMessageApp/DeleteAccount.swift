//
//  DeleteAccount.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 01/05/2025.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct DeleteAccount: View {
    let db = Firestore.firestore()
    @State private var password = ""
    @State private var isDeleted = false
    @State private var errorMessage = ""
    var body: some View {
        NavigationStack {
            ZStack {
                Color.init(hex: "#3632a8").ignoresSafeArea()
                VStack(spacing: 20) {
                    Image(systemName: "trash")
                        .font(.system(size: 40))
                        .padding()
                        .background(Color.white)
                        .clipShape(Circle())
                        .foregroundColor(.red)
                    Text("Delete Account")
                        .font(.largeTitle)
                        .bold().foregroundStyle(Color.white)
                    
                    SecureField("", text: $password, prompt: Text("Enter password").foregroundColor(.gray))
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .foregroundColor(.black)
                    
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                        
                    }
                    
                    Button(action: deleteAccount) {
                        Text("Permanaently delete")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .navigationDestination(isPresented: $isDeleted) {
                        SignupView()
                    }
                    Spacer()
                }
                .padding()
                .padding()
                
                
            }
        }
            
    }
    private func deleteAccount() {
        guard let currentUser = Auth.auth().currentUser,
              let email = currentUser.email?.lowercased() else { return }

        let credential = EmailAuthProvider.credential(withEmail: email, password: password)

        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                errorMessage = "Invalid password"
                return
            }
            
            

            db.collection("users").document(email).collection("friends").getDocuments { (querySnapshot, error) in
                    if let error = error {
                        print("Error getting documents: \(error.localizedDescription)")
                    } else {
                        for document in querySnapshot!.documents {
                            document.reference.delete()
                        }
                    }
                }

            // Step 1: Delete Firestore document
            db.collection("users").document(email).delete { error in
                if let error = error {
                    print("Error deleting user data: \(error.localizedDescription)")
                    return
                } else {
                    //print("User document \(email) deleted from Firestore.")

                   
                    currentUser.delete { error in
                        if let error = error {
                            print("Error deleting account: \(error.localizedDescription)")
                        } else {
                            print("account deleted.")
                            isDeleted = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    DeleteAccount()
}
