# Deploying Privacy Policy and Terms of Service to Firebase Hosting

## Prerequisites
1. Install Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

## Deployment Steps

1. **Initialize Firebase Hosting** (if not already done):
   ```bash
   firebase init hosting
   ```
   - Select "Use an existing project"
   - Choose "thebes-dbc17"
   - Set public directory to: `hosting`
   - Configure as single-page app: `No`
   - Set up automatic builds and deploys: `No` (optional)

2. **Deploy to Firebase Hosting**:
   ```bash
   firebase deploy --only hosting
   ```

3. **Verify Deployment**:
   - Privacy Policy: https://thebes-dbc17.web.app/privacy-policy.html
   - Terms of Service: https://thebes-dbc17.web.app/terms-of-service.html
   - Landing page: https://thebes-dbc17.web.app/

## Alternative: Custom Domain (Optional)

If you want to use a custom domain:
1. Go to Firebase Console > Hosting
2. Click "Add custom domain"
3. Follow the instructions to verify your domain
4. Update the URLs in `ProfileSettingsView.swift` to use your custom domain

## Files Structure
```
hosting/
├── index.html              # Landing page
├── privacy-policy.html     # Privacy Policy
└── terms-of-service.html   # Terms of Service
```

## Updating Documents

To update the documents:
1. Edit the HTML files in the `hosting/` directory
2. Run `firebase deploy --only hosting` again

## Contact Information

Before deploying, update the contact email in both HTML files if needed:
- Currently set to: `support@thebes.app`
- You can change this in `PrivacyPolicy.html` and `TermsOfService.html`

