import 'package:flutter/material.dart';
import '../../widgets/widgets_units/widget_button.dart';
import '../../widgets/widgets_units/widget_title.dart';

/// 用戶引導框架組件
/// 提供可滑動的引導頁面，包含導航按鈕和頁面指示器
/// @param pages 引導頁面列表
/// @param onFinish 完成回調
/// @param onSkip 跳過回調
class GuideFrame extends StatefulWidget {
  final List<Widget> pages;
  final Function()? onFinish;
  final Function()? onSkip;

  const GuideFrame({
    super.key,
    required this.pages,
    this.onFinish,
    this.onSkip,
  });

  @override
  State<GuideFrame> createState() => _GuideFrameState();
}

class _GuideFrameState extends State<GuideFrame> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (!mounted) return;
    try {
      if (_currentPage < widget.pages.length - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        widget.onFinish?.call();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("導航錯誤：$e")),
      );
    }
  }

  void _previousPage() {
    if (!mounted) return;
    try {
      if (_currentPage > 0) {
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("導航錯誤：$e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.onSkip != null)
            SizedBox(
              width: 100,
              child: widgetButton(
                "Skip",
                Icons.skip_next,
                widget.onSkip,
                color: theme.colorScheme.primary,
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: widget.pages,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: widget.pages.isEmpty 
                      ? [] 
                      : List.generate(widget.pages.length, (index) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4.0),
                            height: 8.0,
                            width: 8.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                                color: _currentPage == index
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.primary.withAlpha(77), // 0.3 * 255 ≈ 77
                            ),
                          );
                        }),
                ),
                const SizedBox(height: 16.0),
                // Navigation buttons
                Container(
                  constraints: const BoxConstraints(maxWidth: 300), // 限制最大寬度
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 100,  // 固定寬度
                        child: _currentPage > 0
                            ? widgetButton(
                                "Previous",
                                Icons.arrow_back,
                                _previousPage,
                                color: theme.colorScheme.primary,
                              )
                            : const SizedBox(width: 100),
                      ),
                      SizedBox(
                        width: 100,  // 固定寬度
                        child: widgetButton(
                          _currentPage == widget.pages.length - 1 ? "Finish" : "Next",
                          Icons.arrow_forward,
                          _nextPage,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 引導頁面基礎組件
/// 用於創建一致風格的引導頁面
/// @param title 頁面標題
/// @param description 頁面描述
/// @param content 頁面內容
class GuidePage extends StatelessWidget {
  final String title;
  final String description;
  final Widget content;

  const GuidePage({
    super.key,
    required this.title,
    required this.description,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widgetTitle(title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: 24.0),
          Expanded(child: content),
        ],
      ),
    );
  }
}
