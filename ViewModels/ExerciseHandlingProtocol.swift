//
//  WorkoutViewModelProtocol.swift
//  Thebes
//
//  Created by Ben on 10/03/2025.
//

import Foundation

protocol ExerciseHandlingProtocol: ObservableObject, AnyObject { // ✅ Ensures only class-based ViewModels can conform
    var exercises: [Exercise] { get set }
    func addSet(to exerciseIndex: Int)
    func removeSet(from exerciseIndex: Int, at setIndex: Int)
    func removeExercise(at index: Int)
    func toggleBodyweight(for index: Int)
    func showRestTime(for index: Int, isEnabled: Bool)
}

