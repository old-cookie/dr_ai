import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'package:dr_ai/l10n/app_localizations.dart';


/// 第四個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class GuidePageMedicalfour extends StatefulWidget {
  const GuidePageMedicalfour({super.key});

    @override
  State<GuidePageMedicalfour> createState() => _GuidePageMedicalOneState();
}

class _GuidePageMedicalOneState extends State<GuidePageMedicalfour> {
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
      title: l10n.medintroTitle4,
      description: l10n.medintroBody4,
      content: Listener(
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
        controller: _scrollController,
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/medical_light_4.png',
            width:500 ,height: 550),
            const SizedBox(height: 24),
            Text(
              l10n.medintroTitle4,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(l10n.medintroBody4, textAlign: TextAlign.left),
              )
            ],
          )
        )
      ),
      ),
    );
  }
}



