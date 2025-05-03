import SwiftUI
import FirebaseFirestore
import FirebaseAuth
struct Homepage: View {
    
    @EnvironmentObject var themeManager: ThemeManager
    @State private var users: [ChatUser] = []
    @State private var errorMessage: String?
    @State private var image: UIImage? = nil

    private let db = Firestore.firestore()
    private var currentUserEmail: String? {
        Auth.auth().currentUser?.email?.lowercased()
    }
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.blue.ignoresSafeArea(edges: .top)
                    VStack(spacing: 4) {
                        Text("Chat")
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                        Text("Manage all contacts")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                .frame(height: 80)
                VStack {

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    List {
                        ForEach(users) { user in
                            HStack {
                                ProfileImageView(imageUrl: user.profileImageUrl)
                                    .frame(width: 40, height: 40)
                                NavigationLink(destination: ChatMessagesView(otherUserEmail: user.email)) {
                                    Text(user.username)
                                        .foregroundStyle(Color.blue)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                Spacer()
                                    .swipeActions(edge: .trailing) {
                                        Button(role: .destructive) {
                                            deleteUser(userEmail: user.email)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                    }
                            }
                        }
                    }

                    NavigationLink(destination: AddNewUser()) {
                        Text("Add User")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(8)
                            .padding(.horizontal)
                    }
                }
                .onAppear {
                    fetchUsers()
                }
            }
            
        }
        
    }
    
    private func fetchUsers() {
        guard let currentUserEmail else { return }

        db.collection("users").document(currentUserEmail).collection("friends").addSnapshotListener { snapshot, error in
                if let error = error {
                    errorMessage = "Failed to fetch users: \(error.localizedDescription)"
                    return
                }

                guard let documents = snapshot?.documents, !documents.isEmpty else {
                    users = []
                    return
                }

                let friendEmails = documents.map { doc in doc.documentID }

                db.collection("users").whereField("email", in: friendEmails).getDocuments { snapshot, error in
                    if let error = error {
                        errorMessage = "Failed to fetch friend details: \(error.localizedDescription)"
                        return
                    }

                    users = snapshot?.documents.compactMap { doc in
                        ChatUser(document: doc.data(), id: doc.documentID)
                    } ?? []
                }
            }
    }
    
    private func deleteUser(userEmail: String) {
        guard let currentUserEmail else {return}

        deleteDocument(collection: "users/\(currentUserEmail)/friends", documentID: userEmail)
    }
     
    func deleteDocument(collection: String, documentID: String) {
        db.collection(collection).document(documentID).delete { error in
            if let error = error {
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                print("Document successfully deleted!")

                DispatchQueue.main.async {
                    self.users.removeAll { user in user.email == documentID }
                }
            }
        }
    }
}


#Preview{
    Homepage()
}
