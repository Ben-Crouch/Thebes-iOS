//
//  WeightUnit.swift
//  Thebes
//
//  Created by Ben on 12/11/2025.
//

import Foundation

enum WeightUnit: String, CaseIterable, Identifiable {
    case kilograms = "kg"
    case pounds = "lbs"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .kilograms:
            return "KG"
        case .pounds:
            return "LBS"
        }
    }
    
    var symbol: String {
        switch self {
        case .kilograms:
            return "kg"
        case .pounds:
            return "lbs"
        }
    }
    
    init(fromPreferredUnit unit: String?) {
        let normalized = unit?.lowercased() ?? "kg"
        switch normalized {
        case "lbs", "pounds":
            self = .pounds
        default:
            self = .kilograms
        }
    }
}

extension WeightUnit {
    var preferredUnitString: String {
        rawValue
    }
    
    func convertFromKilograms(_ kilograms: Double) -> Double {
        switch self {
        case .kilograms:
            return kilograms
        case .pounds:
            return kilograms * 2.2046226218
        }
    }
    
    func convertToKilograms(_ value: Double) -> Double {
        switch self {
        case .kilograms:
            return value
        case .pounds:
            return value / 2.2046226218
        }
    }
    
    func formattedWeight(fromKilograms kilograms: Double?, decimals: Int = 1) -> String {
        guard let kilograms = kilograms else {
            return "Bodyweight"
        }
        let converted = convertFromKilograms(kilograms)
        let format = "%0." + String(decimals) + "f"
        return String(format: format, converted)
    }
}
