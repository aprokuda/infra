#!/bin/bash


echo "2. Get version number"
cd ./deploy-version/Get-folder-M-Online/ios
rm -r result_from_testflight
rm -r result_build
fastlane run latest_testflight_build_number >> result_from_testflight
grep build: result_from_testflight >> result_build
buildNum=$(tail -c4 result_build)
let "buildNum += 2"


