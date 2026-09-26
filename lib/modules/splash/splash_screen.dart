
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:taskpro/modules/splash/splash_controller.dart';
import 'package:taskpro/theme/app_colors.dart';

// Note: Replace these imports with your project's actual path if needed:
// import 'package:taskpro/theme/app_colors.dart';
// import 'splash_controller.dart';

/// Main Splash Screen Widget integrated with GetX SplashController
class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {


    // Set immersive status bar style for a modern edge-to-edge feel
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: const Stack(
        children: [
          // Ambient background decorative glow circles
          Positioned.fill(
            child: AmbientBackground(),
          ),

          // Core animated UI Content
          SafeArea(
            child: SplashAnimatedBody(),
          ),
        ],
      ),
    );
  }
}

/// Animated body class handling staggered entrance & ambient pulsing animations
class SplashAnimatedBody extends StatefulWidget {
  const SplashAnimatedBody({super.key});

  @override
  State<SplashAnimatedBody> createState() => _SplashAnimatedBodyState();
}

class _SplashAnimatedBodyState extends State<SplashAnimatedBody>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;

  // Staggered Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _textOpacity;
  late Animation<double> _loaderOpacity;

  @override
  void initState() {
    super.initState();

    // Main entrance controller
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Continuous subtle pulse animation for logo and dynamic effects
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // 1. Logo Scale & Fade-in (0.0 -> 0.5)
    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Text Slide & Fade-in (0.35 -> 0.75)
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Interval(0.35, 0.75, curve: Curves.easeOutCubic),
      ),
    );

    _textOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.35, 0.75, curve: Curves.easeIn),
      ),
    );

    // 3. Loader & Footer Fade-in (0.6 -> 1.0)
    _loaderOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(0.6, 1.0, curve: Curves.easeIn),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(flex: 3),

          // Animated Logo Section with Ambient Pulse Glow
          AnimatedBuilder(
            animation: Listenable.merge([_entryController, _pulseController]),
            builder: (context, child) {
              return Transform.scale(
                scale: _logoScale.value,
                child: Opacity(
                  opacity: _logoOpacity.value,
                  child: _buildLogoCard(_pulseController.value),
                ),
              );
            },
          ),

          const SizedBox(height: 26),

          // Animated Branding Text & Subtitles
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return SlideTransition(
                position: _textSlide,
                child: Opacity(
                  opacity: _textOpacity.value,
                  child: child,
                ),
              );
            },
            child: Column(
              children: [
                // App Title with Gradient Text
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds),
                  child: Text(
                    "TaskPro",
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Pill Tagline
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    "Smart Task Management",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Audience Description
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildAudienceChip(Icons.person_outline_rounded, "Citizens"),
                    _buildDotSeparator(),
                    _buildAudienceChip(Icons.business_center_outlined, "Managers"),
                    _buildDotSeparator(),
                    _buildAudienceChip(Icons.engineering_outlined, "Workers"),
                  ],
                ),
              ],
            ),
          ),

          const Spacer(flex: 3),

          // Bottom Loader & Version Tag
          AnimatedBuilder(
            animation: _entryController,
            builder: (context, child) {
              return Opacity(
                opacity: _loaderOpacity.value,
                child: child,
              );
            },
            child: Column(
              children: [
                // Custom Glowing Modern Linear Progress Indicator
                SizedBox(
                  width: 140,
                  height: 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  "Initializing workspace...",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary.withValues(alpha: 0.8),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 32),

                // Version Badge Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  child: const Text(
                    "v1.0.0",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Creates dynamic glowing glassmorphism logo icon box
  Widget _buildLogoCard(double pulseValue) {
    final double pulseGlow = 15 + (pulseValue * 12);

    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),

        boxShadow: [
          // Soft Primary Tint Outer Glow
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18 + (pulseValue * 0.08)),
            blurRadius: pulseGlow,
            spreadRadius: pulseValue * 3,
            offset: const Offset(0, 10),
          ),
          // Subtle Depth Ambient Shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Main Icon
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/prosat.gif',
                fit: BoxFit.cover,
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildAudienceChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDotSeparator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          color: AppColors.textSecondary.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

/// Soft ambient dynamic canvas painter for modern background aesthetic
class AmbientBackground extends StatelessWidget {
  const AmbientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackgroundPainter(),
    );
  }
}

class _BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Top Right Primary Glow
    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.12),
        AppColors.primary.withValues(alpha: 0.0),
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.85, size.height * 0.15),
        radius: size.width * 0.65,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.15),
      size.width * 0.65,
      paint,
    );

    // Bottom Left Subtle Accent Glow
    paint.shader = RadialGradient(
      colors: [
        AppColors.primaryDark.withValues(alpha: 0.08),
        AppColors.primaryDark.withValues(alpha: 0.0),
      ],
    ).createShader(
      Rect.fromCircle(
        center: Offset(size.width * 0.15, size.height * 0.85),
        radius: size.width * 0.7,
      ),
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.85),
      size.width * 0.7,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


