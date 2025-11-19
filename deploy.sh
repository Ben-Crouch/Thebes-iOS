#!/bin/bash
# Quick deployment script for Firebase Hosting

echo "🚀 Deploying Privacy Policy and Terms of Service to Firebase Hosting..."

# Make sure we're in the right directory
cd "$(dirname "$0")"

# Copy HTML files to hosting directory
cp PrivacyPolicy.html hosting/privacy-policy.html
cp TermsOfService.html hosting/terms-of-service.html

echo "✅ Files copied to hosting directory"

# Deploy to Firebase
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "📄 Privacy Policy: https://thebes-dbc17.web.app/privacy-policy.html"
echo "📄 Terms of Service: https://thebes-dbc17.web.app/terms-of-service.html"

