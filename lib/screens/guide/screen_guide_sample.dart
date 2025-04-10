import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';

/// 第二個引導頁面
/// 展示頁面跳轉示例
class ScreenGuideSample extends StatefulWidget {
  const ScreenGuideSample({super.key});

  @override
  State<ScreenGuideSample> createState() => _ScreenGuideSampleState();
}

class _ScreenGuideSampleState extends State<ScreenGuideSample> {
  // 滾動控制器，用於管理頁面的自動滾動行為
  final ScrollController _scrollController = ScrollController();
  // 是否處於自動滾動狀態
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    // 添加滾動監聽器
    _scrollController.addListener(_onScroll);
    // 第一幀渲染完成後執行自動滾動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  // 滾動事件處理
  void _onScroll() {
    if (!_autoScrolling) return;

    // 當滾動到底部時停止自動滾動
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      setState(() => _autoScrolling = false);
    }
  }

  // 啟動自動滾動功能
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
    // 清理資源，避免記憶體洩漏
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GuidePage(
      //Sample Title - 頁面主標題
      title: "Title",

      //Sample Description - 頁面描述文字
      description: "Description",

      // 主要內容區域
      content: Listener(
        // 當用戶觸摸螢幕時停止自動滾動
        onPointerDown: (_) => setState(() => _autoScrolling = false),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Sample Image - 示例圖片展示
                Image.asset('assets/logo512_light.png', width: 128, height: 128),

                //Sample Icon - 示例圖標展示
                const SizedBox(height: 24),
                Icon(Icons.navigation, size: 64, color: Theme.of(context).colorScheme.primary),

                //Sample Subtitle - 子標題示例
                const SizedBox(height: 24),
                Text("Sample Subitle", style: Theme.of(context).textTheme.headlineMedium),

                //Sample Subescription - 子描述文字區塊
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Text("""
Sample Subescription
                    """, textAlign: TextAlign.left),
                ),

                // 額外的空間，確保內容不會緊貼底部
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
