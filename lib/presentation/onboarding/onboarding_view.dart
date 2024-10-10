import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:tr_guide/presentation/onboarding/onboarding_items.dart";
import "package:tr_guide/presentation/screens/auth_page.dart";
import "package:tr_guide/utils/colors.dart";

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final controller = OnboardingItems();
  final pageController = PageController();

  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == controller.obItems.length - 1;
              });
            },
            itemCount: controller.obItems.length,
            controller: pageController,
            itemBuilder: (context, index) {
              final item = controller.obItems[index];
              return Stack(
                children: [
                  // Background Image
                  Positioned.fill(
                    child: Image.asset(
                      item.backgroundImage,
                      fit: BoxFit.cover,
                    ),
                  ),
                  // Content with background shadow
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 150),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                                0.2), // Semi-transparent background
                          ),
                          child: Column(
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 43,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.start,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.description,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: Colors.transparent, // Transparent to see the background
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: isLastPage
                  ? getStarted()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Skip button
                        TextButton(
                            onPressed: () => pageController
                                .jumpToPage(controller.obItems.length - 1),
                            child: const Text("Skip",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),

                        // Page indicators
                        SmoothPageIndicator(
                            controller: pageController,
                            count: controller.obItems.length,
                            onDotClicked: (index) =>
                                pageController.animateToPage(index,
                                    duration: const Duration(milliseconds: 200),
                                    curve: Curves.easeIn),
                            effect: const WormEffect(
                              dotHeight: 12,
                              dotWidth: 12,
                              dotColor: Color.fromARGB(96, 224, 223, 223),
                              activeDotColor: Colors.white,
                            )),

                        // Next button
                        TextButton(
                            onPressed: () => pageController.nextPage(
                                duration: const Duration(milliseconds: 200),
                                curve: Curves.easeIn),
                            child: const Text("Next",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getStarted() {
    return Container(
      decoration: const BoxDecoration(
        color: redColor,
        borderRadius: BorderRadius.all(Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 50),
      height: 65,
      child: Center(
        child: TextButton(
          child: const Text(
            "Get Started",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            final pres = await SharedPreferences.getInstance();
            pres.setBool("onboarding", true);

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const AuthPage()),
            );
          },
        ),
      ),
    );
  }
}
