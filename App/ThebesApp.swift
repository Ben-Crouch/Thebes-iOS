//
//  ThebesApp.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct ThebesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authViewModel = AuthViewModel() // ✅ Global AuthViewModel

    var body: some Scene {
        WindowGroup {
            
            ZStack {
                // Status bar style controller
                StatusBarStyleView(style: .lightContent)
                    .frame(width: 0, height: 0)
                    .allowsHitTesting(false)
                
                NavigationView {
                    if authViewModel.user != nil && authViewModel.isEmailVerified {
                        MainTabView() // ✅ Show MainTabView only if the email is verified
                    } else {
                        LoginView() // ✅ Redirect unverified or logged-out users to LoginView
                    }
                }
                .environmentObject(authViewModel) // ✅ Pass the authViewModel to all views
                .toolbarBackground(.clear, for: .navigationBar)
                .toolbarColorScheme(.dark, for: .navigationBar)
                .background(Color.clear) // Ensure NavigationView background is clear
                .preferredColorScheme(.light) // Force light mode to ensure gradients display correctly
            }
        }
    }
}
