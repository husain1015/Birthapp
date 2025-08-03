# Installing ReadyBirth Prep on Your iPhone

## Method 1: Direct Installation via Xcode (Recommended for Testing)

### Step 1: Set Up Your Apple ID in Xcode
1. Open Xcode
2. Go to **Xcode → Settings** (or press `Cmd + ,`)
3. Click on **Accounts** tab
4. Click the **+** button to add your Apple ID
5. Sign in with your Apple ID (free account is fine)

### Step 2: Configure the Project
1. Open `ReadyBirthPrep.xcodeproj` in Xcode
2. Click on the project name in the navigator
3. Select the **ReadyBirthPrep** target
4. Go to **Signing & Capabilities** tab
5. Check **Automatically manage signing**
6. Select your Team (your Apple ID)
7. The Bundle Identifier should be unique (e.g., `com.yourname.ReadyBirthPrep`)

### Step 3: Prepare Your iPhone
1. Connect your iPhone to your Mac via USB
2. On your iPhone, you'll see "Trust This Computer?" - tap **Trust**
3. Enter your iPhone passcode if prompted
4. In Xcode, select your iPhone from the device dropdown (next to the play button)

### Step 4: Enable Developer Mode on iPhone (iOS 16+)
1. On your iPhone, go to **Settings → Privacy & Security**
2. Scroll down to **Developer Mode**
3. Toggle it ON
4. Your phone will restart
5. After restart, you'll be prompted to enable Developer Mode - tap **Turn On**

### Step 5: Build and Run
1. In Xcode, make sure your iPhone is selected as the destination
2. Click the **Play button** (or press `Cmd + R`)
3. Xcode will build the app and install it on your iPhone
4. First time only: You may see "Could not launch" error

### Step 6: Trust the Developer Certificate (First Time Only)
1. On your iPhone, go to **Settings → General → VPN & Device Management**
2. Under "Developer App", tap on your Apple ID
3. Tap **Trust "your@email.com"**
4. Tap **Trust** again in the popup

### Step 7: Launch the App
- The app should now launch automatically
- You can also find it on your home screen and tap to open

## Method 2: TestFlight (For Beta Testing)

### Prerequisites:
- Paid Apple Developer Account ($99/year)
- App Store Connect access

### Steps:
1. Archive your app in Xcode: **Product → Archive**
2. Upload to App Store Connect
3. Set up TestFlight in App Store Connect
4. Invite testers via email
5. Testers install TestFlight app and accept invitation

## Method 3: Ad Hoc Distribution

### Prerequisites:
- Paid Apple Developer Account ($99/year)
- Device UDIDs of test devices

### Steps:
1. Register device UDIDs in Apple Developer Portal
2. Create Ad Hoc provisioning profile
3. Archive app with Ad Hoc profile
4. Export .ipa file
5. Distribute via services like Diawi or iTunes

## Troubleshooting

### Common Issues:

1. **"Untrusted Developer" Error**
   - Solution: Follow Step 6 above to trust the developer certificate

2. **"Could not find Developer Disk Image"**
   - Solution: Update Xcode to support your iOS version

3. **"Failed to verify code signature"**
   - Solution: 
     - Delete the app from your iPhone
     - Clean build folder: **Product → Clean Build Folder** (or `Shift + Cmd + K`)
     - Try building again

4. **"Device is busy"**
   - Solution: 
     - Disconnect and reconnect your iPhone
     - Restart both Xcode and your iPhone

5. **App crashes on launch**
   - Solution:
     - Check the device logs in Xcode: **Window → Devices and Simulators**
     - Look for crash logs to identify the issue

### Testing Tips:

1. **Test on Different iOS Versions**: If possible, test on oldest supported iOS version
2. **Test Different Screen Sizes**: iPhone SE, iPhone 14, iPhone 14 Pro Max
3. **Test Orientations**: Make sure the app works in portrait mode
4. **Test Permissions**: Camera, photos, notifications (if used)
5. **Test Offline**: Ensure app works without internet

### Performance Testing:
1. Use Xcode's Instruments: **Product → Profile**
2. Check for memory leaks
3. Monitor CPU usage
4. Test with long usage sessions

## Quick Terminal Commands

```bash
# Open project in Xcode
cd /Users/ha_mac_mini/Desktop/BirthApp/IOS_APP/ReadyBirthPrep
open ReadyBirthPrep.xcodeproj

# Clean build folder
xcodebuild clean -project ReadyBirthPrep.xcodeproj -scheme ReadyBirthPrep

# See connected devices
xcrun devicectl list devices
```

## Notes:
- The app will remain on your device for 7 days with a free developer account
- After 7 days, you'll need to rebuild and reinstall
- With a paid developer account ($99/year), apps last for 1 year

## Ready to Test!
Your app is now installed on your iPhone. Test all features:
- ✅ User onboarding flow
- ✅ Weekly exercise plans
- ✅ Exercise tracking and streaks
- ✅ Birth plan creation and PDF export
- ✅ Hospital bag checklist
- ✅ Contraction timer
- ✅ Educational content