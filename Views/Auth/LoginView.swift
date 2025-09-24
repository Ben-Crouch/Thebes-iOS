//
//  LoginView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var showToast = false
    @State private var toastMessage = ""

    var body: some View {
        ZStack {
            // ✅ Background color
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image("ThebesLogo") // Make sure the asset name matches
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                // ✅ Title
                Text("Login")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                // ✅ Email Input Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                    
                    TextField("", text: $email)
                        .modifier(PlaceholderModifier(
                            showPlaceholder: email.isEmpty,
                            placeholder: "Enter Email",
                            color: .white.opacity(0.8)
                        ))
                        .padding()
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                // ✅ Password Input Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)
                    
                    SecureField("", text: $password)
                        .modifier(PlaceholderModifier(
                            showPlaceholder: password.isEmpty,
                            placeholder: "Enter Password",
                            color: .white.opacity(0.8)
                        ))
                        .padding()
                        .background(AppColors.complementary.opacity(0.2))
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
                .padding(.horizontal)

                // ✅ Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(AppColors.secondary)
                        .padding()
                    
                    // ✅ Show "Forgot Password?" button when an error occurs
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
                            .font(.subheadline)
                            .foregroundColor(AppColors.secondary)
                            .underline()
                    }
                    .padding(.top, 5)
                }

                // ✅ Sign-In Button
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
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.secondary)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                
                // ✅ Google Sign-In Button
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
                    HStack {
                        Image("GoogleLogo") // ✅ Ensure this asset exists in Xcode
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                        
                        Text("Sign in with Google")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.complementary.opacity(0.3))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                // ✅ Navigation to Signup
                NavigationLink("Create an Account", destination: SignupView())
                    .foregroundColor(AppColors.secondary)
                    .padding()

            }
            .padding()
            
            ToastView(message: authViewModel.toastMessage, isShowing: $authViewModel.showToast)
        }
    }
}
