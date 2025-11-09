// ---------------------------- README (instructions) ----------------------------
// Path: train_easy_design_system/README.md
/*
How to use
1) Copy the folder `train_easy_design_system/` into the root of your Flutter repository.
2) In your app's pubspec.yaml add a path dependency:

dependencies:
  train_easy_design_system:
    path: ../train_easy_design_system

3) Run `flutter pub get`.
4) Use the theme and components:

import 'package:train_easy_design_system/train_easy_design_system.dart';

MaterialApp(
  theme: buildTrainEasyTheme(),
  home: Scaffold(...)
)

5) To run Widgetbook (dev):
  cd train_easy_design_system
  flutter pub get
  flutter run -t widgetbook/widgetbook.dart
*/