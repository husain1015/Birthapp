#!/bin/bash

# ReadyBirth Prep iPhone Installation Helper Script

echo "🤰 ReadyBirth Prep - iPhone Installation Helper"
echo "=============================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Xcode is installed
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}❌ Xcode is not installed. Please install Xcode from the App Store.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Xcode is installed${NC}"

# Show Xcode version
echo -e "${YELLOW}Xcode version:${NC}"
xcodebuild -version

# List connected devices
echo ""
echo -e "${YELLOW}📱 Connected iOS Devices:${NC}"
xcrun devicectl list devices --filter "iPhone" 2>/dev/null || xcrun xctrace list devices 2>/dev/null | grep -E "iPhone|iPad"

# Open Xcode with the project
echo ""
echo -e "${YELLOW}Opening Xcode...${NC}"
open ReadyBirthPrep.xcodeproj

echo ""
echo -e "${GREEN}✅ Setup Instructions:${NC}"
echo "1. In Xcode, select your iPhone from the device dropdown (next to the play button)"
echo "2. Make sure 'Automatically manage signing' is checked in Signing & Capabilities"
echo "3. Select your Apple ID as the Team"
echo "4. Press the Play button (▶️) or Cmd+R to build and run"
echo ""
echo -e "${YELLOW}⚠️  First Time Setup:${NC}"
echo "- Enable Developer Mode on your iPhone: Settings → Privacy & Security → Developer Mode"
echo "- Trust the developer certificate: Settings → General → VPN & Device Management"
echo ""
echo -e "${GREEN}📖 Full instructions available in INSTALL_ON_IPHONE.md${NC}"

# Optionally clean build folder
echo ""
read -p "Do you want to clean the build folder first? (recommended for fresh install) [y/N]: " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cleaning build folder...${NC}"
    xcodebuild clean -project ReadyBirthPrep.xcodeproj -scheme ReadyBirthPrep -quiet
    echo -e "${GREEN}✅ Build folder cleaned${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Ready to install! Follow the instructions above in Xcode.${NC}"