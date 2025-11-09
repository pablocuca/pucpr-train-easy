import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:train_easy_design_system/train_easy_design_system.dart';

void main() {
  runApp(const TrainEasyWidgetbook());
}

class TrainEasyWidgetbook extends StatelessWidget {
  const TrainEasyWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      // Define the component directories for Widgetbook v3.x
      directories: [
        WidgetbookCategory(
          name: 'Components',
          children: [
            WidgetbookComponent(
              name: 'PrimaryButton',
              useCases: [
                WidgetbookUseCase(
                  name: 'Filled',
                  builder: (context) => Center(
                    child: PrimaryButton(label: 'Começar', onPressed: () {}),
                  ),
                ),
                WidgetbookUseCase(
                  name: 'Outline',
                  builder: (context) => Center(
                    child: PrimaryButton(
                      label: 'Entrar',
                      onPressed: () {},
                      isFilled: false,
                    ),
                  ),
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'CardProfile',
              useCases: [
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (context) => const Center(
                    child: CardProfile(
                        name: 'Sofia', subtitle: 'Personal Trainer'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
      // Move themes into addons as Theme addon in v3.x
      addons: [
        MaterialThemeAddon(
          themes: [
            WidgetbookTheme(
                name: 'TrainEasy Dark', data: buildTrainEasyTheme()),
          ],
        ),
      ],
    );
  }
}
