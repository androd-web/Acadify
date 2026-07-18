 import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── Controllers ──────────────────────────────────────────
  late AnimationController _scanCtrl;
  late AnimationController _logoCtrl;
  late AnimationController _lettersCtrl;
  late AnimationController _taglineCtrl;
  late AnimationController _barCtrl;

  // ── Animations ───────────────────────────────────────────
  late Animation<double> _scanPos;
  late Animation<double> _scanOpacity;

  late Animation<double> _logoScale;
  late Animation<double> _logoRotation;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoGlow;

  late List<Animation<double>> _letterOpacities;
  late List<Animation<double>> _letterSlides;

  late Animation<double> _taglineOpacity;
  late Animation<double> _barProgress;
  late Animation<double> _barOpacity;

  final String _appName = "Acadify";

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {

    // ── 1. Scan line ─────────────────────────────────────
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scanPos = Tween<double>(begin: -0.02, end: 1.05).animate(
      CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut),
    );
    _scanOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 0.9), weight: 10),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.9), weight: 75),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 0.0), weight: 15),
    ]).animate(_scanCtrl);

    // ── 2. Logo ──────────────────────────────────────────
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const ElasticOutCurve(0.7),
      ),
    );
    _logoRotation = Tween<double>(begin: -0.26, end: 0.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );
    _logoGlow = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoCtrl,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );

    // ── 3. Lettres ───────────────────────────────────────
    final offsets = [0, 100, 195, 285, 365, 440, 510];
    final totalLetterDur = 650 + offsets.last;

    _lettersCtrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalLetterDur),
    );

    _letterOpacities = [];
    _letterSlides    = [];

    for (int i = 0; i < _appName.length; i++) {
      final start = offsets[i] / totalLetterDur;
      final end   = (offsets[i] + 450) / totalLetterDur;

      _letterOpacities.add(
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _lettersCtrl,
            curve: Interval(
              start,
              end.clamp(0.0, 1.0),
              curve: Curves.easeIn,
            ),
          ),
        ),
      );
      _letterSlides.add(
        Tween<double>(begin: 20.0, end: 0.0).animate(
          CurvedAnimation(
            parent: _lettersCtrl,
            curve: Interval(
              start,
              end.clamp(0.0, 1.0),
              curve: const ElasticOutCurve(0.8),
            ),
          ),
        ),
      );
    }

    // ── 4. Tagline ───────────────────────────────────────
    _taglineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineCtrl, curve: Curves.easeIn),
    );

    // ── 5. Barre de progression ──────────────────────────
    _barCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );
    _barProgress = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 0.75)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.75, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_barCtrl);

    _barOpacity = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 5),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 88),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 7),
    ]).animate(_barCtrl);
  }

  // ════════════════════════════════════════════════════════
  //  SÉQUENCE D'ANIMATION + NAVIGATION (logique originale)
  // ════════════════════════════════════════════════════════
  Future<void> _startSequence() async {

    // Phase 1 — Scan
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    _scanCtrl.forward();

    // Phase 2 — Logo
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    _logoCtrl.forward();

    // Phase 3 — Lettres
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    _lettersCtrl.forward();

    // Phase 4 — Tagline
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _taglineCtrl.forward();

    // Phase 5 — Barre
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _barCtrl.forward();

    // Attendre la fin de la barre + petit délai final
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    // ── Logique de navigation originale ──────────────────
    final prefsBox = Hive.box('prefsBox');
    final bool onboardingDone =
        prefsBox.get('onboarding_done', defaultValue: false);

    if (!onboardingDone) {
      context.go('/onboarding');
      return;
    }

    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      context.go('/login');
      return;
    }

    final userBox = Hive.box('userBox');
    final String? role = userBox.get('role');

    switch (role) {
      case 'student':
        context.go('/student-dashboard');
        break;
      case 'teacher':
        context.go('/teacher-dashboard');
        break;
      case 'admin':
        context.go('/admin-dashboard');
        break;
      default:
        context.go('/login');
    }
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _logoCtrl.dispose();
    _lettersCtrl.dispose();
    _taglineCtrl.dispose();
    _barCtrl.dispose();
    super.dispose();
  }

  // ════════════════════════════════════════════════════════
  //  BUILD
  // ════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          // ── Lueur radiale centrale ───────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 0.8,
                  colors: [
                    Color(0x380B6E4F),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ── Scan line ────────────────────────────────────
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, child) => Positioned(
              top: size.height * _scanPos.value,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: _scanOpacity.value,
                child: Container(
                  height: 1.5,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Color(0x990B6E4F),
                        Color(0x9922AA7A),
                        Color(0x990B6E4F),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Contenu central ──────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── Logo ─────────────────────────────────
                AnimatedBuilder(
                  animation: _logoCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _logoOpacity.value,
                    child: Transform.rotate(
                      angle: _logoRotation.value,
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.55 * _logoGlow.value),
                                blurRadius: 45,
                                spreadRadius: 2,
                              ),
                              BoxShadow(
                                color: AppColors.primaryContainer
                                    .withValues(alpha: 0.18 * _logoGlow.value),
                                blurRadius: 90,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                          // ── Ton logo image ───────────────
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              AppAssets.logo,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // ── Nom "Acadify" lettre par lettre ──────
                AnimatedBuilder(
                  animation: _lettersCtrl,
                  builder: (_, child) => Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: List.generate(_appName.length, (i) {
                      return Opacity(
                        opacity: _letterOpacities[i].value,
                        child: Transform.translate(
                          offset: Offset(0, _letterSlides[i].value),
                          child: Text(
                            _appName[i],
                            style: GoogleFonts.inter(
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              letterSpacing: -1.5,
                              color: i == 0
                                  ? const Color(0xFF22AA7A)
                                  : Colors.white,
                              shadows: [
                                Shadow(
                                  color: i == 0
                                      ? const Color(0xFF22AA7A)
                                          .withValues(alpha: 0.7)
                                      : Colors.white.withValues(alpha: 0.1),
                                  blurRadius: i == 0 ? 30 : 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 12),

                // ── Tagline ──────────────────────────────
                FadeTransition(
                  opacity: _taglineOpacity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _dot(),
                      const SizedBox(width: 8),
                      Text(
                        'UIECC · Sangmélima',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 2.2,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                      const SizedBox(width: 8),
                      _dot(),
                    ],
                  ),
                ),

                const SizedBox(height: 44),

                // ── Barre de progression ─────────────────
                AnimatedBuilder(
                  animation: _barCtrl,
                  builder: (_, child) => Opacity(
                    opacity: _barOpacity.value,
                    child: Column(
                      children: [
                        Container(
                          width: 140,
                          height: 2,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _barProgress.value,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF0B6E4F),
                                    Color(0xFF22AA7A),
                                    Color(0xFFE8A317),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_barProgress.value * 100).round()}%',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.2,
                            color: Colors.white.withValues(alpha: 0.25),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              ],
            ),
          ),

        ],
      ),
    );
  }

  Widget _dot() => Container(
    width: 3,
    height: 3,
    decoration: const BoxDecoration(
      shape: BoxShape.circle,
      color: Color(0xFFE8A317),
    ),
  );
}