import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import '../../../l10n/app_localizations.dart';

/// 第二個引導頁面
/// 展示頁面跳轉示例
class GuidePageThree extends StatelessWidget {
  const GuidePageThree({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GuidePage(
      title: l10n.vaccineRecordTitle,
      description: l10n.guideWelcomeDescription,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/dr.ai_vaccine record.png',
              width: 128,
              height: 128,
            ),
            const SizedBox(height: 24),
            Icon(
              Icons.vaccines_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
             l10n.vaccineAddTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                l10n.guideVaccineRecordBenefits,
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