import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_assets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _finishOnboarding() async {
    var prefsBox = Hive.box('prefsBox');
    await prefsBox.put('onboarding_done', true);
    if (mounted) {
      context.go('/login');
    }
  }

  final List<Map<String, dynamic>> _slides = [
    {
      'title': 'Tous tes cours en un seul endroit',
      'description': 'Accède facilement à tous tes documents académiques, même sans connexion internet.',
      'image': AppAssets.ob1,
      'isGoldTitle': false,
    },
    {
      'title': 'Tes notes en ',
      'titleAccent': 'temps réel',
      'description': 'Consulte rapidement tes résultats, moyennes et absences depuis ton téléphone.',
      'image': AppAssets.ob3,
      'isGoldAccent': true,
    },
    {
      'title': 'Accessible même hors ligne',
      'description': 'Acadify fonctionne même avec une connexion faible grâce au mode offline intelligent.',
      'image': AppAssets.ob2,
      'isGoldTitle': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Glow
          Positioned.fill(
            child: Center(
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colorScheme.primaryContainer.withValues(alpha: 0.05),
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentPage > 0)
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                            );
                          },
                        )
                      else
                        const SizedBox(width: 48),
                      TextButton(
                        onPressed: _finishOnboarding,
                        child: Text(
                          'PASSER',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Slides
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (value) => setState(() => _currentPage = value),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Illustration
                            AspectRatio(
                              aspectRatio: 0.8,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: colorScheme.onSurface.withValues(alpha: 0.1)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primaryContainer.withValues(alpha: 0.1),
                                      blurRadius: 40,
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    slide['image'],
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
                            // Title
                            if (slide['isGoldAccent'] == true)
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: AppTextStyles.displayLarge.copyWith(fontSize: 17, color: colorScheme.onSurface),
                                  children: [
                                    TextSpan(text: slide['title']),
                                    TextSpan(
                                      text: slide['titleAccent'],
                                      style: TextStyle(color: colorScheme.primary),
                                    ),
                                  ],
                                ),
                              )
                            else
                              Text(
                                slide['title'],
                                textAlign: TextAlign.center,
                                style: AppTextStyles.displayLarge.copyWith(
                                  fontSize: 17,
                                  color: slide['isGoldTitle'] == true ? colorScheme.primary : colorScheme.onSurface,
                                ),
                              ),
                            const SizedBox(height: 24),
                            // Description
                            Text(
                              slide['description'],
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Footer
                Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    children: [
                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8),
                            height: 2,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? colorScheme.primary : colorScheme.outline.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 48),
                      // Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_currentPage < _slides.length - 1) {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeIn,
                              );
                            } else {
                              _finishOnboarding();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 8,
                            shadowColor: colorScheme.primary.withValues(alpha: 0.3),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _currentPage == _slides.length - 1 ? 'COMMENCER' : 'SUIVANT',
                                style: AppTextStyles.labelMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20, color: colorScheme.onPrimary),
                            ],
                          ),
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

