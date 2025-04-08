import 'package:dr_ai/screens/medical_certificate/screen_add_medical_certificate.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dr_ai/l10n/app_localizations.dart'; // Import localization
// Import the screen to navigate to

class ScreenIntroduction extends StatelessWidget {
  const ScreenIntroduction({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0, 
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
      ),
      bodyTextStyle: const TextStyle(fontSize: 18.0),
      bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Theme.of(context).scaffoldBackgroundColor,
      imagePadding: EdgeInsets.zero,
    );

    return IntroductionScreen(
      globalBackgroundColor: Theme.of(context).scaffoldBackgroundColor,
      pages: [
        PageViewModel(
          title: l10n.medintroTitle1 ?? "Welcome to Medical Certificate",
          body: l10n.medintroBody1 ?? "Your personal health management assistant",
          image: Image.asset('assets/images/firstpage.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.medintroTitle2 ?? "Medical Certificates",
          body: l10n.medintroBody2 ?? "Easily manage and store all your medical certificates in one place",
          image: Image.asset('assets/images/secondpage.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.medintroTitle3 ?? "Secure Storage",
          body: l10n.medintroBody3 ?? "Your medical data is securely encrypted and stored only on your device",
          image: Image.asset('assets/images/thirdpage.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.medintroTitle4 ?? "",
          body: l10n.medintroBody4 ?? "Let's get started with your first medical certificate!",
          image: Image.asset('assets/images/fourthpage.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: l10n.medintroTitle5 ?? "Get Started",
          body: l10n.medintroBody5 ?? "Tap the button below to begin your journey",
          image: Image.asset('assets/images/fifthpage.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      skip: Text(l10n.skip ?? 'Skip'),
      next: Icon(Icons.arrow_forward),
      done: Text(
        l10n.done ?? 'Done', 
        style: const TextStyle(fontWeight: FontWeight.w600)
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
    );
  }

  void _onIntroEnd(BuildContext context) async {
    // Save that the user has seen the intro
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_intro', true);
    
    // Navigate to medical certificate screen instead of home screen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ScreenAddMedicalCertificate()),
    );
  }
}
