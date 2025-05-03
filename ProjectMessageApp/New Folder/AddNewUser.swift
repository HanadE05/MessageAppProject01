import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddNewUser: View {
    @State private var searchUsername: String = ""
    @State private var foundUser: [String: Any]? = nil
    @State private var errorMessage: String? = nil
    @Environment(\.dismiss) private var dismiss
    
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }
    
    private var currentUsername: String? {
        Auth.auth().currentUser?.displayName?.lowercased()
    }
    
    let db = Firestore.firestore()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Search for a User")
                .font(.largeTitle)
                .padding(.top)
            
            TextField("Enter Username", text: $searchUsername)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
            
            Button(action: searchForUser) {
                Text("Search")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.top, 5)
            }
            
            if let user = foundUser {
                VStack(spacing: 10) {
                    Text("User Found: \(user["username"] as? String ?? "Unknown")")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Button(action: {
                        if let user = foundUser {
                            addFriend(friendData: user)
                            dismiss()
                        }
                    }) {
                        Text("Add Friend")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                }
                .padding()
            }
        }
        Spacer()
            .padding()
    }
    
    /// **Search for a User by Username**
    func searchForUser() {
        guard searchUsername.lowercased() != currentUsername else {
            errorMessage = "You cannot search for yourself."
            return
        }
        
        db.collection("users")
            .whereField("username", isEqualTo: searchUsername.lowercased()) // Ensure Firestore field name is correct
            .getDocuments { snapshot, error in
                if let error = error {
                    errorMessage = "Error searching for user: \(error.localizedDescription)"
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    errorMessage = "No user found with this username."
                    return
                }
                
                DispatchQueue.main.async {
                    foundUser = document.data()
                    errorMessage = nil
                }
            }
    }
    
    func addFriend(friendData: [String: Any]) {
        guard let currentUserEmail = currentUserEmail else {
            errorMessage = "Current user email not available."
            return
        }
        
        guard let friendEmail = friendData["email"] as? String, !friendEmail.isEmpty else {
            errorMessage = "Friend email is missing or invalid."
            return
        }

        // Save only the friend's email
        let friendEntry: [String: Any] = ["email": friendEmail]

        db.collection("users").document(currentUserEmail).collection("friends").document(friendEmail).setData(friendEntry) { error in
            if let error = error {
                errorMessage = "Error adding friend: \(error.localizedDescription)"
            } else {
                errorMessage = "Friend added successfully!"
            }
        }
    }
}

#Preview() {
    AddNewUser()
}
