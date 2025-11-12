//
//  AppSettings.swift
//  Thebes
//
//  Created by Ben on 26/02/2025.
//

import Foundation

class AppSettings: ObservableObject {
    static let shared = AppSettings()
    
    @Published var preferredWeightUnit: WeightUnit = .kilograms
    
    private init() {}
    
    var preferredUnitSymbol: String {
        preferredWeightUnit.symbol
    }
    
    var preferredUnitString: String {
        preferredWeightUnit.preferredUnitString
    }
    
    func updatePreferredUnit(_ unit: WeightUnit) {
        preferredWeightUnit = unit
    }
}
