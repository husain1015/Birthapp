# Xcode Setup Instructions for ReadyBirth Prep

Follow these steps to create a new Xcode project and import the existing Swift files:

## Step 1: Create New Xcode Project

1. Open Xcode
2. Select **"Create New Project"** (or File → New → Project)
3. Choose **iOS** → **App** → Click **Next**
4. Configure the project:
   - **Product Name**: ReadyBirthPrep
   - **Team**: Select your team (Personal Team is fine for development)
   - **Organization Identifier**: com.yourname (e.g., com.husain)
   - **Bundle Identifier**: Will auto-generate as com.yourname.ReadyBirthPrep
   - **Interface**: SwiftUI
   - **Language**: Swift
   - **Use Core Data**: Unchecked (we're using UserDefaults for now)
   - **Include Tests**: Check if you want unit tests
5. Click **Next**
6. Choose the location: `/Users/ha_mac_mini/Desktop/BirthApp`
7. Make sure **"Create Git repository on my Mac"** is unchecked (we already have one)
8. Click **Create**

## Step 2: Remove Default Files

Xcode will create some default files. Delete these from the project navigator:
- ContentView.swift (we have our own)
- Any default asset catalogs if not needed

To delete: Right-click → Delete → Move to Trash

## Step 3: Import Existing Files

1. In Xcode's project navigator (left sidebar), right-click on the **ReadyBirthPrep** folder
2. Select **"Add Files to ReadyBirthPrep..."**
3. Navigate to the ReadyBirthPrep folder containing your Swift files
4. Select all the folders:
   - App
   - Models
   - Views
   - Services
5. Important settings in the dialog:
   - ✓ **Copy items if needed**: Unchecked (files are already in place)
   - ✓ **Create groups**: Selected
   - ✓ **Add to targets**: ReadyBirthPrep should be checked
6. Click **Add**

## Step 4: Configure Project Settings

1. Select the project in the navigator (top blue icon)
2. In the **General** tab:
   - **Minimum Deployments**: Set to iOS 16.0
   - **Device Orientation**: Portrait only (uncheck Landscape)
   - **Status Bar Style**: Default

3. In the **Signing & Capabilities** tab:
   - Make sure your team is selected
   - Bundle Identifier is set correctly

## Step 5: Add Required Capabilities

In the **Signing & Capabilities** tab, click **"+ Capability"** to add:

1. **Push Notifications** (for exercise reminders)
2. **Background Modes** → Check "Background fetch" (for notifications)

## Step 6: Configure Info.plist

Add these privacy usage descriptions (required for future features):

1. Select Info.plist
2. Add the following keys:
   - **Privacy - Camera Usage Description**: "ReadyBirth Prep needs camera access to record exercise form videos"
   - **Privacy - Photo Library Usage Description**: "ReadyBirth Prep needs photo access to save birth plans"

## Step 7: Build and Run

1. Select a simulator (iPhone 14 or newer recommended)
2. Press **Cmd + B** to build
3. Press **Cmd + R** to run

## Troubleshooting

### If you see "No such module" errors:
- Make sure all Swift files are added to the correct target
- Clean build folder: Shift + Cmd + K

### If you see signing errors:
- Go to Signing & Capabilities
- Click "Try Again" if automatic signing fails
- Or select "Personal Team" if you don't have a paid developer account

### Missing SwiftUI previews:
- Make sure you're running Xcode 14 or later
- Preview requires macOS Ventura or later

## Next Steps

Once the project builds successfully:

1. Test on simulator first
2. To test on real device:
   - Connect iPhone via USB
   - Select your device from the device menu
   - Trust the developer certificate on device (Settings → General → VPN & Device Management)

## Project Structure Verification

Your Xcode project navigator should show:
```
ReadyBirthPrep
├── ReadyBirthPrep
│   ├── App
│   │   ├── ReadyBirthPrepApp.swift
│   │   └── ContentView.swift
│   ├── Models
│   │   ├── User.swift
│   │   ├── Exercise.swift
│   │   ├── BirthPlan.swift
│   │   ├── Contraction.swift
│   │   └── PostpartumPhase.swift
│   ├── Views
│   │   ├── Onboarding
│   │   ├── Dashboard
│   │   ├── PrenatalPrep
│   │   ├── LaborBirth
│   │   ├── Postpartum
│   │   └── Profile
│   └── Services
│       └── UserManager.swift
└── Products
    └── ReadyBirthPrep.app
```