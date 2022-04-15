#!/bin/bash

#buildNum=284

echo "1. Make folder"
mkdir ./M-Online
cd ./M-Online


echo "2. Git Clone"
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter

echo "3. Copy config Fastlane iOS"
cd ./ios
mkdir fastlane
cd ./fastlane
cp ~/Documents/project/fastlane/Appfile-m-online Appfile
cp ~/Documents/project/fastlane/Fastfile-m-online Fastfile
#cp ~/Documents/project/fastlane/api_key_path.json api_key_path.json
cd ../..


echo "4. Copy config Fastlane Android"
cd ./android
mkdir fastlane
cp ~/Documents/project/fastlane/Appfile-m-online-android ./fastlane/Appfile
cp ~/Documents/project/fastlane/Fastfile-m-online-android ./fastlane/Fastfile
cd ..

echo "5. Get date"
DateToday=$(date "+%d.%m.%Y")


echo "6. Get version number"
cd ./ios
fastlane run latest_testflight_build_number >> result_from_testflight
grep build: result_from_testflight >> result_build
buildNum=$(tail -c4 result_build)
let "buildNum += 2"
cd ..

echo "7. Copy key.properties"
cp ~/Documents/project/key-android/key.properties ./android/key.properties

echo "8. Corrected build.gradle for Android"
cd ./android/app
gsed -i '/android {/i def keystoreProperties = new Properties()' build.gradle
gsed -i '/android {/i def keystorePropertiesFile = rootProject.file("key.properties")' build.gradle
gsed -i '/android {/i if (keystorePropertiesFile.exists()) {' build.gradle
gsed -i '/android {/i keystoreProperties.load(new FileInputStream(keystorePropertiesFile))' build.gradle
gsed -i 's/keystoreProperties.load(new FileInputStream(keystorePropertiesFile))/     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))/' build.gradle
gsed -i '/android {/i }' build.gradle
gsed -i '/android {/i changestring' build.gradle
gsed -i 's/changestring//' build.gradle

gsed -i 's/versionCode flutterVersionCode.toInteger()/versionCode '$buildNum'/' build.gradle
gsed -i 's/versionName flutterVersionName/versionName "3.0.'$buildNum'"/' build.gradle

gsed -i '/buildTypes {/i signingConfigs {' build.gradle
gsed -i '/buildTypes {/i release {' build.gradle
gsed -i '/buildTypes {/i keyAlias keystoreProperties["keyAlias"]' build.gradle
gsed -i '/buildTypes {/i keyPassword keystoreProperties["keyPassword"]' build.gradle
gsed -i '/buildTypes {/i storeFile keystoreProperties["storeFile"] ? file(keystoreProperties["storeFile"]) : null' build.gradle
gsed -i '/buildTypes {/i storePassword keystoreProperties["storePassword"]' build.gradle
gsed -i '/buildTypes {/i }' build.gradle
gsed -i '/buildTypes {/i }' build.gradle

gsed -i 's/signingConfig signingConfigs.debug/signingConfig signingConfigs.release/' build.gradle
cd ../..


echo "9. Corrected constants"
gsed -i -e 's!3.0.113!3.0.'$buildNum'!; s/13.08.2021/'$DateToday'/' ./lib/utils/constants.dart


echo "10. Corrected Info.plist for iOS"
gsed -i -e 's!$(FLUTTER_BUILD_NUMBER)!'$buildNum'!; s!$(FLUTTER_BUILD_NAME)!3.0.'$buildNum'!' ./ios/Runner/Info.plist


echo "11. Build appbundle"
flutter pub upgrade
flutter pub get
flutter build appbundle


echo "12. Run FastLane for Android"
cd ./android
fastlane android internal
cd ..


echo "13. Run FastLane for iOS"
cd ./ios
pod install
pod update
fastlane ios beta

