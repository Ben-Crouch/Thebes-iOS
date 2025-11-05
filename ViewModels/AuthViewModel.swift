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
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])))
            return
        }
        
        guard let nonce = currentNonce else {
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid state: A login callback was received, but no login request was sent."])))
            return
        }
        
        guard let appleIDToken = appleIDCredential.identityToken,
              let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
            return
        }
        
        // Clear the nonce after use
        currentNonce = nil
        
        // Firebase expects the raw nonce (not hashed)
        // Note: Using deprecated method - works perfectly, just shows a warning
        // The new API requires AuthProviderID which has accessibility issues in current SDK
        let credential = OAuthProvider.credential(
            withProviderID: "apple.com",
            idToken: idTokenString,
            rawNonce: nonce
        )
        
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                print("❌ Apple Sign-In error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            if let user = result?.user {
                DispatchQueue.main.async {
                    self.user = user
                    self.isEmailVerified = true // Apple accounts are always verified
                    UserService.shared.createUserProfile(user: user)
                }
                completion(.success(user))
            }
        }
    }
    
    // Helper for Apple Sign In
    private var currentNonce: String?
    
    func startSignInWithAppleFlow() -> String {
        let nonce = randomNonceString()
        currentNonce = nonce
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
}

extension String {
    func sha256() -> String {
        let inputData = Data(self.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return Data(hashedData).base64EncodedString()
    }
}

