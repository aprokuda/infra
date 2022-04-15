#!/bin/bash


echo "1. Make folder"
mkdir ./M-Lombard
cd ./M-Lombard


echo "2. Git Clone"
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter


echo "3. Copy key.properties"
cp ~/Documents/project/key-android/key-m-lom.properties ./android/key.properties


echo "4. Copy config Fastlane iOS"
cd ./ios
mkdir fastlane
cp ~/Documents/project/fastlane/Appfile-m-lombard ./fastlane/Appfile
cp ~/Documents/project/fastlane/Fastfile-m-lombard ./fastlane/Fastfile
#cp ~/Documents/project/fastlane/api_key_path.json api_key_path.json
cd ..

echo "5. Copy config Fastlane Android"
cd ./android
mkdir fastlane
cp ~/Documents/project/fastlane/Appfile-m-lombard-android ./fastlane/Appfile
cp ~/Documents/project/fastlane/Fastfile-m-lombard-android ./fastlane/Fastfile
cd ..

echo "6. Get date"
DateToday=$(date "+%d.%m.%Y")

echo "7. Get version number"
cd ./ios
fastlane run latest_testflight_build_number >> result_from_testflight
grep build: result_from_testflight >> result_build
buildNum=$(tail -c4 result_build)
let "buildNum += 2"
cd ..

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

gsed -i 's/applicationId "kz.mlombard.online"/applicationId "kz.mlombard"/' build.gradle
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
gsed -i -e 's!https://test-backend-01.m-lombard.kz:8000!https://backend-01.m-lombard.kz:9000!; s!13.08.2021!'$DateToday'!; s!3.0.113!3.0.'$buildNum'!' ./lib/utils/constants.dart


echo "10. Corrected AndroidManifest"
gsed -i 's/android:label="М-Онлайн">/android:label="М-Ломбард">/' ./android/app/src/main/AndroidManifest.xml


echo "11. Corrected Info.plist for iOS"
gsed -i -e 's!$(FLUTTER_BUILD_NUMBER)!'$buildNum'!; s!$(FLUTTER_BUILD_NAME)!3.0.'$buildNum'!; s!М-Онлайн!М-Ломбард!' ./ios/Runner/Info.plist


echo "12. Build appbundle"
flutter pub upgrade
flutter pub get
flutter build appbundle


echo "13. Run FastLane Android"
cd ./android
fastlane android internal
cd ..

echo "14. Run FastLane iOS"
cd ./ios
pod install
pod update
fastlane ios beta


