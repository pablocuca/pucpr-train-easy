#!/usr/bin/env bash
set -euo pipefail
dart run flutter_launcher_icons
flutter clean
rm -rf ios/Pods ios/.symlinks ios/Podfile.lock ios/Flutter/Flutter.framework ios/Flutter/Flutter.podspec
flutter pub get
(cd ios && pod install)
flutter analyze
if [ "${1:-run}" = "run" ]; then
  flutter run
else
  flutter build ios --debug
fi