import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:tr_guide/presentation/onboarding/onboarding_items.dart";

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
          itemCount: controller.obItems.length,
          controller: pageController,
          itemBuilder: (context, index) {

            //
            
          }),
    );
  }
}
