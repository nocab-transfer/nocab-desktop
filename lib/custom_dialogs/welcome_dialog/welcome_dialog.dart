import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/network_adapter_info_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/nocab_mobile_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/use_instructions.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/welcome_page.dart';
import 'package:nocab_desktop/custom_dialogs/welcome_dialog/pages/you_are_ready_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class WelcomeDialog extends StatefulWidget {
  final bool createdFromMain;
  final List<Widget>? overridePages;
  const WelcomeDialog({Key? key, this.createdFromMain = false, this.overridePages}) : super(key: key);

  @override
  State<WelcomeDialog> createState() => _WelcomeDialogState();
}

class _WelcomeDialogState extends State<WelcomeDialog> {
  final PageController _pageController = PageController();

  int currentPage = 0;
  late List<Widget> pages;
  @override
  void initState() {
    super.initState();
    pages = widget.overridePages ??
        [
          const WelcomePage(),
          const NoCabMobilePage(),
          const NetworkAdapterInfoPage(),
          const UseInstructions(),
          const YouAreReadyPage(),
        ];
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: WillPopScope(
          onWillPop: () async => !widget.createdFromMain,
          child: Dialog(
            clipBehavior: Clip.antiAlias,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(64),
            child: Container(
              width: 600,
              height: 400,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Stack(
                children: [
                  PageView(
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (value) => setState(() => currentPage = value),
                    controller: _pageController,
                    scrollDirection: Axis.horizontal,
                    children: pages,
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: SmoothPageIndicator(
                        controller: _pageController,
                        count: pages.length,
                        onDotClicked: (index) => _pageController.animateToPage(index, duration: Duration(milliseconds: (currentPage - index).abs() > 2 ? 500 : 300), curve: Curves.easeInOut),
                        effect: WormEffect(
                          dotHeight: 8,
                          dotWidth: 16,
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context).colorScheme.primary.withOpacity(.2),
                          spacing: 16,
                          strokeWidth: 8,
                          paintStyle: PaintingStyle.stroke,
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () => currentPage == pages.length - 1 ? Navigator.pop(context) : _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease),
                        style: ElevatedButton.styleFrom(
                          fixedSize: const Size(150, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                        ),
                        child: Text(currentPage == pages.length - 1 ? "welcomeDialog.finishButton".tr() : "welcomeDialog.nextButton".tr()),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
}
