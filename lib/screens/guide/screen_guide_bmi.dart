import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'screen_guide_frame.dart';

/// 第六個引導頁面
/// 展示 BMI 計算功能頁面
/// 包含自動滾動功能的展示
class ScreenGuideBmi extends StatefulWidget {
  const ScreenGuideBmi({super.key});

  @override
  State<ScreenGuideBmi> createState() => _ScreenGuideBmiState();
}

class _ScreenGuideBmiState extends State<ScreenGuideBmi> {
  /// 滾動控制器
  final ScrollController _scrollController = ScrollController();

  /// 是否處於自動滾動狀態
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 頁面渲染完成後啟動自動滾動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  /// 滾動監聽回調
  /// 當滾動到底部時停止自動滾動
  void _onScroll() {
    if (!_autoScrolling) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _autoScrolling = false);
    }
  }

  /// 啟動自動滾動功能
  /// 延遲1秒後開始，滾動時間為15秒
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
    // 釋放資源
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GuidePage(
      title: l10n.optionBMI,
      description: l10n.guideWelcomeDescription,
      content: Listener(
        // 用戶觸控時停止自動滾動
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // BMI 功能圖片展示
                Image.asset('assets/images/bmi_dark.jpg', width: 500, height: 500),
                const SizedBox(height: 24),
                // BMI 功能圖標
                Icon(Icons.monitor_weight, size: 64, color: Theme.of(context).colorScheme.primary),
                const SizedBox(height: 24),
                // BMI 功能標題
                Text(l10n.bmiCalculate, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                // BMI 功能說明文字
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text(l10n.bmiFunctionDescription, textAlign: TextAlign.left, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
