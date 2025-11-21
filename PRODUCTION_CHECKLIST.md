# Production Firebase Setup Checklist

## Current Configuration ✅
- **Firebase Project:** thebes-dbc17
- **Bundle ID:** com.Ben.Thebes
- **Project ID:** thebes-dbc17
- **GoogleService-Info.plist:** Already configured and in use

---

## 1. Firebase Console - Authentication Setup

### Email/Password Authentication
- [ ] Go to Firebase Console → Authentication → Sign-in method
- [ ] Verify "Email/Password" is **Enabled**
- [ ] Verify "Email link (passwordless sign-in)" is **Disabled** (unless you want this)

### Google Sign-In
- [ ] Go to Authentication → Sign-in method → Google
- [ ] Verify Google Sign-In is **Enabled**
- [ ] Check that **Project support email** is set (required)
- [ ] Verify **Authorized domains** include:
  - `thebes-dbc17.firebaseapp.com`
  - `thebes-dbc17.web.app`
  - Your custom domain if you have one

**OAuth Redirect URIs should automatically include:**
- `com.googleusercontent.apps.908656713054-bobjbnsee5ju20m280ir8k5pdovk8tko:/` (from REVERSED_CLIENT_ID)

### Apple Sign-In
- [ ] Go to Authentication → Sign-in method → Apple
- [ ] Verify Apple Sign-In is **Enabled**
- [ ] Verify **OAuth code flow** is enabled
- [ ] Check configuration matches:
  - **Services ID:** (from Apple Developer Portal)
  - **Apple Team ID:** (10-character team ID)
  - **Key ID:** (from Apple Developer Portal)
  - **Private Key:** (uploaded to Firebase)

---

## 2. Firebase Console - Firestore Security Rules

**IMPORTANT:** You need to set up security rules to protect user data!

Go to Firebase Console → Firestore Database → Rules

