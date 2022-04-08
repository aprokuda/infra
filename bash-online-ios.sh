#!/bin/bash

#buildNum=284

echo "1. Make folder"
mkdir ./M-Online
cd ./M-Online


echo "2. Git Clone"
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter


echo "3. Install and update pub & pod" 
flutter pub upgrade
flutter pub get
cd ./ios
pod install
pod update


echo "4. Copy config Fastlane"
mkdir fastlane
cd ./fastlane
cp ~/Documents/project-test/fastlane/Appfile-m-online Appfile
cp ~/Documents/project-test/fastlane/Fastfile-m-online Fastfile
#cp ~/Documents/project-test/fastlane/api_key_path.json api_key_path.json
cd ..


echo "5. Get version number"
fastlane run latest_testflight_build_number >> result
grep build: result >> result1
buildNum=$(tail -c4 result1)
let "buildNum += 2"


echo "6. Change Info.plist for iOS"
sed -i".bak" -e 's!$(FLUTTER_BUILD_NUMBER)!'$buildNum'!; s!$(FLUTTER_BUILD_NAME)!3.0.'$buildNum'!' ./Runner/Info.plist
#rm .Runner/Info.plist.bak


echo "8. Run FastLane"
fastlane ios beta

 
