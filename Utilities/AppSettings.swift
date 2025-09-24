//
//  AppSettings.swift
//  Thebes
//
//  Created by Ben on 26/02/2025.
//

import Foundation

class AppSettings: ObservableObject {
    @Published var preferredUnit: String = "kg" // Default unit
    static let shared = AppSettings()
}
