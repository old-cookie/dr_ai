import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'screen_guide_frame.dart';

/// 第四個引導頁面
/// 展示頁面跳轉示例
class GuidePageSix extends StatelessWidget {
  const GuidePageSix({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GuidePage(
      title: l10n.optionBMI,
      description: l10n.guideWelcomeDescription,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/dr_ai_BMI.jpg',
              width: 128,
              height: 128,
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.monitor_weight,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.bmiCalculate,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                l10n.bmiFunctionDescription,
                textAlign: TextAlign.left,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
