//
//  ConversionUtils.swift
//  Thebes
//
//  Created by Ben on 26/02/2025.
//

import Foundation

func convertWeight(value: Double, fromUnit: String, toUnit: String) -> Double {
    if fromUnit == toUnit { return value }
    if fromUnit == "kg" {
        return value * 2.20462 // kg to lbs
    } else {
        return value / 2.20462 // lbs to kg
    }
}
