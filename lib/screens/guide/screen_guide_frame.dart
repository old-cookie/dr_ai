import 'package:flutter/material.dart';
import '../../widgets/widgets_units/widget_button.dart';
import 'package:dr_ai/l10n/app_localizations.dart';

// ==========================================================================
// 用戶引導框架相關組件
// ==========================================================================

/// 用戶引導框架組件
/// 提供可滑動的引導頁面，包含導航按鈕和頁面指示器
/// @param pages 引導頁面列表
/// @param onFinish 完成回調
/// @param onSkip 跳過回調
class GuideFrame extends StatefulWidget {
  final List<Widget> pages;
  final Function()? onFinish;
  final Function()? onSkip;

  const GuideFrame({super.key, required this.pages, this.onFinish, this.onSkip});

  @override
  State<GuideFrame> createState() => _GuideFrameState();
}

class _GuideFrameState extends State<GuideFrame> {
  late PageController _pageController;
  int _currentPage = 0;
  // 移除全局滾動控制器，每個頁面使用自己的控制器
  // final ScrollController _scrollController = ScrollController();
  bool _autoScrolling = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  void _resetScroll() {
    // 僅通知頁面重置滾動狀態，而不直接控制滾動
    setState(() => _autoScrolling = true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ==========================================================================
  // 頁面導航控制
  // ==========================================================================

  void _nextPage() {
    if (!mounted) return;
    try {
      if (_currentPage < widget.pages.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        // 重置滾動狀態
        _resetScroll();
      } else {
        widget.onFinish?.call();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("導航錯誤：$e")));
    }
  }

  void _previousPage() {
    if (!mounted) return;
    try {
      if (_currentPage > 0) {
        _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        // 重置滾動狀態
        _resetScroll();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("導航錯誤：$e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (widget.onSkip != null)
            SizedBox(width: 100, child: widgetButton(l10n.skip, Icons.skip_next, widget.onSkip, color: theme.colorScheme.primary)),
        ],
      ),
      body: Column(
        children: [
          // ==========================================================================
          // 頁面內容區域
          // ==========================================================================
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  // 重置滾動狀態
                  _resetScroll();
                });
              },
              children:
                  widget.pages.map((page) {
                    if (page is GuidePage) {
                      // 將滾動控制器傳遞給 GuidePage
                      return GuidePage(
                        title: page.title,
                        description: page.description,
                        content: page.content,
                        scrollController: page.scrollController,
                        autoScrolling: _autoScrolling,
                        onPointerDown: () => setState(() => _autoScrolling = false),
                      );
                    }
                    return page;
                  }).toList(),
            ),
          ),
          // ==========================================================================
          // 導航控制區域
          // ==========================================================================
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // 頁面指示器
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:
                      widget.pages.isEmpty
                          ? []
                          : List.generate(widget.pages.length, (index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              height: 8.0,
                              width: 8.0,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPage == index ? theme.colorScheme.primary : theme.colorScheme.primary.withAlpha(77), // 0.3 * 255 ≈ 77
                              ),
                            );
                          }),
                ),
                const SizedBox(height: 16.0),
                // 導航按鈕
                Container(
                  constraints: const BoxConstraints(maxWidth: 300), // 限制最大寬度
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120, // 固定寬度
                        child:
                            _currentPage > 0
                                ? widgetButton(l10n.previous, Icons.arrow_back, _previousPage, color: theme.colorScheme.primary)
                                : const SizedBox(width: 100),
                      ),
                      SizedBox(
                        width: 100, // 固定寬度
                        child: widgetButton(
                          _currentPage == widget.pages.length - 1 ? l10n.finish : l10n.next,
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

// ==========================================================================
// 引導頁面組件
// ==========================================================================

/// 引導頁面基礎組件
/// 用於創建一致風格的引導頁面
/// @param title 頁面標題
/// @param description 頁面描述
/// @param content 頁面內容
class GuidePage extends StatefulWidget {
  final String title;
  final String description;
  final Widget content;
  final ScrollController? scrollController;
  final bool? autoScrolling;
  final VoidCallback? onPointerDown;

  const GuidePage({
    super.key,
    required this.title,
    required this.description,
    required this.content,
    this.scrollController,
    this.autoScrolling,
    this.onPointerDown,
  });

  @override
  State<GuidePage> createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  ScrollController? _scrollController;
  
  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    // 添加後置幀回調以確保在佈局完成後進行滾動
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoScrollToTop();
    });
  }
  
  @override
  void didUpdateWidget(GuidePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 當 autoScrolling 狀態改變時執行自動滾動
    if (widget.autoScrolling != oldWidget.autoScrolling && widget.autoScrolling == true) {
      _autoScrollToTop();
    }
  }
  
  void _autoScrollToTop() {
    // 只有在啟用自動滾動且滾動控制器已附加時才執行滾動
    if ((widget.autoScrolling ?? false) && _scrollController != null && _scrollController!.hasClients) {
      _scrollController!.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // 只有在內部創建的控制器才需要釋放
    if (widget.scrollController == null) {
      _scrollController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 確保內容可滾動
    Widget contentWidget = widget.content;
    if (contentWidget is! ScrollView) {
      contentWidget = Listener(
        onPointerDown: (_) => widget.onPointerDown?.call(),
        child: SingleChildScrollView(
          controller: _scrollController,
          child: contentWidget,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surface.withAlpha((0.8 * 255).round())],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                widget.description,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.secondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              Expanded(child: contentWidget),
            ],
          ),
        ),
      ),
    );
  }
}
