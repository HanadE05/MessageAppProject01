//
//  Models.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 07/02/2025.
//

import Foundation
import Foundation
import FirebaseFirestore
import SwiftUI
import PhotosUI


struct User: Identifiable {
    let id: String
    let email: String
    let firstName: String
    let username: String
    let profileImageUrl: String?

    init(document: [String: Any], id: String) {
        self.id = id
        self.email = document["email"] as? String ?? ""
        self.firstName = document["firstName"] as? String ?? ""
        self.username = document["username"] as? String ?? ""
        self.profileImageUrl = document["profileImageUrl"] as? String
    }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let senderEmail: String
    let receiverEmail: String
    let imageUrl: String?
    let timestamp: Timestamp

    init(document: [String: Any], id: String) {
        self.id = id
        self.text = document["text"] as? String ?? ""
        self.senderEmail = document["senderEmail"] as? String ?? ""
        self.receiverEmail = document["receiverEmail"] as? String ?? ""
        self.imageUrl = document["imageUrl"] as? String
        self.timestamp = document["timestamp"] as? Timestamp ?? Timestamp()
    }
}

