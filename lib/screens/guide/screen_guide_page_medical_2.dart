import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'package:dr_ai/l10n/app_localizations.dart';


/// 第一個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class GuidePageMedicaltwo extends StatelessWidget {
  const GuidePageMedicaltwo({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return GuidePage(
      title: l10n.medintroTitle2,
      description: l10n.medintroBody2,
      
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/medical_light_2.png',
            width:500 ,height: 550),
          ],
        )
      )
    );
  }
}



