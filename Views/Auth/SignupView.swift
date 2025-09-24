//
//  SignupView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//
import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct SignupView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)

            VStack(spacing: 20) {
                // ✅ Thebes Logo
                Image("ThebesLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)

                // ✅ Title
                Text("Sign Up")
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

                // ✅ Confirm Password Field
                VStack(alignment: .leading, spacing: 5) {
                    Text("Confirm Password")
                        .font(.headline)
                        .foregroundColor(AppColors.secondary)

                    SecureField("", text: $confirmPassword)
                        .modifier(PlaceholderModifier(
                            showPlaceholder: confirmPassword.isEmpty,
                            placeholder: "Re-enter Password",
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
                        .foregroundColor(.red)
                        .padding()
                }

                // ✅ Sign-Up Button
                Button(action: {
                    if password == confirmPassword {
                        authViewModel.signUp(email: email, password: password) { result in
                            switch result {
                            case .success:
                                errorMessage = nil
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    dismiss() // ✅ Dismiss SignupView and return to LoginView
                                }
                            case .failure(let error):
                                errorMessage = authViewModel.getFriendlyErrorMessage(error)
                            }
                        }
                    } else {
                        errorMessage = "Passwords do not match."
                    }
                }) {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.secondary)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                // ✅ Google Sign-Up Button
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
                    HStack {
                        Image("GoogleLogo") // ✅ Ensure this asset exists in Xcode
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text("Sign up with Google")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.complementary.opacity(0.3))
                    .cornerRadius(8)
                }
                .padding(.horizontal)

                // ✅ Navigation to Login
                Button(action: {
                    dismiss()
                }) {
                    Text("Already have an account? Log in")
                        .foregroundColor(AppColors.secondary)
                        .underline()
                }
            }
            .padding()
            // ✅ Toast Notification
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
        .navigationBarBackButtonHidden(true) // ✅ Hides default back button
    }
}
