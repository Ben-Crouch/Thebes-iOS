//
//  Colors.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

import SwiftUI

struct AppColors {
    static let primary = Color(red: 15/255, green: 15/255, blue: 15/255) // Darker Gray
    static let secondary = Color(red: 20/255, green: 184/255, blue: 166/255) // Teal
    static let complementary = Color(red: 100/255, green: 100/255, blue: 100/255) // Light Gray for input fields
    
    // Gradient colors adjusted for dark mode visibility
    static func gradientColors(for colorScheme: ColorScheme) -> [Color] {
        if colorScheme == .dark {
            // In dark mode, use slightly lighter grays that are visible against black background
            return [
                Color(red: 15/255, green: 15/255, blue: 17/255), // Slightly lighter dark gray
                Color(red: 10/255, green: 10/255, blue: 12/255), // Middle dark gray
                Color(red: 15/255, green: 15/255, blue: 17/255)  // Slightly lighter dark gray
            ]
        } else {
            // In light mode, use original black gradient
            return [
                Color.black,
                Color.black.opacity(0.8),
                Color.black
            ]
        }
    }
}
