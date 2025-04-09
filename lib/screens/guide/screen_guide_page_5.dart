import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import '../../../l10n/app_localizations.dart';

/// 第二個引導頁面
/// 展示頁面跳轉示例
class GuidePageFive extends StatefulWidget {
  const GuidePageFive({super.key});

  @override
  State<GuidePageFive> createState() => _GuidePageFiveState();
}

class _GuidePageFiveState extends State<GuidePageFive> {
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
      title: l10n.vaccineRecordTitle,
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
                  'assets/images/dr.ai_vaccine record.jpg',
                  width: 500,
                  height: 500,
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
        ),
      ),
    );
  }
}