### Recommended Production Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is authenticated
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Helper function to check if user owns the resource
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles (for social features)
      allow read: if isAuthenticated();
      // Users can only create/update their own profile
      allow create, update: if isOwner(userId);
      // Users can delete their own profile
      allow delete: if isOwner(userId);
    }
    
    // Workouts collection
    match /workouts/{workoutId} {
      // Users can only read their own workouts
      allow read: if isOwner(resource.data.userId);
      // Users can only create workouts for themselves
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      // Users can only update/delete their own workouts
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Templates collection
    match /templates/{templateId} {
      // Users can only read their own templates
      allow read: if isOwner(resource.data.userId);
      // Users can only create templates for themselves
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      // Users can only update/delete their own templates
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Exercises collection
    match /exercises/{exerciseId} {
      // Users can only read their own exercises
      allow read: if isOwner(resource.data.userId);
      // Users can only create exercises for themselves
      allow create: if isAuthenticated() && request.resource.data.userId == request.auth.uid;
      // Users can only update/delete their own exercises
      allow update, delete: if isOwner(resource.data.userId);
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**Action Required:**
- [ ] Go to Firebase Console → Firestore → Rules
- [ ] Copy and paste the security rules above (or customize as needed)
- [ ] Click "Publish" to deploy the rules
- [ ] Test that rules work correctly

---

## 3. Firebase Console - Firestore Indexes

Check if you need any composite indexes:

Go to Firebase Console → Firestore → Indexes

Common indexes you might need:
- [ ] Check if any queries are failing (error messages will indicate missing indexes)
- [ ] Create any required composite indexes

**Note:** Firestore will automatically suggest indexes when you use queries that need them.

---

## 4. Apple Developer Portal - Sign in with Apple Configuration

Verify Apple Sign-In is configured correctly:

### Services ID Configuration
- [ ] Go to https://developer.apple.com/account/resources/identifiers/list/serviceId
- [ ] Verify your Services ID exists for `com.Ben.Thebes`
- [ ] Check **Sign In with Apple** capability is enabled
- [ ] Verify **Primary App ID** is: `com.Ben.Thebes`
- [ ] Check **Return URLs** includes Firebase callback URL:
  - Should be: `https://thebes-dbc17.firebaseapp.com/__/auth/handler`

### App ID Configuration
- [ ] Go to https://developer.apple.com/account/resources/identifiers/list/appId
- [ ] Verify App ID `com.Ben.Thebes` has **Sign In with Apple** capability enabled

### Key Configuration
- [ ] Go to https://developer.apple.com/account/resources/authkeys/list
- [ ] Verify you have a Key for **Sign in with Apple**
- [ ] Note the **Key ID** (10-character string)
- [ ] Download the key file (.p8) if you need to re-upload to Firebase

---

## 5. Firebase Console - Apple Sign-In Configuration

Verify configuration matches:

- [ ] Go to Firebase Console → Authentication → Sign-in method → Apple
- [ ] Verify **Services ID** matches Apple Developer Portal
- [ ] Verify **Apple Team ID** matches (10-character, no com.Ben.Thebes)
- [ ] Verify **Key ID** matches Apple Developer Portal
- [ ] Verify **Private Key** is uploaded (if you see error, re-upload .p8 file)

---

## 6. Info.plist - URL Schemes

Verify your Info.plist has the correct URL scheme for Google Sign-In:

**Required URL Scheme:**
```
com.googleusercontent.apps.908656713054-bobjbnsee5ju20m280ir8k5pdovk8tko
```

**Check:**
- [ ] Open `Info.plist` in Xcode
- [ ] Verify `CFBundleURLTypes` includes the REVERSED_CLIENT_ID
- [ ] Should match: `com.googleusercontent.apps.908656713054-bobjbnsee5ju20m280ir8k5pdovk8tko`

---

## 7. Xcode Project Settings

### Capabilities
- [ ] Verify **Sign in with Apple** capability is enabled in Xcode
- [ ] Check Target → Signing & Capabilities

### Bundle Identifier
- [ ] Verify Bundle ID is: `com.Ben.Thebes`
- [ ] Check Target → General → Bundle Identifier

### Entitlements
- [ ] Verify `Thebes.entitlements` includes:
  - [ ] `com.apple.developer.applesignin` entitlement

---

## 8. GoogleService-Info.plist

Verify the file is correct:
- [ ] File is included in the Xcode project
- [ ] File is added to the correct target
- [ ] Check Target → Build Phases → Copy Bundle Resources includes `GoogleService-Info.plist`

**Current Configuration:**
- PROJECT_ID: thebes-dbc17 ✅
- BUNDLE_ID: com.Ben.Thebes ✅
- REVERSED_CLIENT_ID: com.googleusercontent.apps.908656713054-bobjbnsee5ju20m280ir8k5pdovk8tko ✅

---

## 9. Test Data Cleanup

Before launching to production:
- [ ] Review Firestore data for test/mock users
- [ ] Decide if you want to keep or delete test data
- [ ] Consider creating a script to clear test data

**Note:** You can keep test data for now and clear it later, or clear it before App Store submission.

---

## 10. Testing on Physical Device

**Critical:** Test all auth flows on a physical device (not simulator):
- [ ] Email/Password sign-up
- [ ] Email/Password sign-in
- [ ] Email verification
- [ ] Google Sign-In
- [ ] Apple Sign-In
- [ ] Password reset
- [ ] Account deletion
- [ ] Sign out

---

## 11. Firebase Billing & Quotas

Review your Firebase usage:
- [ ] Go to Firebase Console → Usage and billing
- [ ] Understand the free tier limits
- [ ] Set up billing alerts if needed
- [ ] Review Firestore read/write quotas

**Firebase Spark (Free) Plan Limits:**
- Authentication: Unlimited
- Firestore: 1 GB storage, 50K reads/day, 20K writes/day
- Cloud Functions: 2 million invocations/month
- Hosting: 10 GB storage, 360 MB/day transfer

---

## Quick Verification Commands

### Check if Firebase is configured correctly:
1. Open your app in Xcode
2. Build and run on a physical device
3. Try signing in with each method
4. Check Xcode console for any Firebase errors

---

## Summary

Once you've completed this checklist:
1. ✅ All auth providers enabled and configured
2. ✅ Security rules published and tested
3. ✅ Apple Sign-In verified end-to-end
4. ✅ Tested on physical device
5. ✅ Ready for App Store submission

**Next Steps After Setup:**
- Test on physical device with production Firebase
- Verify Apple Sign-In works correctly
- Clear test data if needed
- Proceed with App Store submission

