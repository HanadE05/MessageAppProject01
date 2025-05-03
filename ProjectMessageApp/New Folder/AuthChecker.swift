//
//  AuthChecker.swift
//  ProjectMessageApp
//
//  Created by Ibrahim Eid on 07/12/2024.
//


import SwiftUI
import FirebaseAuth

struct AuthChecker: View {
    @State private var isAuthenticated = false

    var body: some View {
        Group {
            if isAuthenticated {
                MainTabView()
            } else {
                Login()
            }
        }
        .onAppear(perform: checkAuthStatus)
    }

    private func checkAuthStatus() {
        isAuthenticated = Auth.auth().currentUser != nil

        Auth.auth().addStateDidChangeListener { auth, user in
            isAuthenticated = user != nil
        }
    }
}
