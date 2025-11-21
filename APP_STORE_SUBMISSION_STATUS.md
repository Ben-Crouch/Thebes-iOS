# App Store Submission Checklist Status

## ✅ Completed

### Firebase Production Setup
- ✅ Firebase project configured (thebes-dbc17)
- ✅ Firestore security rules deployed
- ✅ Firebase Hosting configured (Privacy Policy & Terms of Service)
- ✅ Email forwarding set up (support@thebes.app)

### Authentication
- ✅ Auth Providers verification complete (Google, Apple, Email/Password)
- ✅ Apple Sign-In working correctly
- ✅ Google Sign-In configured
- ✅ Account deletion implemented (per Apple guidelines)

### App Assets
- ✅ App icon created and added to Xcode (1024x1024)
- ✅ Screenshots taken (user confirmed)

### Legal & Privacy
- ✅ Privacy Policy hosted: `https://thebes-dbc17.web.app/privacy-policy.html`
- ✅ Terms of Service hosted: `https://thebes-dbc17.web.app/terms-of-service.html`
- ✅ Support email configured: `support@thebes.app`

### Apple Developer Account
- ✅ Paid Apple Developer account active

---

## 📋 Remaining Tasks

### 1. App Store Connect Setup (HIGH PRIORITY)

#### A. App Information
- [ ] Create app listing in App Store Connect
- [ ] Set app name: "Thebes" (or your preferred name)
- [ ] Set subtitle
- [ ] Write app description
- [ ] Set keywords (for App Store search)
- [ ] Set support URL: `https://thebes-dbc17.web.app/privacy-policy.html`
- [ ] Set marketing URL (optional)
- [ ] Set privacy policy URL: `https://thebes-dbc17.web.app/privacy-policy.html`

#### B. App Privacy Details (REQUIRED)
- [ ] Go to App Store Connect → App Privacy
- [ ] Complete privacy questionnaire based on `APP_PRIVACY_DETAILS.md`
- [ ] Mark data collection types:
  - Name (display name) ✅
  - Email address ✅
  - User content (workouts, exercises) ✅
  - Other user content (templates) ✅
  - Fitness info ✅
- [ ] Specify usage purposes (App Functionality, Analytics, etc.)
- [ ] Confirm data is linked to user identity
- [ ] Confirm "Does your app track users?" = **No**

#### C. Pricing and Availability
- [ ] Set price (Free or Paid)
- [ ] Set availability (all countries or specific)
- [ ] Set age rating

### 2. Upload Screenshots (HIGH PRIORITY)
- [ ] Upload screenshots for iPhone 6.7" (1290 x 2796)
- [ ] Upload screenshots for iPhone 6.5" (1242 x 2688)
- [ ] Upload screenshots for iPhone 5.5" (1242 x 2208)
- [ ] Add screenshot descriptions/captions (optional but recommended)

**Screenshot Guidelines:**
- At least 1 screenshot per size (required)
- Recommended: 3-6 screenshots per size
- Maximum: 10 screenshots per size
- Show core features: Home, Workout Logging, Social, Profile, Settings

### 3. Build and Upload (REQUIRED)

#### A. Xcode Archive
- [ ] Clean build folder (Product → Clean Build Folder)
- [ ] Set build version number (e.g., 1.0.0)
- [ ] Set build number (e.g., 1)
- [ ] Select "Any iOS Device" as destination
- [ ] Product → Archive
- [ ] Wait for archive to complete

#### B. Upload to App Store Connect
- [ ] In Organizer, click "Distribute App"
- [ ] Select "App Store Connect"
- [ ] Select "Upload"
- [ ] Follow prompts to upload
- [ ] Wait for processing (can take 10-60 minutes)

### 4. App Store Connect - Version Details

#### A. Version Information
- [ ] Set version number (e.g., 1.0.0)
- [ ] Upload build (from step 3)
- [ ] Add "What's New in This Version" release notes

#### B. App Review Information
- [ ] Add notes for reviewer (optional but recommended)
- [ ] Provide demo account credentials if needed
- [ ] Set contact information
- [ ] Set demo account (if required by features)

#### C. Version Release
- [ ] Choose release option:
  - Automatic release after review ✅
  - Manual release (you control when it goes live)
  - Scheduled release (specific date/time)

---

## 🔍 Pre-Submission Verification

### Code & Build Checks
- [ ] Build succeeds without errors
- [ ] No linter warnings (or acceptable ones)
- [ ] TestFlight build works (optional but recommended)
- [ ] All features tested on physical device

### Testing Checklist
- [ ] Email/Password sign-up works
- [ ] Email/Password sign-in works
- [ ] Google Sign-In works
- [ ] Apple Sign-In works
- [ ] Password reset works
- [ ] Account deletion works
- [ ] Workout logging works
- [ ] Social features work (follow, search, etc.)
- [ ] Settings work (weight units, avatar, tagline)
- [ ] Navigation works correctly

### Legal Compliance
- [ ] Privacy Policy accessible and accurate
- [ ] Terms of Service accessible and accurate
- [ ] Support email responds (test it)
- [ ] Account deletion works (Apple requirement)

---

## 📝 Quick Reference

### Important URLs
- **Privacy Policy:** https://thebes-dbc17.web.app/privacy-policy.html
- **Terms of Service:** https://thebes-dbc17.web.app/terms-of-service.html
- **Support Email:** support@thebes.app
- **App Store Connect:** https://appstoreconnect.apple.com

### Important Identifiers
- **Bundle ID:** com.Ben.Thebes
- **Firebase Project:** thebes-dbc17
- **Developer Name:** Benjamin Crouch

### Key Files to Reference
- `APP_PRIVACY_DETAILS.md` - For privacy questionnaire
- `APP_STORE_ASSETS.md` - For screenshot requirements
- `PRODUCTION_CHECKLIST.md` - For Firebase setup verification

---

## 🚀 Next Steps (Priority Order)

1. **Create App Listing** in App Store Connect
2. **Complete App Privacy Details** (required before submission)
3. **Upload Screenshots** to App Store Connect
4. **Archive and Upload Build** from Xcode
5. **Fill in Version Details** in App Store Connect
6. **Submit for Review**

---

## ⚠️ Important Notes

1. **App Privacy Details** must be completed before you can submit
2. **Screenshots** are required for each device size (at least 1 per size)
3. **Build Processing** can take 10-60 minutes after upload
4. **Review Time** typically 24-48 hours, but can be longer
5. **TestFlight** is optional but recommended for final testing

---

**Last Updated:** Based on current project status
**Status:** Ready for App Store Connect setup and submission

