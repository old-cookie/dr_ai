import 'package:flutter/material.dart';
import 'screen_guide_frame.dart';

/// 第二個引導頁面
/// 展示頁面跳轉示例
class GuidePageTwo extends StatelessWidget {
  const GuidePageTwo({super.key});

  @override
  Widget build(BuildContext context) {
    return GuidePage(
      //Sample Title
      title: "Title",

      //Sample Description
      description: "Description",

      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Sample Iamge
            Image.asset('assets/logo512_light.png', width: 128, height: 128),

            //Sample Icon
            const SizedBox(height: 24),
            Icon(Icons.navigation, size: 64, color: Theme.of(context).colorScheme.primary),

            //Sample Subitle
            const SizedBox(height: 24),
            Text("Sample Subitle", style: Theme.of(context).textTheme.headlineMedium),

            //Sample Subescription
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.0),
              child: Text("""
Sample Subescription
                """, textAlign: TextAlign.left),
            ),
          ],
        ),
      ),
    );
  }
}
