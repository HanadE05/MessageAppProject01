import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct AddNewUser: View {
    @State private var searchUsername: String = ""
    @State private var foundUsername: ChatUser? = nil
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
        ZStack {
            Color.init(hex: "#3632a8").ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "person.crop.circle.fill.badge.plus")
                    .font(.system(size: 80))
                    .padding()
                    .foregroundColor(.white)

                Text("Search for a User")
                    .font(.largeTitle).bold()
                    .foregroundStyle(.white)

                TextField("", text: $searchUsername, prompt: Text("Enter username").foregroundColor(.gray))
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .foregroundColor(.black)

                Button("Search", action: searchForUser)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color.green)
                    .cornerRadius(8)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                if let user = foundUsername {
                    VStack(spacing: 10) {
                        Text("User Found: \(user.username)")
                            .font(.headline)
                            .foregroundColor(.green)

                        Button("Add Friend") {
                            addFriend(friend: user)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(8)
                    }
                    .padding()
                }

                Spacer()
            }
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
                foundUsername = ChatUser(document: document.data(), id: document.documentID)
                errorMessage = nil
            }
        }
    }
    
    func addFriend(friend: ChatUser) {
        guard let currentUserEmail = currentUserEmail else { return }

        let friendEntry: [String: Any] = [
            "email": friend.email
        ]

        db.collection("users").document(currentUserEmail).collection("friends").document(friend.email).setData(friendEntry) { error in
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
