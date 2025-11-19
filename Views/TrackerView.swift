//
//  TrackerView.swift
//  Thebes
//
//  Created by Ben on 17/02/2025.
//

import SwiftUI
import Charts

struct TrackerView: View {
    @ObservedObject var viewModel: TrackerViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var showSideMenu = false
    @State private var showSettingsView = false

    var body: some View {
        ZStack(alignment: .top) {
            // Gradient background - adjusted for dark mode visibility
            LinearGradient(
                gradient: Gradient(colors: AppColors.gradientColors(for: colorScheme)),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header Section
                    VStack(spacing: 16) {
                        TopNavBarView(showSideMenu: $showSideMenu)
                        
                        VStack(spacing: 8) {
                            Text("Progress Tracker")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Track your fitness journey")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                        
                        // Dynamic description based on data availability
                        VStack(spacing: 8) {
                            if viewModel.trackedExercises.isEmpty {
                                InfoCard(
                                    icon: "exclamationmark.triangle.fill",
                                    title: "No Data Yet",
                                    message: "Start logging workouts to see your progress here. The more workouts you log, the better insights you'll get!",
                                    color: .orange
                                )
                            } else if viewModel.trackedExercises.count < 3 {
                                InfoCard(
                                    icon: "chart.line.uptrend.xyaxis",
                                    title: "Building Your Data",
                                    message: "Great start! Log a few more workouts to see meaningful progress trends and statistics.",
                                    color: .blue
                                )
                            } else if viewModel.trackedExercises.count < 10 {
                                InfoCard(
                                    icon: "star.fill",
                                    title: "Progress Tracking Active",
                                    message: "Nice! You're building a good dataset. Keep logging workouts to unlock more detailed analytics.",
                                    color: .green
                                )
                            } else {
                                InfoCard(
                                    icon: "trophy.fill",
                                    title: "Rich Data Available",
                                    message: "Excellent! You have plenty of data for comprehensive progress tracking and insights.",
                                    color: .purple
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Exercise Selection Card
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "dumbbell.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                            
                            Text("Exercise Selection")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        // Exercise Selection Button
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Exercise")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Button(action: {}) {
                                HStack {
                                    if let selectedExercise = viewModel.selectedExercise {
                                        Text(selectedExercise)
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                            .foregroundColor(.white)
                                    } else {
                                        Text("Select Exercise")
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(AppColors.secondary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.08))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(viewModel.selectedExercise != nil ? AppColors.secondary.opacity(0.5) : Color.white.opacity(0.2), lineWidth: 1)
                                        )
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .overlay(
                                Menu {
                                    ForEach(viewModel.allExerciseNames, id: \.self) { exercise in
                                        Button(action: {
                                            viewModel.selectedExercise = exercise
                                        }) {
                                            HStack {
                                                Text(exercise)
                                                if viewModel.selectedExercise == exercise {
                                                    Spacer()
                                                    Image(systemName: "checkmark")
                                                        .foregroundColor(AppColors.secondary)
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Color.clear
                                }
                            )
                        }
                        
                        // Time Range Selection
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Time Range")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    Spacer()
                                    ForEach(viewModel.timeRanges, id: \.self) { range in
                                        Button(action: {
                                            viewModel.selectedTimeRange = range
                                            viewModel.updateSelectedTimeRange(range)
                                        }) {
                                            Text(range)
                                                .font(.caption)
                                                .fontWeight(.medium)
                                                .foregroundColor(viewModel.selectedTimeRange == range ? .black : .white)
                                                .padding(.horizontal, 12)
                                                .padding(.vertical, 8)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 8)
                                                        .fill(viewModel.selectedTimeRange == range ? AppColors.secondary : Color.white.opacity(0.08))
                                                        .overlay(
                                                            RoundedRectangle(cornerRadius: 8)
                                                                .stroke(viewModel.selectedTimeRange == range ? AppColors.secondary : Color.white.opacity(0.2), lineWidth: 1)
                                                        )
                                                )
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                    Spacer()
                                }
                                .padding(.horizontal, 2) // Add small padding to prevent edge clipping
                            }
                        }
                        
                        // Unit Display
                        HStack {
                            Text("Unit")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            HStack(spacing: 6) {
                                Image(systemName: "scalemass")
                                    .font(.caption)
                                    .foregroundColor(AppColors.secondary)
                                Text(viewModel.preferredWeightUnit.displayName)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(AppColors.secondary)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Progress Chart Card
                    if viewModel.selectedExercise != nil {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.title2)
                                
                                Text("Progress Chart")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            if viewModel.trackedExercises.isEmpty {
                                VStack(spacing: 16) {
                                    Image(systemName: "chart.line.uptrend.xyaxis")
                                        .foregroundColor(AppColors.secondary.opacity(0.5))
                                        .font(.system(size: 48))
                                    
                                    Text("No Data Available")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Start logging workouts with this exercise to see your progress chart")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(height: 280)
                                .frame(maxWidth: .infinity)
                            } else {
                                let unit = viewModel.preferredWeightUnit
                                Chart(viewModel.trackedExercises) { exercise in
                            if let date = exercise.date,
                               let maxWeight = exercise.sets.map({ $0.weight ?? 0 }).max() {
                                let convertedWeight = unit.convertFromKilograms(maxWeight)
                                LineMark(
                                    x: .value("Date", date),
                                    y: .value("Weight", convertedWeight)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.secondary, AppColors.secondary.opacity(0.6)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                                
                                AreaMark(
                                    x: .value("Date", date),
                                    y: .value("Weight", convertedWeight)
                                )
                                .foregroundStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [AppColors.secondary.opacity(0.3), AppColors.secondary.opacity(0.1)]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                
                                // Data point dots
                                PointMark(
                                    x: .value("Date", date),
                                    y: .value("Weight", convertedWeight)
                                )
                                .foregroundStyle(AppColors.secondary)
                                .symbolSize(60)
                                .opacity(0.9)
                            }
                        }
                        .chartYAxis {
                            AxisMarks(position: .leading) { value in
                                if let doubleValue = value.as(Double.self) {
                                    AxisGridLine()
                                        .foregroundStyle(Color.white.opacity(0.2))
                                    AxisTick()
                                        .foregroundStyle(Color.white.opacity(0.4))
                                    AxisValueLabel("\(Int(doubleValue)) \(viewModel.preferredWeightUnit.symbol)")
                                        .foregroundStyle(.white)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks { value in
                                AxisGridLine()
                                    .foregroundStyle(Color.white.opacity(0.2))
                                AxisTick()
                                    .foregroundStyle(Color.white.opacity(0.4))
                                AxisValueLabel()
                                    .foregroundStyle(.white)
                            }
                                }
                                .frame(height: 280)
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    } else {
                        // Empty state when no exercise selected
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .foregroundColor(AppColors.secondary)
                                    .font(.title2)
                                
                                Text("Progress Chart")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            
                            VStack(spacing: 16) {
                                Image(systemName: "arrow.up.circle")
                                    .foregroundColor(AppColors.secondary.opacity(0.5))
                                    .font(.system(size: 48))
                                
                                Text("Select an Exercise")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Choose an exercise above to view your progress chart and statistics")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(height: 280)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.05))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 20)
                    }
                    
                    // Stats Summary Cards
                    if viewModel.selectedExercise != nil {
                    VStack(spacing: 16) {
                        HStack {
                            Image(systemName: "chart.bar.fill")
                                .foregroundColor(AppColors.secondary)
                                .font(.title2)
                            
                            Text("Performance Stats")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        
                        // Primary Stats Row
                        HStack(spacing: 12) {
                            StatCard(
                                title: viewModel.isBodyweightExercise ? "Best Reps" : "Best EORM",
                                value: viewModel.isBodyweightExercise
                                    ? "\(viewModel.bestReps)"
                                    : String(format: "%.1f %@",
                                             viewModel.preferredWeightUnit.convertFromKilograms(viewModel.bestEORM),
                                             viewModel.preferredWeightUnit.symbol),
                                icon: "trophy.fill",
                                color: .orange
                            )
                            
                            StatCard(
                                title: "Change",
                                value: viewModel.isBodyweightExercise
                                    ? "\(viewModel.repsChange)"
                                    : String(format: "%.1f %@",
                                             viewModel.preferredWeightUnit.convertFromKilograms(viewModel.eormChange),
                                             viewModel.preferredWeightUnit.symbol),
                                icon: viewModel.isBodyweightExercise
                                    ? (viewModel.repsChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill")
                                    : (viewModel.eormChange >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill"),
                                color: viewModel.isBodyweightExercise
                                    ? (viewModel.repsChange >= 0 ? .green : .red)
                                    : (viewModel.eormChange >= 0 ? .green : .red)
                            )
                            
                            StatCard(
                                title: "Total Sets",
                                value: "\(viewModel.totalSets)",
                                icon: "list.bullet",
                                color: AppColors.secondary
                            )
                        }
                        
                        // Volume Stats Row
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Total Volume",
                                value: String(format: "%.0f %@",
                                              viewModel.preferredWeightUnit.convertFromKilograms(viewModel.totalVolume),
                                              viewModel.preferredWeightUnit.symbol),
                                icon: "scalemass.fill",
                                color: .blue
                            )
                            
                            StatCard(
                                title: "Sessions",
                                value: "\(viewModel.workoutFrequency)",
                                icon: "calendar",
                                color: .purple
                            )
                            
                            StatCard(
                                title: "Avg Volume",
                                value: String(format: "%.0f %@",
                                              viewModel.preferredWeightUnit.convertFromKilograms(viewModel.averageVolumePerSession),
                                              viewModel.preferredWeightUnit.symbol),
                                icon: "chart.bar.xaxis",
                                color: .cyan
                            )
                        }
                        
                        // Additional Stats Row
                        HStack(spacing: 12) {
                            StatCard(
                                title: "Avg Reps",
                                value: String(format: "%.1f", viewModel.averageRepsPerSet),
                                icon: "repeat",
                                color: .yellow
                            )
                            
                            StatCard(
                                title: "Volume Change",
                                value: String(format: "%.1f%%", viewModel.volumeProgressionPercentage),
                                icon: viewModel.volumeProgressionPercentage >= 0 ? "arrow.up.circle.fill" : "arrow.down.circle.fill",
                                color: viewModel.volumeProgressionPercentage >= 0 ? .green : .red
                            )
                            
                            StatCard(
                                title: "Best Session",
                                value: String(format: "%.0f %@",
                                              viewModel.preferredWeightUnit.convertFromKilograms(viewModel.bestSessionVolume),
                                              viewModel.preferredWeightUnit.symbol),
                                icon: "star.fill",
                                color: .pink
                            )
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.white.opacity(0.05))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.secondary.opacity(0.3), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, 20)
            }
            .onChange(of: viewModel.selectedExercise) { newValue in
                if let newExercise = newValue {
                    viewModel.updateSelectedExercise(newExercise)
                }
            }
            
            // Side Menu
            SideMenuView(
                isPresented: $showSideMenu,
                username: viewModel.displayName,
                profileImageUrl: viewModel.profileImageUrl,
                userEmail: authViewModel.user?.email,
                onViewProfile: {
                    // TODO: Navigate to user's own profile
                },
                onSettings: {
                    showSettingsView = true
                },
                onAbout: {
                    // TODO: Show about screen
                },
                onLogOut: {
                    authViewModel.signOut()
                }
            )
        }
        .navigationDestination(isPresented: $showSettingsView) {
            ProfileSettingsView()
                .environmentObject(authViewModel)
        }
    }
}

// MARK: - StatCard Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer(minLength: 0)
        }
        .frame(height: 80) // Fixed height for all cards
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - InfoCard Component
struct InfoCard: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.title2)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}