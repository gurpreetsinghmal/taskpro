import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:taskpro/modules/login/login_controller.dart';

import '../../theme/app_colors.dart';
import '../app_routes/app_routes.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color navy = Color(0xFF10143F);
  static const Color navyLight = Color(0xFF192052);

  static const Color yellow = Color(0xFFFFE500);
  static const Color yellowDark = Color(0xFFFFB900);

  static const Color teal = Color(0xFF00C9A7);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: navy,
      resizeToAvoidBottomInset: true,

      body: Stack(
        children: [
          // ========================================================
          // ANIMATED BACKGROUND
          // ========================================================

          const Positioned.fill(
            child: _AnimatedBackground(),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,

                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),

                    child: const _LoginBody(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// LOGIN BODY
// ============================================================================

class _LoginBody extends StatefulWidget {
  const _LoginBody();

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody>
    with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _floatController;
  late AnimationController _shineController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<Offset> _cardSlide;
  late Animation<double> _cardOpacity;

  @override
  void initState() {
    super.initState();

    // ============================================================
    // ENTRY ANIMATION
    // ============================================================

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );

    // ============================================================
    // FLOATING LOGO
    // ============================================================

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    // ============================================================
    // BUTTON SHINE
    // ============================================================

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    // ============================================================
    // LOGO SCALE
    // ============================================================

    _logoScale = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.0,
          0.42,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    // ============================================================
    // LOGO OPACITY
    // ============================================================

    _logoOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.0,
          0.30,
          curve: Curves.easeIn,
        ),
      ),
    );

    // ============================================================
    // CARD SLIDE
    // ============================================================

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.20),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.25,
          0.95,
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    // ============================================================
    // CARD OPACITY
    // ============================================================

    _cardOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: const Interval(
          0.25,
          0.75,
          curve: Curves.easeIn,
        ),
      ),
    );

    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    _floatController.dispose();
    _shineController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Register controller dynamically
    final controller = Get.put(LoginController());

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        16,
        20,
        25,
      ),

      child: Column(
        children: [
          const SizedBox(height: 5),

          // ========================================================
          // LOGO
          // ========================================================

          AnimatedBuilder(
            animation: Listenable.merge([
              _entryController,
              _floatController,
            ]),

            builder: (context, child) {
              final float =
                  (_floatController.value - 0.5) * 7;

              return Transform.translate(
                offset: Offset(0, float),

                child: Transform.scale(
                  scale: _logoScale.value,

                  child: Opacity(
                    opacity: _logoOpacity.value,

                    child: child,
                  ),
                ),
              );
            },

            child: _buildLogo(),
          ),

          const SizedBox(height: 13),

          // ========================================================
          // BRAND
          // ========================================================

          FadeTransition(
            opacity: _entryController,

            child: _buildBrand(),
          ),

          const SizedBox(height: 23),

          // ========================================================
          // FEATURE ICONS
          // ========================================================

          FadeTransition(
            opacity: _entryController,

            child: _buildFeatureRow(),
          ),

          const SizedBox(height: 22),

          // ========================================================
          // LOGIN CARD
          // ========================================================

          SlideTransition(
            position: _cardSlide,

            child: FadeTransition(
              opacity: _cardOpacity,

              child: _buildLoginCard(controller),
            ),
          ),

          const SizedBox(height: 20),

          // ========================================================
          // FOOTER
          // ========================================================

          FadeTransition(
            opacity: _entryController,

            child: _buildFooter(),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // LOGO
  // ==========================================================================

  Widget _buildLogo() {
    return Container(
      width: 118,
      height: 118,

      padding: const EdgeInsets.all(6),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(31),

        border: Border.all(
          color: LoginScreen.yellow,
          width: 3,
        ),

        boxShadow: [
          BoxShadow(
            color: LoginScreen.yellow.withValues(
              alpha: 0.25,
            ),

            blurRadius: 35,
            spreadRadius: 5,
          ),

          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.30,
            ),

            blurRadius: 25,

            offset: const Offset(
              0,
              12,
            ),
          ),
        ],
      ),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),

        child: Image.asset(
          'assets/prosat.gif',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // ==========================================================================
  // BRAND
  // ==========================================================================

  Widget _buildBrand() {
    return Column(
      children: [
        RichText(
          textAlign: TextAlign.center,

          text: const TextSpan(
            children: [
              TextSpan(
                text: 'PSN ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),

              TextSpan(
                text: 'Task',
                style: TextStyle(
                  color: LoginScreen.yellow,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),

              TextSpan(
                text: ' Pro',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 7),

        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.07,
            ),

            borderRadius: BorderRadius.circular(30),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
            ),
          ),

          child: const Row(
            mainAxisSize: MainAxisSize.min,

            children: [
              Icon(
                Icons.bolt_rounded,
                color: LoginScreen.yellow,
                size: 15,
              ),

              SizedBox(width: 5),

              Text(
                'WORK  •  TRACK  •  GROW',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================================
  // FEATURE ROW
  // ==========================================================================

  Widget _buildFeatureRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,

      children: [
        _FeatureIcon(
          icon: Icons.assignment_rounded,
          color: const Color(0xFF00D4A8),
          label: 'Work Orders',
        ),

        const SizedBox(width: 13),

        _FeatureIcon(
          icon: Icons.location_on_rounded,
          color: const Color(0xFF4C8DFF),
          label: 'Track',
        ),

        const SizedBox(width: 13),

        _FeatureIcon(
          icon: Icons.analytics_rounded,
          color: const Color(0xFFFFB52E),
          label: 'Progress',
        ),

        // const SizedBox(width: 13),
        //
        // _FeatureIcon(
        //   icon: Icons.groups_rounded,
        //   color: const Color(0xFFFF6FAE),
        //   label: 'Team',
        // ),
      ],
    );
  }

  // ==========================================================================
  // LOGIN CARD
  // ==========================================================================

  Widget _buildLoginCard(LoginController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(31),

      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 15,
          sigmaY: 15,
        ),

        child: Container(
          width: double.infinity,

          padding: const EdgeInsets.fromLTRB(
            21,
            24,
            21,
            21,
          ),

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.97,
            ),

            borderRadius: BorderRadius.circular(31),

            border: Border.all(
              color: Colors.white,
              width: 1.2,
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.25,
                ),

                blurRadius: 35,

                offset: const Offset(
                  0,
                  18,
                ),
              ),
            ],
          ),

          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,

            children: [
              // ====================================================
              // HEADER
              // ====================================================

              Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          LoginScreen.yellow,
                          LoginScreen.yellowDark,
                        ],
                      ),

                      borderRadius:
                      BorderRadius.circular(14),

                      boxShadow: [
                        BoxShadow(
                          color: LoginScreen.yellow
                              .withValues(alpha: 0.30),

                          blurRadius: 12,

                          offset: const Offset(
                            0,
                            5,
                          ),
                        ),
                      ],
                    ),

                    child: const Icon(
                      Icons.login_rounded,
                      color: LoginScreen.navy,
                      size: 23,
                    ),
                  ),

                  const SizedBox(width: 13),

                  const Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      Text(
                        'Welcome Back!',
                        style: TextStyle(
                          color: Color(0xFF00A989),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),

                      SizedBox(height: 2),

                      Text(
                        'Sign in to continue',
                        style: TextStyle(
                          color: LoginScreen.navy,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 25),

              // ====================================================
              // EMAIL
              // ====================================================

              const _FieldLabel(
                icon: Icons.alternate_email_rounded,
                text: 'Email Address',
              ),

              const SizedBox(height: 8),

              _LoginTextField(
                controller:controller.usernameController,

                hintText:
                'Enter your email address',

                prefixIcon:
                Icons.person_outline_rounded,

                keyboardType:
                TextInputType.emailAddress,

                textInputAction:
                TextInputAction.next,
              ),

              const SizedBox(height: 17),

              // ====================================================
              // PASSWORD
              // ====================================================

              const _FieldLabel(
                icon: Icons.lock_outline_rounded,
                text: 'Password',
              ),

              const SizedBox(height: 8),

              Obx(
                    () => _LoginTextField(
                  controller:
                  controller.passwordController,

                  hintText:
                  'Enter your password',

                  prefixIcon:
                  Icons.lock_outline_rounded,

                  obscureText:
                  !controller
                      .isPasswordVisible
                      .value,

                  textInputAction:
                  TextInputAction.done,

                  onSubmitted: (_) {
                    controller.login();
                  },

                  suffixIcon: IconButton(
                    onPressed:
                    controller
                        .togglePasswordVisibility,

                    splashRadius: 20,

                    icon: Icon(
                      controller
                          .isPasswordVisible
                          .value
                          ? Icons.visibility_rounded
                          : Icons
                          .visibility_off_rounded,

                      size: 20,

                      color:
                      const Color(0xFF687690),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              // ====================================================
              // LOGIN BUTTON
              // ====================================================
              _AnimatedLoginButton(
                controller: controller,
                animation: _shineController,
              )
              ,

              const SizedBox(height: 17),
// ====================================================
// FORGOT PASSWORD
// ====================================================

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: ()=>Get.toNamed(AppRoutes.forget_password),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_reset_rounded,
                        size: 16,
                        color: Color(0xFF52627D),
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Color(0xFF52627D),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 7),

              // ====================================================
              // SECURITY MESSAGE
              // ====================================================

              Container(
                width: double.infinity,

                padding:
                const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 11,
                ),

                decoration: BoxDecoration(
                  color: const Color(0xFFF3FBF8),

                  borderRadius:
                  BorderRadius.circular(13),

                  border: Border.all(
                    color: const Color(0xFFD7F0E8),
                  ),
                ),

                child: const Row(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Color(0xFF13A982),
                      size: 17,
                    ),

                    SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        'Your login is protected and securely encrypted.',
                        style: TextStyle(
                          color: Color(0xFF527069),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 17),

              // ====================================================
              // CARD FOOTER
              // ====================================================

              // PROSAT Security Footer Watermark
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.textHint,
                    ),
                    SizedBox(width: 4),
                    Text(
                      "Secured by PROSAT Networks",
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // FOOTER
  // ==========================================================================

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.center,

      children: [
        Icon(
          Icons.shield_rounded,
          size: 13,

          color: Colors.white.withValues(
            alpha: 0.40,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          'Secure  •  Reliable  •  Connected',

          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.48,
            ),

            fontSize: 10,

            fontWeight: FontWeight.w500,

            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FEATURE ICON
// ============================================================================

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const _FeatureIcon({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 51,
          height: 51,

          decoration: BoxDecoration(
            color: Colors.white.withValues(
              alpha: 0.07,
            ),

            borderRadius:
            BorderRadius.circular(16),

            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
            ),

            boxShadow: [
              BoxShadow(
                color: color.withValues(
                  alpha: 0.12,
                ),

                blurRadius: 14,
              ),
            ],
          ),

          child: Icon(
            icon,
            color: color,
            size: 23,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          label,

          style: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.65,
            ),

            fontSize: 9.5,

            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// FIELD LABEL
// ============================================================================

class _FieldLabel extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FieldLabel({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: const Color(0xFF52627D),
        ),

        const SizedBox(width: 6),

        Text(
          text,

          style: const TextStyle(
            color: Color(0xFF263C62),
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// LOGIN TEXT FIELD
// ============================================================================

class _LoginTextField extends StatefulWidget {
  final TextEditingController controller;

  final String hintText;

  final IconData prefixIcon;

  final Widget? suffixIcon;

  final bool obscureText;

  final TextInputType? keyboardType;

  final TextInputAction? textInputAction;

  final Function(String)? onSubmitted;

  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,

    this.suffixIcon,

    this.obscureText = false,

    this.keyboardType,

    this.textInputAction,

    this.onSubmitted,
  });

  @override
  State<_LoginTextField> createState() =>
      _LoginTextFieldState();
}

class _LoginTextFieldState
    extends State<_LoginTextField> {
  final FocusNode _focusNode =
  FocusNode();

  bool _focused = false;

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {
          _focused =
              _focusNode.hasFocus;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration:
      const Duration(milliseconds: 200),

      height: 57,

      decoration: BoxDecoration(
        color: _focused
            ? const Color(0xFFFAFCFF)
            : const Color(0xFFF4F7FB),

        borderRadius:
        BorderRadius.circular(17),

        border: Border.all(
          color: _focused
              ? const Color(0xFF12A987)
              : const Color(0xFFE1E6EF),

          width:
          _focused ? 1.5 : 1,
        ),

        boxShadow: _focused
            ? [
          BoxShadow(
            color:
            const Color(0xFF12A987)
                .withValues(
              alpha: 0.10,
            ),

            blurRadius: 13,

            spreadRadius: 1,
          ),
        ]
            : null,
      ),

      child: TextField(
        controller:
        widget.controller,

        focusNode:
        _focusNode,

        obscureText:
        widget.obscureText,

        keyboardType:
        widget.keyboardType,

        textInputAction:
        widget.textInputAction,

        onSubmitted:
        widget.onSubmitted,

        style: const TextStyle(
          color: Color(0xFF172646),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),

        decoration:
        InputDecoration(
          border: InputBorder.none,

          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 17,
          ),

          prefixIcon:
          Icon(
            widget.prefixIcon,

            size: 20,

            color: _focused
                ? const Color(0xFF12A987)
                : const Color(0xFF7C879B),
          ),

          suffixIcon:
          widget.suffixIcon,

          hintText:
          widget.hintText,

          hintStyle:
          const TextStyle(
            color: Color(0xFF9AA5B7),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED LOGIN BUTTON
// ============================================================================

class _AnimatedLoginButton
    extends StatelessWidget {
  final LoginController controller;

  final Animation<double> animation;

  const _AnimatedLoginButton({
    required this.controller,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: controller.isLoading.value
          ? null
          : controller.login,

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),

        height: 57,

        width: double.infinity,

        decoration: BoxDecoration(
          gradient:
          const LinearGradient(
            colors: [
              Color(0xFFFFE500),
              Color(0xFFFFC400),
              Color(0xFFFFE500),
            ],

            begin:
            Alignment.centerLeft,

            end:
            Alignment.centerRight,
          ),

          borderRadius:
          BorderRadius.circular(17),

          boxShadow: [
            BoxShadow(
              color:
              const Color(0xFFFFD000)
                  .withValues(
                alpha: 0.30,
              ),

              blurRadius: 18,

              offset:
              const Offset(0, 8),
            ),
          ],
        ),

        child:
        controller.isLoading.value
            ? const Center(
          child: SizedBox(
            width: 24,
            height: 24,

            child:
            CircularProgressIndicator(
              strokeWidth: 2.7,

              valueColor:
              AlwaysStoppedAnimation<
                  Color>(
                Color(0xFF111642),
              ),
            ),
          ),
        )
            : Stack(
          children: [
            // ------------------------------------------------
            // SHINE
            // ------------------------------------------------

            AnimatedBuilder(
              animation:
              animation,

              builder:
                  (context, child) {
                return Positioned(
                  left:
                  -70 +
                      (animation
                          .value *
                          450),

                  top: 0,
                  bottom: 0,

                  child:
                  IgnorePointer(
                    child:
                    Container(
                      width: 55,

                      decoration:
                      BoxDecoration(
                        gradient:
                        LinearGradient(
                          colors: [
                            Colors
                                .white
                                .withValues(
                              alpha: 0,
                            ),
                            Colors
                                .white
                                .withValues(
                              alpha: 0.30,
                            ),
                            Colors
                                .white
                                .withValues(
                              alpha: 0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            // ------------------------------------------------
            // TEXT
            // ------------------------------------------------

            const Center(
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .center,

                children: [
                  Text(
                    'LOGIN',

                    style:
                    TextStyle(
                      color:
                      Color(
                        0xFF111642,
                      ),

                      fontSize: 14,

                      fontWeight:
                      FontWeight
                          .w900,

                      letterSpacing:
                      1.3,
                    ),
                  ),

                  SizedBox(
                    width: 11,
                  ),

                  Icon(
                    Icons
                        .arrow_forward_rounded,

                    color:
                    Color(
                      0xFF111642,
                    ),

                    size: 21,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ANIMATED BACKGROUND
// ============================================================================

class _AnimatedBackground
    extends StatefulWidget {
  const _AnimatedBackground();

  @override
  State<_AnimatedBackground>
  createState() =>
      _AnimatedBackgroundState();
}

class _AnimatedBackgroundState
    extends State<_AnimatedBackground>
    with
        SingleTickerProviderStateMixin {
  late AnimationController
  _controller;

  @override
  void initState() {
    super.initState();

    _controller =
    AnimationController(
      vsync: this,

      duration:
      const Duration(seconds: 7),
    )..repeat(
      reverse: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,

      builder: (context, child) {
        final value =
        Curves.easeInOut.transform(
          _controller.value,
        );

        return Stack(
          children: [
            // ========================================================
            // BASE GRADIENT
            // ========================================================

            Container(
              decoration:
              const BoxDecoration(
                gradient:
                LinearGradient(
                  begin:
                  Alignment.topLeft,

                  end:
                  Alignment.bottomRight,

                  colors: [
                    Color(0xFF10143F),
                    Color(0xFF192052),
                    Color(0xFF10143F),
                  ],
                ),
              ),
            ),

            // ========================================================
            // YELLOW GLOW
            // ========================================================

            Positioned(
              top:
              -140 +
                  (value * 45),

              right: -120,

              child: _GlowCircle(
                size: 350,

                color:
                const Color(
                  0xFFFFE500,
                ),

                opacity: 0.14,
              ),
            ),

            // ========================================================
            // BLUE GLOW
            // ========================================================

            Positioned(
              top:
              220 -
                  (value * 60),

              left: -160,

              child: _GlowCircle(
                size: 350,

                color:
                const Color(
                  0xFF4555FF,
                ),

                opacity: 0.20,
              ),
            ),

            // ========================================================
            // TEAL GLOW
            // ========================================================

            Positioned(
              bottom:
              -160 +
                  (value * 45),

              left: -100,

              child: _GlowCircle(
                size: 320,

                color:
                const Color(
                  0xFF00D5B0,
                ),

                opacity: 0.08,
              ),
            ),

            // ========================================================
            // ORANGE GLOW
            // ========================================================

            Positioned(
              bottom: -180,

              right:
              -110 +
                  (value * 30),

              child: _GlowCircle(
                size: 340,

                color:
                const Color(
                  0xFFFFB000,
                ),

                opacity: 0.09,
              ),
            ),

            // ========================================================
            // DOTS
            // ========================================================

            const Positioned(
              top: 110,
              right: 35,
              child: _Dots(),
            ),

            const Positioned(
              bottom: 90,
              left: 25,
              child: _Dots(),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// GLOW CIRCLE
// ============================================================================

class _GlowCircle
    extends StatelessWidget {
  final double size;

  final Color color;

  final double opacity;

  const _GlowCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,

      decoration:
      BoxDecoration(
        shape: BoxShape.circle,

        color:
        color.withValues(
          alpha: opacity,
        ),

        boxShadow: [
          BoxShadow(
            color:
            color.withValues(
              alpha: opacity,
            ),

            blurRadius: 110,

            spreadRadius: 30,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DECORATIVE DOTS
// ============================================================================

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 45,
      height: 45,

      child: Wrap(
        spacing: 7,
        runSpacing: 7,

        children:
        List.generate(
          9,

              (index) {
            return Container(
              width: 4,
              height: 4,

              decoration:
              BoxDecoration(
                color:
                Colors.white
                    .withValues(
                  alpha: 0.20,
                ),

                shape:
                BoxShape.circle,
              ),
            );
          },
        ),
      ),
    );
  }
}