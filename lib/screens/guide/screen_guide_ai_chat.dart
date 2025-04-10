import 'package:dr_ai/l10n/app_localizations.dart';
import 'package:dr_ai/screens/guide/screen_guide_vaccine_record.dart';
import 'package:dr_ai/screens/guide/screen_guide_medical_certificate.dart';
import 'package:dr_ai/screens/guide/screen_guide_medical_certificate_add.dart';
import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
//import 'screen_guide_sample.dart';
import 'screen_guide_bmi.dart';
import '../../services/service_guide.dart';
import '../../services/service_theme.dart';
import 'package:dr_ai/screens/guide/screen_guide_calendar.dart';
import 'package:dr_ai/screens/guide/screen_guide_calendar_list.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_medical_3.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_medical_4.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_medical_5.dart';
import 'package:dr_ai/screens/guide/screen_guide_calendar_add_edit.dart';

/// 第一個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class ScreenGuideAiChat extends StatefulWidget {
  const ScreenGuideAiChat({super.key});

  @override
  State<ScreenGuideAiChat> createState() => _ScreenGuideAiChatState();
}

class _ScreenGuideAiChatState extends State<ScreenGuideAiChat> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    // 計算適合的圖片尺寸，最大不超過螢幕高度的40%
    final imageSize = screenSize.height * 0.4;

    return GuidePage(
      title: l10n.guideWelcomeTitle,
      description: l10n.guideWelcomeDescription,
      scrollController: _scrollController,
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              themeCurrent(context) == themeLight() ? 'assets/images/ai_chat_light.png' : 'assets/images/ai_chat_dark.png',
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),

            Text(l10n.guideMedicalConsultation, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(l10n.guideMedicalAssistantCapabilities, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
            ),
            // 底部增加額外的空間以確保內容可以完全滾動
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class GuideExample extends StatelessWidget {
  const GuideExample({super.key});

  @override
  Widget build(BuildContext context) {
    // 引導頁面順序在這裡定義，可以根據需要調整順序
    // 順序規則：
    // 1. 先顯示基本介紹頁面
    // 2. 依功能分組展示（醫療功能、疫苗記錄、BMI、日曆功能）
    final List<Widget> orderedPages = const [
      ScreenGuideAiChat(), // 歡迎/基本介紹頁面
      //ScreenGuideSample(),     // 功能示範頁面
      // 醫療功能頁面組
      ScreenGuideMedicalCertificate(),
      ScreenGuideMedicalCertificateAdd(),
      GuidePageMedicalthree(),
      GuidePageMedicalfour(),
      GuidePageMedicalfive(),
      // 健康記錄功能頁面組
      ScreenGuideVaccineRecord(), // 疫苗記錄頁面
      ScreenGuideBmi(), // BMI計算頁面
      // 日曆功能頁面組
      ScreenGuideCalendar(), // 日曆功能介紹1
      ScreenGuideCalendarList(), // 日曆功能介紹2
      ScreenGuideCalendarAddEdit(), // 日曆功能介紹3
    ];

    return GuideFrame(
      pages: orderedPages,
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
}
