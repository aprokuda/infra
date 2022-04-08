#!/bin/bash

echo "1. Make folder"
mkdir ./M-Online-andriod
cd ./M-Online-android


echo "2. Git Clone"
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter


echo "3. Copy key.properties"
cp ~/Documents/project-test/key-android/key.properties ./android/key.properties

echo "4. Build.gradle corrected"



#echo "3. Install and update pub" 
#flutter pub upgrade


#echo "5. Get version number"
#fastlane run latest_testflight_build_number >> result
#grep build: result >> result1
#buildNum=$(tail -c4 result1)
#let "buildNum += 2"



#echo "6. Change Info.plist for iOS"
#sed -i".bak" -e 's!$(FLUTTER_BUILD_NUMBER)!'$buildNum'!; s!$(FLUTTER_BUILD_NAME)!3.0.'$buildNum'!' ./Runner/Info.plist
#rm .Runner/Info.plist.bak


#echo "8. Run FastLane"
#fastlane ios beta

 
