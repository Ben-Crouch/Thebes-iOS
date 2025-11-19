//
//  AuthViewModel.swift
//  Thebes
//
//  Created by Ben on 14/03/2025.
//

import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices
import CryptoKit

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isEmailVerified: Bool = false
    private var authStateListenerHandle: AuthStateDidChangeListenerHandle?
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""

    init() {
        self.user = Auth.auth().currentUser
        checkEmailVerification()
        handleAuthStateChange()
    }
    
    func handleAuthStateChange() {
        authStateListenerHandle = Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.user = user
            } else {
                self.user = nil
            }
        }
    }
    
    deinit {
        if let handle = authStateListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                // ✅ Send verification email
                user.sendEmailVerification { error in
                    if let error = error {
                        completion(.failure(error))
                        return
                    }

                    // ✅ Show toast for email verification
                    DispatchQueue.main.async {
                        self.toastMessage = "A verification email has been sent. Please check your inbox."
                        self.showToast = true

                        // ✅ Hide toast after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            self.showToast = false
                        }
                    }

                    // ✅ Save user profile in Firestore
                    UserService.shared.createUserProfile(user: user)

                    // ✅ Immediately remove user from state to prevent UI flashing
                    DispatchQueue.main.async {
                        self.user = nil
                        self.isEmailVerified = false
                    }

                    // ✅ Force sign-out after registration
                    do {
                        try Auth.auth().signOut()
                        print("✅ Successfully signed out after registration")
                    } catch {
                        print("❌ Error signing out after sign-up: \(error.localizedDescription)")
                    }

                    completion(.success(())) // ✅ Return success without logging in
                }
            }
        }
    }



    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("❌ Error signing in: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            if let user = result?.user {
                print("🔄 Attempting to reload user data...")
                
                // ✅ Force refresh user data before checking email verification
                user.reload { error in
                    if let error = error {
                        print("❌ Error reloading user: \(error.localizedDescription)")
                        completion(.failure(error))
                        return
                    }

                    print("📩 Email Verified Status AFTER reload: \(user.isEmailVerified)")

                    if user.isEmailVerified {
                        DispatchQueue.main.async {
                            self.user = user
                            self.isEmailVerified = true
                        }
                        print("✅ Login successful!")
                        completion(.success(user))
                    } else {
                        // ✅ Show toast if email is not verified
                        DispatchQueue.main.async {
                            self.toastMessage = "Please verify your email before logging in."
                            self.showToast = true

                            // ✅ Hide toast after 3 seconds
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                self.showToast = false
                            }
                        }
                        completion(.failure(NSError(domain: "Auth", code: -1, userInfo: [NSLocalizedDescriptionKey: "Email not verified."])))
                    }
                }
            }
        }
    }

    
    func checkEmailVerification() {
        Auth.auth().currentUser?.reload { error in
            if let user = Auth.auth().currentUser {
                DispatchQueue.main.async {
                    self.isEmailVerified = user.isEmailVerified
                }
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Result<Void, Error>) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    func getFriendlyErrorMessage(_ error: Error) -> String {
        let errorCode = (error as NSError).code
        switch errorCode {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect email or password. Please try again."
        case AuthErrorCode.invalidEmail.rawValue:
            return "Invalid email format. Please enter a valid email."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.networkError.rawValue:
            return "Network error. Please check your connection."
        case AuthErrorCode.userDisabled.rawValue:
            return "This account has been disabled. Contact support."
        default:
            return "Something went wrong. Please try again."
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            DispatchQueue.main.async {
                self.user = nil
            }
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Account Deletion
    
    /// Deletes the current user's account (for email/password users)
    func deleteAccount(password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser,
              let email = user.email else {
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        // Re-authenticate before deletion
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        user.reauthenticate(with: credential) { [weak self] result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Delete user data from Firestore first
            UserService.shared.deleteUserData(userId: user.uid) { success in
                if !success {
                    print("Warning: Failed to delete some user data from Firestore")
                }
                
                // Delete the Firebase Auth account
                user.delete { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        DispatchQueue.main.async {
                            self?.user = nil
                        }
                        completion(.success(()))
                    }
                }
            }
        }
    }
    
    /// Deletes account for Apple Sign In users (requires re-authentication with Apple)
    func deleteAppleAccount(authorization: ASAuthorization, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            print("❌ No user signed in for account deletion")
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user signed in"])))
            return
        }
        
        print("🗑️ Starting Apple account deletion for user: \(user.uid)")
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ Unable to get Apple ID credential")
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple credential"])))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("❌ Unable to get identity token from Apple credential")
            completion(.failure(NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        // Get the nonce if available (for re-authentication)
        // If no nonce is available, we'll generate one (though it won't match what was sent to Apple)
        // For re-authentication, Firebase might accept it, but if not, we'll need to ensure nonce is set
        let nonce = currentNonce ?? randomNonceString()
        if currentNonce == nil {
            print("⚠️ No nonce found in currentNonce, generated new one for re-authentication")
        }
        
        // Create Firebase credential from Apple authorization
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        print("✅ Created Firebase credential, re-authenticating user...")
        
        // Re-authenticate the user with Firebase (required before deletion)
        Task { [weak self] in
            do {
                // Re-authenticate to satisfy Firebase's "recent authentication" requirement
                _ = try await user.reauthenticate(with: credential)
                print("✅ User re-authenticated successfully")
                
                // Try to revoke Apple token (optional, but good practice)
                if let appleAuthCode = appleIDCredential.authorizationCode,
                   let authCodeString = String(data: appleAuthCode, encoding: .utf8) {
                    do {
                        try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                        print("✅ Apple token revoked successfully")
                    } catch {
                        print("⚠️ Warning: Failed to revoke Apple token: \(error.localizedDescription)")
                        print("   Continuing with account deletion anyway...")
                    }
                }
                
                // Delete user data from Firestore
                print("🗑️ Deleting user data from Firestore...")
                UserService.shared.deleteUserData(userId: user.uid) { success in
                    if !success {
                        print("⚠️ Warning: Failed to delete some user data from Firestore")
                    } else {
                        print("✅ User data deleted from Firestore")
                    }
                    
                    // Delete the Firebase Auth account (now that we're re-authenticated)
                    print("🗑️ Deleting Firebase Auth account...")
                    Task { @MainActor [weak self] in
                        do {
                            try await user.delete()
                            print("✅ Firebase Auth account deleted successfully")
                            self?.user = nil
                            completion(.success(()))
                        } catch {
                            print("❌ Error deleting Firebase Auth account: \(error.localizedDescription)")
                            completion(.failure(error))
                        }
                    }
                }
            } catch {
                print("❌ Error re-authenticating user: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    /// Checks if the current user signed in with Apple
    func isAppleUser() -> Bool {
        guard let user = Auth.auth().currentUser,
              let providerData = user.providerData.first else {
            return false
        }
        return providerData.providerID == "apple.com"
    }

    func signInWithGoogle(presenting: UIViewController, completion: @escaping (Result<User, Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing Firebase client ID"])))
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        
        GIDSignIn.sharedInstance.configuration = config
        GIDSignIn.sharedInstance.signIn(withPresenting: presenting) { result, error in
            if let error = error {
                print("❌ Google Sign-In error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }

            guard let user = result?.user, let idToken = user.idToken else {
                completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get Google ID token"])))
                return
            }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: user.accessToken.tokenString)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print("❌ Firebase auth error: \(error.localizedDescription)")
                    completion(.failure(error))
                } else if let user = result?.user {
                    DispatchQueue.main.async {
                        self.user = user
                        self.isEmailVerified = user.isEmailVerified
                        UserService.shared.createUserProfile(user: user)
                    }
                    completion(.success(user))
                }
            }
        }
    }
    
    // Sign in with Apple
    func signInWithApple(authorization: ASAuthorization, completion: @escaping (Result<User, Error>) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            print("❌ Failed to get Apple ID credential")
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])))
            return
        }
        
        guard let nonce = currentNonce else {
            print("❌ No nonce found - was startSignInWithAppleFlow() called?")
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }
        
        print("✅ Using stored raw nonce: \(nonce)")
        // Apple returns hex-encoded SHA256 in the token, so we compare with hex
        let expectedHash = nonce.sha256Hex()
        print("🔑 Expected hash (hex, what we sent to Apple): \(expectedHash)")
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("❌ Failed to get identity token")
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        print("✅ Got identity token from Apple")
        
        // Decode the ID token to check the nonce (for debugging)
        if let tokenParts = idTokenString.split(separator: ".").dropFirst().first,
           let tokenData = Data(base64Encoded: String(tokenParts), options: .ignoreUnknownCharacters),
           let tokenJSON = try? JSONSerialization.jsonObject(with: tokenData) as? [String: Any],
           let nonceInToken = tokenJSON["nonce"] as? String {
            print("🔑 Nonce from Apple's ID token (hex): \(nonceInToken)")
            print("🔑 Hash match: \(nonceInToken == expectedHash)")
        }
        
        // Use the Apple-specific credential method as per Firebase documentation
        // This includes the user's full name from the first sign-in
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: nonce,
            fullName: appleIDCredential.fullName
        )
        
        print("✅ Created Firebase credential with raw nonce")
        
        Auth.auth().signIn(with: credential) { [weak self] result, error in
            // Clear the nonce after Firebase processes it (success or failure)
            self?.currentNonce = nil
            
            if let error = error {
                let nsError = error as NSError
                print("❌ Apple Sign-In error: \(error.localizedDescription)")
                print("   Error domain: \(nsError.domain)")
                print("   Error code: \(nsError.code)")
                let userInfo = nsError.userInfo
                if !userInfo.isEmpty {
                    print("   Error userInfo: \(userInfo)")
                }
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                print("✅ Apple Sign-In successful! User ID: \(user.uid)")
                
                // Extract display name from Apple credential (only available on first sign-in)
                var displayName: String? = nil
                if let fullName = appleIDCredential.fullName {
                    var nameComponents: [String] = []
                    if let givenName = fullName.givenName {
                        nameComponents.append(givenName)
                    }
                    if let familyName = fullName.familyName {
                        nameComponents.append(familyName)
                    }
                    if !nameComponents.isEmpty {
                        displayName = nameComponents.joined(separator: " ")
                        print("📝 Extracted Apple display name: \(displayName!)")
                    }
                }
                
                DispatchQueue.main.async {
                    self?.user = user
                    self?.isEmailVerified = true // Apple accounts are always verified
                    UserService.shared.createUserProfile(user: user, displayName: displayName)
                }
                completion(.success(user))
            } else {
                print("❌ No user returned from Firebase")
                completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned from Firebase"])))
            }
        }
    }
    
    // Helper for Apple Sign In
    private var currentNonce: String?
    
    func startSignInWithAppleFlow() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
        print("🔑 Generated raw nonce (length: \(nonce.count))")
        let hashedNonce = nonce.sha256Hex() // Use hex encoding for Apple Sign-In
        print("🔑 Hashed nonce for Apple request (hex, length: \(hashedNonce.count))")
        return nonce
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    private func sha256Hex(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
    }
    
}

extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        // Return base64-encoded hash for Apple Sign-In request
        return Data(hashedData).base64EncodedString()
    }
    
    // Alternative: hex-encoded hash (for debugging)
    func sha256Hex() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

