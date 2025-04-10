import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'package:dr_ai/l10n/app_localizations.dart';

/// 第三個日曆引導頁面
/// 展示如何使用 Calendar 功能的進階設置
class ScreenGuideCalendarAddEdit extends StatefulWidget {
  const ScreenGuideCalendarAddEdit({super.key});

  @override
  State<ScreenGuideCalendarAddEdit> createState() => _ScreenGuideCalendarAddEditState();
}

class _ScreenGuideCalendarAddEditState extends State<ScreenGuideCalendarAddEdit> {
  // 滾動控制器，用於控制頁面的滾動
  final ScrollController _scrollController = ScrollController();
  // 是否處於自動滾動狀態
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    // 添加滾動監聽
    _scrollController.addListener(_onScroll);
    // 頁面渲染完成後開始自動滾動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // 滾動監聽回調，檢測是否滾動到底部
  void _onScroll() {
    if (!_autoScrolling) return;

    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _autoScrolling = false);
    }
  }

  // 開始自動滾動頁面
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
      title: l10n.guidecalendarTitle3,
      description: l10n.guidecalendarBody3,
      // 內容區域：包含圖片和描述文字
      content: Listener(
        // 當用戶觸摸屏幕時停止自動滾動
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 第一個日曆功能示例圖片
                Image.asset('assets/images/calendar_add_light.jpg', width: 500, height: 500),
                // 第二個日曆功能示例圖片
                Image.asset('assets/images/calendar_edit_light.jpg', width: 500, height: 500),

                // 間隔元件
                const SizedBox(height: 16),
                // 日曆功能描述文字
                Padding(padding: const EdgeInsets.symmetric(horizontal: 32.0), child: Text(l10n.guidecalendarBody3, textAlign: TextAlign.left)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
