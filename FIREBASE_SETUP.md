# Firebase Configuration Guide

This guide will help you configure Firebase for Google Sign-In and Apple Sign-In.

## Prerequisites

1. A Firebase project at https://console.firebase.google.com
2. Your iOS app registered in Firebase Console
3. Your `GoogleService-Info.plist` file downloaded and added to your Xcode project

## Google Sign-In Configuration

### Step 1: Enable Google Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project (`thebes-dbc17`)
3. Navigate to **Authentication** > **Sign-in method**
4. Find **Google** in the list and click on it
5. **Enable** Google Sign-In
6. Set your **Project support email** (required)
7. Click **Save**

### Step 2: Configure URL Scheme in Xcode

1. Open your project in Xcode
2. Select your project in the navigator
3. Select your app target
4. Go to the **Info** tab
5. Expand **URL Types** (if it doesn't exist, click the **+** button)
6. Add a new URL Type:
   - **Identifier**: `GoogleSignIn`
   - **URL Schemes**: Use the **REVERSED_CLIENT_ID** from your `GoogleService-Info.plist`
     - Example: `com.googleusercontent.apps.908656713054-bobjbnsee5ju20m280ir8k5pdovk8tko`
   - You can find this value in `GoogleService-Info.plist` under the key `REVERSED_CLIENT_ID`

### Step 3: Verify GoogleService-Info.plist

Make sure your `GoogleService-Info.plist` is:
- ✅ Added to your Xcode project
- ✅ Included in your app target (check in Target Membership)
- ✅ Located in the root of your project directory

### Step 4: Test Google Sign-In

1. Build and run your app
2. Try signing in with Google
3. Check the Xcode console for any error messages
4. Common issues:
   - **"Missing Firebase client ID"**: Verify `GoogleService-Info.plist` is properly included
   - **"Failed to get Google ID token"**: Check Firebase Console has Google Sign-In enabled
   - **URL Scheme not working**: Verify the REVERSED_CLIENT_ID is correctly added to URL Types

## Apple Sign-In Configuration

### Step 1: Enable Apple Sign-In in Firebase

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Navigate to **Authentication** > **Sign-in method**
4. Find **Apple** in the list and click on it
5. **Enable** Apple Sign-In
6. Set your **Apple Services ID** (optional for iOS apps)
7. Click **Save**

### Step 2: Enable Sign in with Apple Capability in Xcode

1. Open your project in Xcode
2. Select your project in the navigator
3. Select your app target
4. Go to the **Signing & Capabilities** tab
5. Click **+ Capability**
6. Add **Sign in with Apple**
   - This capability is required for App Store submission

### Step 3: Verify Bundle Identifier

Make sure your Bundle Identifier matches:
- Your Xcode project: `com.Ben.Thebes`
- Your Firebase app registration
- Your Apple Developer account (if using App Store Connect)

### Step 4: Test Apple Sign-In

1. Build and run your app on a **real device** (Apple Sign-In doesn't work in the simulator for all features)
2. Try signing in with Apple
3. Check the Xcode console for any error messages

## Common Issues and Solutions

### Google Sign-In Issues

**Issue**: "The operation couldn't be completed. (com.google.GIDSignIn error -1.)"
- **Solution**: Check that the URL scheme is correctly configured in Xcode Info tab

**Issue**: "Missing Firebase client ID"
- **Solution**: Verify `GoogleService-Info.plist` is included in your target

**Issue**: Sign-in flow doesn't open
- **Solution**: 
  1. Verify Google Sign-In is enabled in Firebase Console
  2. Check URL scheme matches REVERSED_CLIENT_ID exactly
  3. Clean build folder (Product > Clean Build Folder) and rebuild

### Apple Sign-In Issues

**Issue**: "Sign in with Apple" button doesn't appear
- **Solution**: 
  1. Make sure you're testing on iOS 13+ device
  2. Verify the capability is added in Xcode
  3. Check that you're signed in to an Apple ID on the device

**Issue**: "Invalid state: A login callback was received"
- **Solution**: This is usually a timing issue. The nonce handling should work automatically.

## App Store Requirements

For App Store submission:
- ✅ **Sign in with Apple** is required if your app offers third-party sign-in (Google, Facebook, etc.)
- ✅ Make sure Apple Sign-In is enabled and working before submission
- ✅ Test on a real device before submitting

## Additional Resources

- [Firebase Authentication Documentation](https://firebase.google.com/docs/auth)
- [Google Sign-In for iOS](https://developers.google.com/identity/sign-in/ios)
- [Apple Sign-In Documentation](https://developer.apple.com/sign-in-with-apple/)

## Checklist

### Google Sign-In
- [ ] Google Sign-In enabled in Firebase Console
- [ ] URL Scheme added to Xcode (REVERSED_CLIENT_ID)
- [ ] GoogleService-Info.plist included in project
- [ ] Tested Google Sign-In flow

### Apple Sign-In
- [ ] Apple Sign-In enabled in Firebase Console
- [ ] "Sign in with Apple" capability added in Xcode
- [ ] Tested Apple Sign-In flow on real device

### General
- [ ] Both authentication methods tested
- [ ] Error handling verified
- [ ] User profiles created in Firestore after sign-in

