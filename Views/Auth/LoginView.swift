//
//  LoginView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showToast = false
    @State private var toastMessage = ""

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
            
            VStack(spacing: 24) {
                // Logo and Title Section
                VStack(spacing: 16) {
                    Image("ThebesLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                    
                    Text("Welcome Back")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Sign in to continue your fitness journey")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                // Input Fields Card
                VStack(spacing: 16) {
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
                                placeholder: "Enter your password",
                                color: .white.opacity(0.5)
                            ))
                            .padding(14)
                            .background(Color.white.opacity(0.08))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                    }

                    // Error Message and Forgot Password
                    if let errorMessage = errorMessage {
                        VStack(spacing: 8) {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(AppColors.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                authViewModel.resetPassword(email: email) { result in
                                    switch result {
                                    case .success:
                                        toastMessage = "Password reset email sent!"
                                        showToast = true
                                    case .failure:
                                        toastMessage = "Failed to send reset email. Check the email address."
                                        showToast = true
                                    }
                                }
                            }) {
                                Text("Forgot Password?")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondary)
                                    .underline()
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.05))
                .cornerRadius(20)
                .padding(.horizontal, 20)

                // Sign-In Button
                Button(action: {
                    authViewModel.signIn(email: email, password: password) { result in
                        switch result {
                        case .success:
                            print("Successfully signed in")
                        case .failure(let error):
                            errorMessage = authViewModel.getFriendlyErrorMessage(error)
                        }
                    }
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(AppColors.secondary)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                
                // Social Sign-In Buttons
                VStack(spacing: 12) {
                    // Google Sign-In Button
                    Button(action: {
                        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let rootViewController = scene.windows.first?.rootViewController {
                            authViewModel.signInWithGoogle(presenting: rootViewController) { result in
                                switch result {
                                case .success:
                                    print("Google Sign-In successful")
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
                            
                            Text("Sign in with Google")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                    }
                    
                    // Apple Sign-In Button
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
                                        print("Apple Sign-In successful")
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

                // Navigation to Signup
                HStack(spacing: 4) {
                    Text("Don't have an account?")
                        .foregroundColor(.white.opacity(0.7))
                        .font(.caption)
                    
                    NavigationLink("Sign Up", destination: SignupView())
                        .foregroundColor(AppColors.secondary)
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.top, 4)
                .padding(.bottom, 20)
            }
            
            ToastView(message: authViewModel.toastMessage, isShowing: $authViewModel.showToast)
        }
    }
}
