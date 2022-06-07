#!/bin/bash


echo "1. Get date"
DateToday=$(date "+%d.%m.%Y")


echo "2. Get version number"
cd ./deploy-version/Get-folder-M-Online/ios
rm -r result_from_testflight
rm -r result_build
fastlane ios lane_get_build_number >> result_from_testflight
grep build: result_from_testflight >> result_build
buildNum=$(tail -c4 result_build)
let "buildNum += 2"
cd ../..

#buildNum=376
#cd ./deploy-version 

echo "3. Make folder"
cd ./M-Online
sudo rm -r 3.0.$buildNum
mkdir 3.0.$buildNum
cd ./3.0.$buildNum


echo "4. Git Clone"
#git clone --branch=feature/old_project_force_to_update git@github.com:m-lombard/front-flutter.git
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter


echo "5. Copy config Fastlane iOS"
cd ./ios
mkdir fastlane
cp ~/Documents/project/fastlane/Appfile-m-online ./fastlane/Appfile
cp ~/Documents/project/fastlane/Fastfile-m-online ./fastlane/Fastfile
#cp ~/Documents/project/fastlane/api_key_path.json api_key_path.json
cd ..


echo "6. Copy config Fastlane Android"
cd ./android
mkdir fastlane
cp ~/Documents/project/fastlane/Appfile-m-online-android ./fastlane/Appfile
cp ~/Documents/project/fastlane/Fastfile-m-online-android ./fastlane/Fastfile
cd ..


echo "6. Copy key.properties"
cp ~/Documents/project/key-android/key.properties ./android/key.properties
cp ~/Documents/project/key-ios/AuthKey_HMZZ5Q374W.p8 ./ios/AuthKey_HMZZ5Q374W.p8

echo "7. Corrected build.gradle for Android"
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


echo "8. Corrected constants"
gsed -i -e 's!3.0.113!3.0.'$buildNum'!; s/13.08.2021/'$DateToday'/' ./lib/utils/constants.dart


echo "9. Corrected Info.plist for iOS"
gsed -i -e 's!$(FLUTTER_BUILD_NUMBER)!'$buildNum'!; s!$(FLUTTER_BUILD_NAME)!3.0.'$buildNum'!' ./ios/Runner/Info.plist
gsed -i '/UIViewControllerBasedStatusBarAppearance/i <key>ITSAppUsesNonExemptEncryption</key>' ./ios/Runner/Info.plist
gsed -i '/UIViewControllerBasedStatusBarAppearance/i <false/>' ./ios/Runner/Info.plist


echo "10. Upgrade pub"
flutter pub upgrade
flutter pub get


echo "11. Run Fastlane for iOS"
cd ./ios
fastlane ios beta
cd ..


echo "12. Build appbundle"
flutter build appbundle


echo "15. Run FastLane for Android"
cd ./android
fastlane android internal


