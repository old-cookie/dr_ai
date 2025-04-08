import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';
import 'screen_guide_page_2.dart';
import '../../services/service_guide.dart';

/// 第一個引導頁面
/// 展示如何使用 GuidePage 組件創建引導頁面
class GuidePageOne extends StatelessWidget {
  const GuidePageOne({super.key});

  @override
  Widget build(BuildContext context) {
    return GuidePage(
      title: "歡迎使用",
      description: "這是一個示例引導頁面，展示如何使用引導框架",
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.waving_hand,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              "自定義您的引導內容",
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                "在這裡添加圖片、文字或任何其他 Widget 來創建豐富的引導體驗",
                textAlign: TextAlign.center,
              ),
            ),
          ],
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
