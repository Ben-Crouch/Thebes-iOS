//
//  AuthService.swift
//  Thebes
//
//  Created by Ben on 17/03/2025.
//

import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle? // ✅ Store listener
    
    func handleAuthStateChange() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                UserService.shared.createUserProfile(user: user) // ✅ Ensure user is stored in Firestore
            }
        }
    }
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
    
