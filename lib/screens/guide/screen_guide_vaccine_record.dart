import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import '../../../l10n/app_localizations.dart';

/// 第五個引導頁面
/// 展示疫苗記錄功能頁面
/// 具有自動滾動展示內容的功能
class ScreenGuideVaccineRecord extends StatefulWidget {
  const ScreenGuideVaccineRecord({super.key});

  @override
  State<ScreenGuideVaccineRecord> createState() => _GuidePageFiveState();
}

class _GuidePageFiveState extends State<ScreenGuideVaccineRecord> {
  /// 滾動控制器，用於控制頁面的自動滾動
  final ScrollController _scrollController = ScrollController();

  /// 是否正在自動滾動
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  /// 滾動監聽器回調
  /// 當滾動到底部時停止自動滾動
  void _onScroll() {
    if (!_autoScrolling) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _autoScrolling = false);
    }
  }

  /// 開始自動滾動
  /// 延遲1秒後開始，15秒內滾動到底部
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return; // 檢查元件是否仍在樹中
      if (_scrollController.hasClients && _autoScrolling) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(seconds: 15), curve: Curves.linear).then((
          _,
        ) {
          if (!mounted) return; // 檢查元件是否仍在樹中
          setState(() => _autoScrolling = false);
        });
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
                // 疫苗記錄圖片
                Image.asset('assets/images/vaccine_record_dark.jpg', width: 500, height: 500),
                const SizedBox(height: 24),
                // 疫苗圖標
                Icon(Icons.vaccines_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                // 疫苗添加標題
                Text(l10n.vaccineAddTitle, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                // 疫苗記錄好處描述
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(l10n.guideVaccineRecordBenefits, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
