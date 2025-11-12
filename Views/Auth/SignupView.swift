//
//  SignupView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @Environment(\.presentationMode) var presentationMode
    
    private var isPasswordValid: Bool {
        password.count >= 8 &&
        password.rangeOfCharacter(from: CharacterSet.uppercaseLetters) != nil &&
        password.rangeOfCharacter(from: CharacterSet.lowercaseLetters) != nil &&
        password.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil &&
        password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil
    }

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.8),
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // Logo and Title Section
                VStack(spacing: 16) {
                    Image("ThebesLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Join Thebes and start tracking your fitness journey")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Input Fields Card
                VStack(spacing: 14) {
                    // Email Input Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Email")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        TextField("", text: $email)
                            .modifier(PlaceholderModifier(
                                showPlaceholder: email.isEmpty,
                                placeholder: "Enter your email",
                                color: .white.opacity(0.5)
                            ))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                    }

                    // Password Input Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        SecureField("", text: $password)
                            .modifier(PlaceholderModifier(
                                showPlaceholder: password.isEmpty,
                                placeholder: "Create a password",
                                color: .white.opacity(0.5)
                            ))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                        
                        // Password Strength Indicator
                        PasswordStrengthIndicator(password: password)
                            .padding(.top, 4)
                    }

                    // Confirm Password Field
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Confirm Password")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        SecureField("", text: $confirmPassword)
                            .modifier(PlaceholderModifier(
                                showPlaceholder: confirmPassword.isEmpty,
                                placeholder: "Re-enter your password",
                                color: .white.opacity(0.5)
                            ))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }

                    // Error Message
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(AppColors.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // Sign-Up Button
                Button(action: {
                    // Validate password strength
                    guard isPasswordValid else {
                        errorMessage = "Password must meet all requirements."
                        return
                    }
                    
                    // Validate password match
                    guard password == confirmPassword else {
                        errorMessage = "Passwords do not match."
                        return
                    }
                    
                    // Proceed with sign up
                    authViewModel.signUp(email: email, password: password) { result in
                        switch result {
                        case .success:
                            errorMessage = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                dismiss()
                            }
                        case .failure(let error):
                            errorMessage = authViewModel.getFriendlyErrorMessage(error)
                        }
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.secondary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Social Sign-Up Buttons
                VStack(spacing: 12) {
                    // Google Sign-Up Button
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = scene.windows.first?.rootViewController {
                            authViewModel.signInWithGoogle(presenting: rootViewController) { result in
                                switch result {
                                case .success:
                                    print("Google Sign-Up successful")
                                case .failure(let error):
                                    errorMessage = authViewModel.getFriendlyErrorMessage(error)
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 12) {
                            Image("GoogleLogo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            
                            Text("Sign up with Google")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                    
                    // Apple Sign-Up Button
                    SignInWithAppleButton(
                        onRequest: { request in
                            let nonce = authViewModel.startSignInWithAppleFlow()
                            request.requestedScopes = [.fullName, .email]
                            request.nonce = nonce.sha256()
                        },
                        onCompletion: { result in
                            switch result {
                            case .success(let authorization):
                                authViewModel.signInWithApple(authorization: authorization) { result in
                                    switch result {
                                    case .success:
                                        print("Apple Sign-Up successful")
                                    case .failure(let error):
                                        errorMessage = authViewModel.getFriendlyErrorMessage(error)
                                    }
                                }
                            case .failure(let error):
                                errorMessage = authViewModel.getFriendlyErrorMessage(error)
                            }
                        }
                    )
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)

                // Navigation to Login
                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                    
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Sign In")
                            .foregroundColor(AppColors.secondary)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            
            ToastView(message: authViewModel.toastMessage, isShowing: $authViewModel.showToast)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.secondary)
                        .font(.title2)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
