//
//  RecentActivityViewModel.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import Foundation

struct RecentWorkoutActivity: Identifiable {
    let id: String
    let workoutId: String?
    let userId: String
    let workoutTitle: String
    let workoutDate: Date
    let userDisplayName: String
    let userProfilePic: String?
    let exerciseCount: String
}

class RecentActivityViewModel: ObservableObject {
    @Published var recentWorkouts: [RecentWorkoutActivity] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    func fetchRecentActivity(for userId: String, completion: @escaping () -> Void) {
        isLoading = true
        errorMessage = nil
        
        SocialService.shared.fetchRecentActivity(userId: userId, limit: 10) { workouts in
            DispatchQueue.main.async {
                self.recentWorkouts = workouts
                self.isLoading = false
                completion()
            }
        }
    }
}
