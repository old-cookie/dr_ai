import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'package:dr_ai/l10n/app_localizations.dart';

/// 第一個引導頁面
/// 展示如何使用 Calendar 功能介紹
class GuidePageCalendarone extends StatefulWidget {
  const GuidePageCalendarone({super.key});

  @override
  State<GuidePageCalendarone> createState() => _GuidePageCalendaroneState();
}

class _GuidePageCalendaroneState extends State<GuidePageCalendarone> {
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
      title: l10n.guidecalendarTitle1,
      description: l10n.guidecalendarBody1,
      content: Listener(
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
          controller: _scrollController,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Sample Image
            Image.asset('assets/images/Calendar_1.jpg', width: 500, height: 500),

            // Sample Subdescription
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(l10n.guidecalendarBody1, textAlign: TextAlign.left),
            ),
          ],
        ),
      ),
    ),
    ),
    );
  }
}



