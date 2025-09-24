# Thebes - iOS Fitness Tracking App

A comprehensive iOS fitness tracking application built with SwiftUI and Firebase, featuring workout tracking, social features, and user profiles.

## 🏗️ Architecture

### **Framework & Technologies**
- **Frontend**: SwiftUI
- **Backend**: Firebase (Authentication + Firestore)
- **Architecture Pattern**: MVVM (Model-View-ViewModel)
- **Navigation**: TabView with NavigationStack

### **Project Structure**
```
Thebes/
├── App/
│   ├── ThebesApp.swift          # Main app entry point, Firebase config
│   └── ContentView.swift        # Placeholder view
├── Models/
│   ├── UserProfile.swift        # User data model with social connections
│   ├── Workout.swift           # Workout session model
│   ├── Exercise.swift          # Exercise within workout
│   ├── SetData.swift           # Individual set data
│   ├── Template.swift          # Workout template
│   └── MockUserProfile.swift   # Simplified mock user for testing
├── Services/
│   ├── AuthService.swift       # Firebase Authentication
│   ├── FirestoreManager.swift  # Centralized Firestore access
│   ├── UserService.swift       # User profile operations
│   ├── WorkoutService.swift    # Workout CRUD operations
│   └── Social/
│       ├── SocialService.swift # Social features (follow, search, etc.)
│       └── FollowersService.swift # Followers management
├── ViewModels/
│   ├── AuthViewModel.swift     # Authentication state management
│   ├── HomeViewModel.swift     # Home dashboard logic
│   ├── TrackerViewModel.swift  # Workout tracking logic
│   └── Social/
│       ├── SocialViewModel.swift      # Main social view
│       ├── SocialSearchViewModel.swift # User search functionality
│       ├── FollowingViewModel.swift   # Following users management
│       ├── FollowersViewModel.swift   # Followers management
│       ├── FriendsViewModel.swift     # Mutual connections
│       └── UserProfileViewModel.swift # Individual user profiles
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift     # User authentication
│   │   └── SignupView.swift    # User registration
│   ├── HomeView.swift          # Main dashboard
│   ├── ProfileView.swift       # Current user profile
│   ├── TrackerView.swift       # Workout tracking interface
│   ├── WorkoutsView.swift      # Workout management
│   ├── Shared/
│   │   ├── MainTabView.swift   # Main tab navigation
│   │   └── TopNavBarView.swift # Custom navigation header
│   └── Social/
│       ├── SocialView.swift         # Main social hub
│       ├── SocialSearchView.swift   # User search interface
│       ├── FollowingView.swift      # Users being followed
│       ├── FollowersView.swift      # User's followers
│       ├── FriendsView.swift        # Mutual connections
│       ├── UserProfileView.swift    # Individual user profiles
│       └── RecentActivityView.swift # Recent workouts feed
└── Utilities/
    ├── Colors.swift           # App color palette
    ├── AppSettings.swift      # App configuration
    ├── ConversionUtils.swift  # Unit conversion utilities
    ├── MockData.swift         # Mock data generators
    └── PlaceholderModifier.swift # Custom text field styling
```

## 🎨 Design System

### **Color Palette**
```swift
struct AppColors {
    static let primary = Color(red: 15/255, green: 15/255, blue: 15/255)     // Dark Gray
    static let secondary = Color(red: 20/255, green: 184/255, blue: 166/255) // Teal
    static let complementary = Color(red: 100/255, green: 100/255, blue: 100/255) // Light Gray
}
```

### **Custom Components**
- **PlaceholderModifier**: Custom text field styling with white placeholder text
- **SocialStatCard**: Reusable social statistics display component
- **UserCard**: Consistent user profile card design across social views

## 🔐 Authentication & User Management

### **Firebase Authentication**
- Email/password authentication
- Email verification flow
- User profile creation on first sign-up
- Global authentication state management via `AuthService`

### **User Profile Model**
```swift
struct UserProfile: Codable, Identifiable {
    @DocumentID var id: String?
    var uid: String                    // Firebase Auth UID
    var displayName: String
    var email: String
    var profilePic: String?
    var createdAt: Date
    var preferredWeightUnit: String
    var trackedExercise: String?       // Currently tracked exercise
    var followers: [String]           // Array of follower UIDs
    var following: [String]           // Array of following UIDs
}
```

