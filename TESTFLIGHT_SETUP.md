# TestFlight Setup for ReadyBirth Prep

## Prerequisites
1. Apple Developer Account ($99/year)
2. Xcode 15+ installed
3. Valid provisioning profiles
4. App Store Connect access

## Step 1: Configure App in Xcode

### 1.1 Update Bundle Identifier
1. Open `ReadyBirthPrep.xcodeproj` in Xcode
2. Select the project in navigator
3. Select "ReadyBirthPrep" target
4. Under "General" tab:
   - Bundle Identifier: `com.yourcompany.readybirthprep`
   - Version: `1.0.0`
   - Build: `1`

### 1.2 Set Team & Signing
1. In "Signing & Capabilities" tab:
   - Check "Automatically manage signing"
   - Team: Select your developer team
   - Bundle Identifier: Confirm it matches above

### 1.3 Update Deployment Info
1. In "General" tab:
   - Minimum Deployments: iOS 16.0
   - Device: iPhone only (or Universal)
   - Device Orientation: Portrait only

## Step 2: Add Required Assets

### 2.1 App Icons
You need to add app icons in these sizes:
- 1024x1024 (App Store)
- 120x120 (iPhone App 2x)
- 180x180 (iPhone App 3x)

1. Select `Assets.xcassets` in Xcode
2. Click on "AppIcon"
3. Drag and drop your icon files

### 2.2 Launch Screen
Already configured with your app

## Step 3: Configure Capabilities

### 3.1 Update Info.plist
Add these keys if not present:
```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to scan documents for your birth plan.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>This app needs photo library access to add images to your birth plan.</string>

<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

### 3.2 API Key Configuration
For TestFlight, you have two options:

**Option A: Hardcode for Testing (Not Recommended for Production)**
```swift
// In ExerciseRecommendationService.swift
private let apiKey = "your-test-api-key-here"
```

**Option B: Use Configuration File**
1. Create `Config.xcconfig` file
2. Add: `ANTHROPIC_API_KEY = your-api-key`
3. Add to .gitignore
4. Reference in Info.plist

## Step 4: Build for TestFlight

### 4.1 Select Generic iOS Device
1. In Xcode toolbar, select "Any iOS Device" as destination

### 4.2 Archive the App
1. Menu: Product → Archive
2. Wait for build to complete
3. Organizer window will open

### 4.3 Validate the Archive
1. In Organizer, select your archive
2. Click "Validate App"
3. Follow prompts to validate

### 4.4 Upload to App Store Connect
1. Click "Distribute App"
2. Select "App Store Connect"
3. Select "Upload"
4. Follow prompts

## Step 5: Configure in App Store Connect

### 5.1 Create App
1. Log in to [App Store Connect](https://appstoreconnect.apple.com)
2. Click "My Apps"
3. Click "+" → "New App"
4. Fill in:
   - Platform: iOS
   - Name: ReadyBirth Prep
   - Primary Language: English
   - Bundle ID: Select from dropdown
   - SKU: readybirthprep001

### 5.2 TestFlight Setup
1. Go to your app in App Store Connect
2. Click "TestFlight" tab
3. Complete Test Information:
   - Beta App Description
   - Email
   - Privacy Policy URL (can be placeholder)

### 5.3 Add Test Users
1. In TestFlight tab, click "+" next to "Testers"
2. Add internal testers (your email)
3. Or create a public link for external testing

## Step 6: Install on iPhone

### 6.1 Download TestFlight
1. On your iPhone, download "TestFlight" from App Store

### 6.2 Accept Invitation
1. Check email for TestFlight invitation
2. Tap "View in TestFlight"
3. Accept and install

## Common Issues & Solutions

### Build Errors
- **Signing issues**: Ensure you're logged into Xcode with your Apple ID
- **Provisioning profile**: Let Xcode manage automatically
- **Bundle ID taken**: Use unique identifier

### Upload Errors
- **Missing compliance**: Add encryption compliance key
- **Icon issues**: Ensure all sizes are provided
- **Version conflicts**: Increment build number

### TestFlight Issues
- **App not appearing**: Wait 5-10 minutes after upload
- **Can't install**: Check device iOS version
- **Crashes on launch**: Check API key configuration

## Quick Checklist

- [ ] Apple Developer account active
- [ ] Bundle identifier set
- [ ] Team selected in Xcode
- [ ] App icons added (1024x1024, 120x120, 180x180)
- [ ] Info.plist permissions added
- [ ] API key configured
- [ ] Archive validated
- [ ] Uploaded to App Store Connect
- [ ] TestFlight configured
- [ ] Test users added

## Testing the AI Features

Since the app uses Claude API:
1. Ensure API key is properly configured
2. Test with small usage first
3. Monitor API usage in Anthropic console

## Next Steps

After successful TestFlight testing:
1. Gather feedback from testers
2. Fix any reported issues
3. Prepare for App Store submission
4. Create App Store screenshots
5. Write app description

## Support

For issues:
- Xcode signing: Check Apple Developer forums
- TestFlight: Contact App Store Connect support
- App specific: Check console logs in Xcode