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
        ZStack{
            Color.init(hex: "#3632a8").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName:"person.crop.circle.fill.badge.plus")
                    .font(.system(size: 80))
                    .padding()
                    .clipShape(Circle())
                    .foregroundColor(.white)
                
                Text("Search for a User") .font(.largeTitle).bold().foregroundStyle(Color.white)
                
                TextField("",text: $searchUsername,prompt: Text("Enter username").foregroundColor(.gray))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                
                Button(action: searchForUser) {
                    Text("Search")
                        .padding()
                        .frame(maxWidth: .infinity)
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
                Spacer()
            }
            .padding()
                .padding()
        }
       
    }
    
    func searchForUser() {
        guard searchUsername.lowercased() != currentUsername else {
            errorMessage = "You cannot search for yourself."
            return
        }
        
        db.collection("users").whereField("username", isEqualTo: searchUsername.lowercased()).getDocuments { snapshot, error in
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
        guard let currentUserEmail = currentUserEmail else {return}
        guard let friendEmail = friendData["email"] as? String, !friendEmail.isEmpty else {
            errorMessage = "Friend email is missing or invalid."
            return
        }
        let friendEntry: [String: Any] =
        ["email": friendEmail]

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