### **Mock Users**
- Simplified `MockUserProfile` for testing
- Automatically converted to full `UserProfile` format
- Supports following/followers functionality
- Uploaded via `firestore_uploader/` scripts

## 🏋️ Workout System

### **Data Models**
- **Workout**: Complete workout session with exercises and metadata
- **Exercise**: Individual exercise within a workout
- **SetData**: Individual set with reps, weight, and notes
- **Template**: Reusable workout templates

### **Key Features**
- Workout logging with exercises and sets
- Template creation and management
- Workout history and tracking
- Exercise database with common exercises

## 👥 Social Features

### **Core Social Functionality**
- **Follow/Unfollow**: Users can follow other users
- **Followers/Following**: Track social connections
- **Friends**: Mutual follows (users following each other)
- **User Search**: Find users by display name
- **Recent Activity**: Feed of recent workouts from followed users

### **Social Views**
1. **SocialView**: Main hub with personalized greeting and stats
2. **SocialSearchView**: Search and discover users
3. **FollowingView**: Manage users you're following
4. **FollowersView**: View and follow back followers
5. **FriendsView**: View mutual connections
6. **UserProfileView**: Individual user profiles with follow/unfollow
7. **RecentActivityView**: Recent workouts from followed users

### **Social Data Flow**
- Real-time UI updates via callback patterns
- Immediate state changes after follow/unfollow actions
- Consistent data across all social views
- Support for both real users and mock users

## 🔧 Key Implementation Patterns

### **MVVM Architecture**
- **Models**: Data structures with Codable conformance
- **Views**: SwiftUI views with minimal business logic
- **ViewModels**: ObservableObject classes managing state and data operations
- **Services**: Handle Firebase operations and data persistence

### **State Management**
- `@Published` properties for reactive UI updates
- `@StateObject` for ViewModel lifecycle management
- `@EnvironmentObject` for shared data (AuthViewModel)
- Callback patterns for cross-view communication

### **Firebase Integration**
- **Firestore**: NoSQL document database
- **Authentication**: User management and security
- **Document Structure**: Users, workouts, exercises collections
- **Real-time Updates**: Automatic UI refresh on data changes

### **Navigation Patterns**
- Tab-based main navigation
- Sheet presentations for modal views
- NavigationStack for hierarchical navigation
- Item-based sheet presentation for robust state management

## 🧪 Testing & Development

### **Mock Data**
- Mock users in Firestore for testing social features
- Mock workouts for development and testing
- Upload scripts in `firestore_uploader/` directory

### **Development Notes**
- Social features fully functional with mock users
- Follow/unfollow works for both real and mock users
- Recent activity feed shows workouts from past year (dev setting)
- All navigation and state management working correctly

## 🚀 Current Status

### **Completed Features**
✅ User authentication and profiles  
✅ Workout tracking and templates  
✅ Complete social system (follow, search, profiles)  
✅ Navigation and state management  
✅ Mock user support for testing  
✅ UI/UX with consistent design system  

### **Pending Enhancements**
- Social stats visual improvements
- Additional action buttons on user cards
- Performance optimizations
- Additional social features (messaging, etc.)

## 🔄 Getting Back Up to Speed

When returning to this project:

1. **Review this README** for architecture and patterns
2. **Check Firebase console** for data structure
3. **Run the app** to see current functionality
4. **Review recent changes** in git history
5. **Test social features** with mock users (Alex Johnson, etc.)

## 📱 Key User Flows

### **Social Flow**
1. User opens Social tab → sees personalized greeting and stats
2. Can search for users → follow/unfollow with immediate UI updates
3. Can view Following/Followers/Friends lists
4. Can view individual user profiles with recent workouts
5. Can see recent activity feed from followed users

### **Workout Flow**
1. User opens Tracker tab → logs workouts with exercises and sets
2. Can create and use workout templates
3. Can view workout history and progress
4. Workouts appear in social feeds for followers

## 🛠️ Development Commands

```bash
# Upload mock users to Firestore
cd firestore_uploader
node uploadUsers.js

# Upload mock workouts to Firestore  
node uploadAll.js
```

---

**Last Updated**: December 2024  
**Status**: Core features complete, social system fully functional
