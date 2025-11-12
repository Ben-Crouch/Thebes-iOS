//
//  UserTagline.swift
//  Thebes
//
//  Created by Ben on 12/11/2025.
//

import Foundation

enum UserTagline: String, CaseIterable, Identifiable {
    case fitnessEnthusiast = "fitness_enthusiast"
    case strengthSeeker = "strength_seeker"
    case trailblazer = "trailblazer_in_training"
    case mindMuscleExplorer = "mind_muscle_explorer"
    case wellnessWarrior = "wellness_warrior"
    
    var id: String { rawValue }
    
    var displayText: String {
        switch self {
        case .fitnessEnthusiast:
            return "Fitness Enthusiast"
        case .strengthSeeker:
            return "Strength Seeker"
        case .trailblazer:
            return "Trailblazer in Training"
        case .mindMuscleExplorer:
            return "Mind & Muscle Explorer"
        case .wellnessWarrior:
            return "Wellness Warrior"
        }
    }
}

extension UserTagline {
    static func from(rawValue: String?) -> UserTagline {
        guard let rawValue = rawValue,
              let tagline = UserTagline(rawValue: rawValue) else {
            return .fitnessEnthusiast
        }
        return tagline
    }
}
