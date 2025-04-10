import 'package:dr_ai/l10n/app_localizations.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_medical_1.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_medical_2.dart';
import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'screen_guide_page_2.dart';
import '../../services/service_guide.dart';
import '../../services/service_theme.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_calendar_1.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_calendar_2.dart';
import 'package:dr_ai/screens/guide/screen_guide_page_calendar_3.dart';
/// 第一個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class GuidePageOne extends StatefulWidget {
  const GuidePageOne({super.key});

  @override
  State<GuidePageOne> createState() => _GuidePageOneState();
}

class _GuidePageOneState extends State<GuidePageOne> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _onScroll() {
    if (!_autoScrolling) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _autoScrolling = false);
    }
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_scrollController.hasClients && _autoScrolling) {
        _scrollController
            .animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(seconds: 15), curve: Curves.linear)
            .then((_) => setState(() => _autoScrolling = false));
      }
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GuidePage(
      title: l10n.guideWelcomeTitle,
      description: l10n.guideWelcomeDescription,
      content: Listener(
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  themeCurrent(context) == themeLight() ? 'assets/images/ai_chat_light.png' : 'assets/images/ai_chat_dark.png',
                  width: 500,
                  height: 500,
                ),
                const SizedBox(height: 24),

                Text(l10n.guideMedicalConsultation, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(l10n.guideMedicalAssistantCapabilities, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class GuideExample extends StatelessWidget {
  const GuideExample({super.key});

  @override
  Widget build(BuildContext context) {
    return GuideFrame(
      pages: const [
        //TODO More pages can be added here
        //add GuidePageX() here
        GuidePageOne(),
        GuidePageTwo(),
        GuidePageMedicalOne(),
        GuidePageMedicaltwo(),
        GuidePageCalendarone(),
        GuidePageCalendartwo(),
        GuidePageCalendarthree()
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
}
