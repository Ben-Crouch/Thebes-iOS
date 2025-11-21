# App Privacy Details for App Store Connect

## Based on Your App's Data Collection

Review these and copy the relevant information to App Store Connect → App Privacy.

---

## Data Collection Summary

### Data Your App Collects:

1. **Workout Data**
   - Exercise names
   - Sets, reps, weights
   - Dates and timestamps
   - Workout notes
   - Templates

2. **Profile Information**
   - Display name
   - Email address
   - Profile picture (from Google/Apple)
   - User preferences (weight units, tagline)

3. **Social Data**
   - Followers/following lists
   - User connections

4. **Authentication Data**
   - Email/password (stored by Firebase, not accessible to you)
   - Google Sign-In tokens (handled by Firebase)
   - Apple Sign-In tokens (handled by Firebase)

---

## App Store Connect - App Privacy Form

Go to: App Store Connect → Your App → App Privacy

### For Each Data Type, You'll Answer:

#### 1. Does your app collect [Data Type]?
**Yes** - Select "Yes" for:
- Name (display name)
- Email address
- User content (workouts, exercises, notes)
- Other user content (templates)
- Fitness info (workout data, exercise tracking)

**No** - For:
- Location data
- Contacts
- Photos (unless you plan to let users upload photos)
- Purchases/payment info
- Browsing history

---

### 2. For Each Data Type, How Is It Used?

**Workout/Exercise Data:**
- ✅ App Functionality (primary purpose - storing user workouts)
- ✅ Analytics (if you enable Firebase Analytics)

**Profile Information:**
- ✅ App Functionality (user profiles, social features)
- ✅ Analytics (if you enable Firebase Analytics)

**Email Address:**
- ✅ App Functionality (authentication, account management)
- ✅ Developer Communications (sending password reset emails)

---

### 3. Is This Data Linked to the User's Identity?

**Answer: Yes** for all data types you collect
- All data is associated with user accounts
- Data is linked to Firebase Auth user IDs

---

### 4. Does Your App Track Users?

**Answer: No** (unless you plan to use Firebase Analytics with ad tracking)

**Tracking Definition:**
- Linking user data across apps/websites for advertising
- Sharing user data with data brokers
- Using user data for advertising/marketing purposes

**Note:** Basic analytics (like Firebase Analytics) that only measure app performance are NOT considered tracking.

---

## Recommended Answers for App Store Connect:

### Name
- **Collected:** Yes
- **Used for:** App Functionality, Analytics (if enabled)
- **Linked to User:** Yes
- **Tracking:** No

### Email Address
- **Collected:** Yes
- **Used for:** App Functionality, Developer Communications
- **Linked to User:** Yes
- **Tracking:** No

### User Content (Workouts, Exercises, Notes)
- **Collected:** Yes
- **Used for:** App Functionality, Analytics (if enabled)
- **Linked to User:** Yes
- **Tracking:** No

### Other User Content (Templates)
- **Collected:** Yes
- **Used for:** App Functionality
- **Linked to User:** Yes
- **Tracking:** No

### Fitness Info
- **Collected:** Yes
- **Used for:** App Functionality, Analytics (if enabled)
- **Linked to User:** Yes
- **Tracking:** No

### Device ID
- **Collected:** Maybe (Firebase may collect automatically)
- **Used for:** Analytics (if enabled)
- **Linked to User:** Yes (if collected)
- **Tracking:** No

---

## Important Notes:

1. **Firebase Analytics:** If you enable Firebase Analytics, mark Analytics as "Yes" for data usage
2. **Third-Party Data Sharing:** You're not sharing data with third parties (except Firebase, which is your service provider)
3. **Age Restrictions:** Your app doesn't collect data from children under 13 (you handle this in Privacy Policy)

---

## Next Steps:

1. Go to App Store Connect
2. Navigate to App Privacy section
3. Answer questions based on the recommendations above
4. Be accurate - Apple reviews this carefully

---

## Support URL:

Use: `https://thebes-dbc17.web.app/privacy-policy.html`

This points to your Privacy Policy hosted on Firebase.

