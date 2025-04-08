import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import '../../services/service_guide.dart';
import 'package:dr_ai/l10n/app_localizations.dart';


/// 第一個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class GuidePageMedicalOne extends StatelessWidget {
  const GuidePageMedicalOne({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GuidePage(
      title: l10n.medintroTitle1,
      description: l10n.medintroBody1,
      
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/medical_light_1.png',
            width:1080 ,height: 600),
          ],
        )
      )
    );
  }
}

// /// 示例：如何使用 GuideFrame
// /// 您可以根據需要添加更多引導頁面
// class GuideExample extends StatelessWidget {
//   const GuideExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GuideFrame(
      pages: const [        
        GuidePageMedicalOne(),
      ],
      onFinish: () async {
        await GuideService.markGuideShown();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
      onSkip: () async {
        await GuideService.markGuideShown();
        if (context.mounted) {
          Navigator.of(context).pushReplacementNamed('/');
        }
      },
    );
  }

