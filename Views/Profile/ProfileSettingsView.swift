import SwiftUI
import AuthenticationServices

struct ProfileSettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var settingsViewModel = ProfileSettingsViewModel()
    @State private var weightUnit: WeightUnit = .kilograms
    @State private var isPrivateMode = false
    @State private var hideWorkoutHistory = false
    @State private var dailySummaryEnabled = true
    @State private var showResetConfirmation = false
    @State private var pendingResetEmail: String?
    @State private var resetAlertTitle: String = ""
    @State private var resetAlertMessage: String = ""
    @State private var showResetResult = false
    @State private var selectedTagline: UserTagline = .fitnessEnthusiast
    @State private var showDeleteAccountConfirmation = false
    @State private var showDeletePasswordPrompt = false
    @State private var deletePassword = ""
    @State private var showAppleReAuth = false
    @State private var isDeleting = false
    @State private var showPrivacyPolicy = false
    @State private var showTermsOfService = false
    
    var body: some View {
        ZStack {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    profileHeader
                    
                    if let errorMessage = settingsViewModel.errorMessage, !errorMessage.isEmpty {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                    }
                    
                    settingsSection(title: "Account") {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Display Name")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                TextField("Enter your name", text: Binding(
                                    get: { settingsViewModel.displayName },
                                    set: { newValue in
                                        settingsViewModel.displayName = newValue
                                    }
                                ))
                                .textFieldStyle(PlainTextFieldStyle())
                                .padding(12)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                                .foregroundColor(.white)
                                .onSubmit {
                                    if !settingsViewModel.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        settingsViewModel.saveDisplayName(for: authViewModel.user?.uid, newDisplayName: settingsViewModel.displayName)
                                    }
                                }
                                .onChange(of: settingsViewModel.displayName) { newValue in
                                    // Auto-save after user stops typing (debounce)
                                    let trimmed = newValue.trimmingCharacters(in: .whitespacesAndNewlines)
                                    if !trimmed.isEmpty {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            // Only save if the value hasn't changed in the meantime
                                            if settingsViewModel.displayName == newValue {
                                                settingsViewModel.saveDisplayName(for: authViewModel.user?.uid, newDisplayName: trimmed)
                                            }
                                        }
                                    }
                                }
                            }
                            divider
                            settingsRow(title: "Email", description: settingsViewModel.email) {
                                Button(action: {}) {
                                    Text("Manage")
                                        .font(.footnote)
                                        .fontWeight(.semibold)
                                        .foregroundColor(AppColors.secondary)
                                }
                            }
                            divider
                            Button(action: { handleChangePasswordTap() }) {
                                settingsRow(title: "Change Password", description: "Update your password securely.") {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    settingsSection(title: "Preferences") {
                        VStack(alignment: .leading, spacing: 16) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Weight Units")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Picker("Weight Unit", selection: $weightUnit) {
                                    ForEach(WeightUnit.allCases) { unit in
                                        Text(unit.displayName)
                                            .tag(unit)
                                    }
                                }
                                .pickerStyle(.segmented)
                                .colorMultiply(AppColors.secondary)
                            }
                            
                            divider
                            
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Profile Tagline")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.white)
                                Picker("Tagline", selection: $selectedTagline) {
                                    ForEach(UserTagline.allCases) { tagline in
                                        Text(tagline.displayText)
                                            .tag(tagline)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(AppColors.secondary)
                            }

                            divider
                            
                            Toggle(isOn: $dailySummaryEnabled) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Daily Summary")
                                        .foregroundColor(.white)
                                    Text("Show a condensed overview of your stats on the home screen.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.secondary))
                        }
                    }
                    
                    settingsSection(title: "Privacy & Sharing") {
                        VStack(alignment: .leading, spacing: 16) {
                            Toggle(isOn: $isPrivateMode) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Private Mode")
                                        .foregroundColor(.white)
                                    Text("Hide your activity from the social feed and leaderboards.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.secondary))
                            
                            divider
                            
                            Toggle(isOn: $hideWorkoutHistory) {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Hide Workout History")
                                        .foregroundColor(.white)
                                    Text("Keep your past sessions visible only to you.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            .toggleStyle(SwitchToggleStyle(tint: AppColors.secondary))
                        }
                    }
                    
                    settingsSection(title: "Legal") {
                        VStack(alignment: .leading, spacing: 16) {
                            Button(action: {
                                showPrivacyPolicy = true
                            }) {
                                settingsRow(title: "Privacy Policy", description: "How we collect and use your data") {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            divider
                            
                            Button(action: {
                                showTermsOfService = true
                            }) {
                                settingsRow(title: "Terms of Service", description: "Terms and conditions for using Thebes") {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(.white.opacity(0.4))
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    
                    settingsSection(title: "Notifications") {
                        VStack(alignment: .leading, spacing: 16) {
                            settingsRow(
                                title: "Push Notifications",
                                description: "Get alerts for challenges, friend activity, and reminders."
                            ) {
                                comingSoonTag()
                            }
                            
                            divider
                            
                            settingsRow(
                                title: "Email Updates",
                                description: "Receive digest emails with progress reports and tips."
                            ) {
                                comingSoonTag()
                            }
                        }
                    }
                    
                    settingsSection(title: "Connected Accounts") {
                        VStack(alignment: .leading, spacing: 14) {
                            connectedAccountRow(
                                service: "Apple",
                                status: settingsViewModel.isAppleConnected ? "Connected" : "Not Connected"
                            )
                            divider
                            connectedAccountRow(
                                service: "Google",
                                status: settingsViewModel.isGoogleConnected ? "Connected" : "Not Connected"
                            )
                        }
                    }
                    
                    settingsSection(title: "Account Actions") {
                        VStack(alignment: .leading, spacing: 16) {
                            settingsRow(title: "Sign Out", description: "") {
                                Button(action: handleSignOut) {
                                    HStack(spacing: 6) {
                                        Image(systemName: "arrow.right.circle")
                                            .foregroundColor(AppColors.secondary)
                                        Text("Sign Out")
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(AppColors.secondary)
                                    }
                                }
                            }
                            
                            divider
                            
                            settingsRow(title: "Delete Account", description: "Permanently delete your account and all data") {
                                Button(action: {
                                    showDeleteAccountConfirmation = true
                                }) {
                                    Text("Delete")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            settingsViewModel.loadProfile(
                for: authViewModel.user?.uid,
                fallbackDisplayName: authViewModel.user?.displayName,
                fallbackEmail: authViewModel.user?.email
            )
            weightUnit = settingsViewModel.preferredWeightUnit
        }
        .onChange(of: settingsViewModel.preferredWeightUnit) { newValue in
            weightUnit = newValue
        }
        .onChange(of: weightUnit) { newValue in
            if newValue != settingsViewModel.preferredWeightUnit {
                settingsViewModel.savePreferredWeightUnit(for: authViewModel.user?.uid, newUnit: newValue)
            }
        }
        .onChange(of: settingsViewModel.tagline) { newValue in
            selectedTagline = newValue
        }
        .onChange(of: selectedTagline) { newValue in
            if newValue != settingsViewModel.tagline {
                settingsViewModel.saveTagline(for: authViewModel.user?.uid, newTagline: newValue)
            }
        }
        .confirmationDialog(
            "Reset Password",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible,
            presenting: pendingResetEmail
        ) { email in
            Button("Email reset link", role: .none) {
                sendPasswordReset(to: email)
            }
            Button("Cancel", role: .cancel) {
                pendingResetEmail = nil
            }
        } message: { email in
            Text("We'll send a password reset email to \(email).")
        }
        .alert(resetAlertTitle, isPresented: $showResetResult) {
            Button("OK", role: .cancel) {
                resetAlertTitle = ""
                resetAlertMessage = ""
            }
        } message: {
            Text(resetAlertMessage)
        }
        .confirmationDialog(
            "Delete Account",
            isPresented: $showDeleteAccountConfirmation,
            titleVisibility: .visible
        ) {
            Button("Cancel", role: .cancel) { }
            Button("Delete My Account", role: .destructive) {
                if authViewModel.isAppleUser() {
                    showAppleReAuth = true
                } else {
                    showDeletePasswordPrompt = true
                }
            }
        } message: {
            Text("This action cannot be undone. All your data, including workouts, templates, and profile information, will be permanently deleted.")
        }
        .sheet(isPresented: $showDeletePasswordPrompt) {
            deleteAccountPasswordSheet
        }
        .sheet(isPresented: $showAppleReAuth) {
            appleReAuthSheet
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            if let url = URL(string: "https://thebes-dbc17.web.app/privacy-policy.html") {
                SafariView(url: url)
            }
        }
        .sheet(isPresented: $showTermsOfService) {
            if let url = URL(string: "https://thebes-dbc17.web.app/terms-of-service.html") {
                SafariView(url: url)
            }
        }
    }
    
    private var deleteAccountPasswordSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Confirm Deletion")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 20)
                
                Text("To delete your account, please enter your password to confirm.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.9))
                    
                    SecureField("Enter your password", text: $deletePassword)
                        .modifier(PlaceholderModifier(
                            showPlaceholder: deletePassword.isEmpty,
                            placeholder: "Enter your password",
                            color: .white.opacity(0.5)
                        ))
                        .padding(14)
                        .background(Color.white.opacity(0.08))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    isDeleting = true
                    authViewModel.deleteAccount(password: deletePassword) { result in
                        isDeleting = false
                        switch result {
                        case .success:
                            showDeletePasswordPrompt = false
                            // User will be signed out automatically
                        case .failure(let error):
                            resetAlertTitle = "Deletion Failed"
                            resetAlertMessage = authViewModel.getFriendlyErrorMessage(error)
                            showResetResult = true
                        }
                    }
                }) {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red.opacity(0.6))
                            .cornerRadius(12)
                    } else {
                        Text("Delete Account")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .disabled(isDeleting || deletePassword.isEmpty)
                
                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(uiColor: .black).opacity(0.85),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showDeletePasswordPrompt = false
                        deletePassword = ""
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private var appleReAuthSheet: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Confirm Deletion")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                Text("To delete your account, please sign in with Apple again to confirm.")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                
                SignInWithAppleButton(
                    onRequest: { request in
                        let nonce = authViewModel.startSignInWithAppleFlow()
                        request.requestedScopes = [.fullName, .email]
                        // Apple Sign-In expects hex-encoded SHA256, not base64
                        request.nonce = nonce.sha256Hex()
                    },
                    onCompletion: { result in
                        switch result {
                        case .success(let authorization):
                            isDeleting = true
                            authViewModel.deleteAppleAccount(authorization: authorization) { result in
                                isDeleting = false
                                switch result {
                                case .success:
                                    showAppleReAuth = false
                                    // User will be signed out automatically
                                case .failure(let error):
                                    resetAlertTitle = "Deletion Failed"
                                    resetAlertMessage = authViewModel.getFriendlyErrorMessage(error)
                                    showResetResult = true
                                    showAppleReAuth = false
                                }
                            }
                        case .failure(let error):
                            resetAlertTitle = "Authentication Failed"
                            resetAlertMessage = authViewModel.getFriendlyErrorMessage(error)
                            showResetResult = true
                        }
                    }
                )
                .signInWithAppleButtonStyle(.white)
                .frame(height: 50)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .disabled(isDeleting)
                .opacity(isDeleting ? 0.6 : 1.0)
                
                if isDeleting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding()
                }
                
                Spacer()
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.black,
                        Color(uiColor: .black).opacity(0.85),
                        Color.black
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        showAppleReAuth = false
                    }
                    .foregroundColor(.white)
                    .disabled(isDeleting)
                }
            }
        }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            if settingsViewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                    .scaleEffect(1.2)
                    .padding(.bottom, 4)
                Text("Loading profile...")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.6))
            } else {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 80, height: 80)
                    
                    if let imageUrl = settingsViewModel.profileImageUrl,
                       let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                                .scaledToFill()
                        } placeholder: {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.secondary))
                        }
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .stroke(AppColors.secondary.opacity(0.4), lineWidth: 2)
                        )
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Text(settingsViewModel.displayName.isEmpty ? "Athlete" : settingsViewModel.displayName)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                
                if !settingsViewModel.email.isEmpty {
                    Text(settingsViewModel.email)
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                )
        )
    }
    
    private func settingsSection<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title.uppercased())
                .font(.footnote)
                .fontWeight(.semibold)
                .kerning(1)
                .foregroundColor(.white.opacity(0.6))
                .padding(.leading, 4)
            
            VStack(alignment: .leading, spacing: 0) {
                content()
                    .padding(20)
            }
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                    )
            )
        }
    }
    
    private func settingsRow<Action: View>(title: String, description: String, @ViewBuilder trailing: () -> Action) -> some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: description.isEmpty ? 0 : 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                
                if !description.isEmpty {
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer(minLength: 16)
            trailing()
        }
    }
    
    private var divider: some View {
        Divider()
            .background(Color.white.opacity(0.1))
    }
    
    private func connectedAccountRow(service: String, status: String) -> some View {
        HStack {
            HStack(spacing: 12) {
                Image(systemName: service == "Apple" ? "apple.logo" : "globe")
                    .font(.title3)
                    .foregroundColor(AppColors.secondary)
                Text(service)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Text(status)
                .font(.caption)
                .foregroundColor(status == "Connected" ? AppColors.secondary : .white.opacity(0.6))
            
            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.4))
        }
    }
    
    private func comingSoonTag() -> some View {
        Text("Coming Soon")
            .font(.caption)
            .fontWeight(.semibold)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.secondary.opacity(0.15))
            .foregroundColor(AppColors.secondary)
            .clipShape(Capsule())
    }
    
    private func handleSignOut() {
        authViewModel.signOut()
    }
    
    private func handleChangePasswordTap() {
        guard !settingsViewModel.email.isEmpty else {
            resetAlertTitle = "Email Unavailable"
            resetAlertMessage = "We need a valid email address on file before we can send a reset link. Please update your account details first."
            showResetResult = true
            return
        }
        pendingResetEmail = settingsViewModel.email
        showResetConfirmation = true
    }
    
    private func sendPasswordReset(to email: String) {
        authViewModel.resetPassword(email: email) { result in
            DispatchQueue.main.async {
                pendingResetEmail = nil
                switch result {
                case .success:
                    resetAlertTitle = "Email Sent"
                    resetAlertMessage = "We've emailed a password reset link to \(email). Please check your inbox."
                case .failure(let error):
                    resetAlertTitle = "Reset Failed"
                    resetAlertMessage = authViewModel.getFriendlyErrorMessage(error)
                }
                showResetResult = true
            }
        }
    }
}

struct ProfileSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProfileSettingsView()
        }
        .environmentObject(AuthViewModel())
    }
}
