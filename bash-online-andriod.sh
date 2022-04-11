#!/bin/bash
echo "1. Make folder"
mkdir M-Online-android
cd ./M-Online-android


echo "2. Git Clone"
git clone git@github.com:m-lombard/front-flutter.git
cd ./front-flutter

echo "3. Copy config Fastlane"
cd ./ios
mkdir fastlane
cd ./fastlane
cp ~/Documents/project/fastlane/Appfile-m-online Appfile
cp ~/Documents/project/fastlane/Fastfile-m-online Fastfile
#cp ~/Documents/project/fastlane/api_key_path.json api_key_path.json
cd ..

echo "4. Get version number"
fastlane run latest_testflight_build_number >> result
grep build: result >> result1
buildNum=$(tail -c4 result1)
let "buildNum += 2"
cd ..


echo "5. Copy key.properties"
cp ~/Documents/project/key-android/key.properties ./android/key.properties


echo "6. build.gradle corrected"
cd ./android/app
gsed -i '/android {/i def keystoreProperties = new Properties()' build.gradle
gsed -i '/android {/i def keystorePropertiesFile = rootProject.file('key.properties')' build.gradle 
gsed -i '/android {/i if (keystorePropertiesFile.exists()) {' build.gradle
gsed -i '/android {/i keystoreProperties.load(new FileInputStream(keystorePropertiesFile))' build.gradle
gsed -i 's/keystoreProperties.load(new FileInputStream(keystorePropertiesFile))/     keystoreProperties.load(new FileInputStream(keystorePropertiesFile))/' build.gradle
gsed -i '/android {/i }' build.gradle
gsed -i '/android {/i changestring' build.gradle
gsed -i 's/changestring//' build.gradle

gsed -i 's/kz.mlombard.online/kz.mlombard/' build.gradle
gsed -i 's/versionCode flutterVersionCode.toInteger()/versionCode '$buildNum'/' build.gradle
gsed -i 's/versionName flutterVersionName/versionName "3.0.'$buildNum'"/' build.gradle

gsed -i '/buildTypes {/i signingConfigs {' build.gradle
gsed -i '/buildTypes {/i release {' build.gradle
gsed -i '/buildTypes {/i keyAlias keystoreProperties['keyAlias']' build.gradle
gsed -i '/buildTypes {/i keyPassword keystoreProperties['keyPassword']' build.gradle
gsed -i '/buildTypes {/i storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null' build.gradle
gsed -i '/buildTypes {/i storePassword keystoreProperties['storePassword']' build.gradle
gsed -i '/buildTypes {/i }' build.gradle
gsed -i '/buildTypes {/i }' build.gradle

gsed -i 's/signingConfig signingConfigs.debug/signingConfig signingConfigs.release/' build.gradle
cd ../..

echo "7. Install and update pub" 
flutter pub upgrade

echo "8. Build appbundle"
flutter build appbundle


#echo "9. Run FastLane"
#fastlane ios beta

 
