
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const Color _navy = Color(0xFF102A56);
  static const Color _blue = Color(0xFF2563EB);

  static const Color _background = Color(0xFFF4F7FC);

  static const Color _muted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildHeroHeader(),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 24, 18, 30),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 720,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildPrivacyNotice(),

                      const SizedBox(height: 24),

                      const _SectionHeading(
                        title: 'OUR PRIVACY COMMITMENT',
                        subtitle:
                        'Learn how we handle your information.',
                      ),

                      const SizedBox(height: 14),

                      _PolicyCard(
                        number: '01',
                        title: 'Introduction',
                        icon: Icons.info_outline_rounded,
                        accentColor: Color(0xFF2563EB),
                        child: const _PolicyText(
                          'Welcome to PSN Task Pro ("we", "our", or '
                              '"us"). We respect your privacy and are '
                              'committed to protecting your personal data. '
                              'This policy explains how we collect, use, '
                              'store and protect information when you use '
                              'our mobile application.',
                        ),
                      ),

                      const SizedBox(height: 14),

                      _PolicyCard(
                        number: '02',
                        title: 'Information We Collect',
                        icon: Icons.folder_shared_outlined,
                        accentColor: Color(0xFF7C3AED),
                        child: const Column(
                          children: [
                            _InfoItem(
                              icon: Icons.badge_outlined,
                              title: 'Identity Data',
                              description:
                              'Username or similar identifiers '
                                  'used to identify your account.',
                              color: Color(0xFF7C3AED),
                            ),
                            _InfoItem(
                              icon: Icons.mail_outline_rounded,
                              title: 'Contact Data',
                              description:
                              'Email address and contact details '
                                  'provided when requesting support.',
                              color: Color(0xFF2563EB),
                            ),
                            _InfoItem(
                              icon: Icons.assignment_outlined,
                              title: 'Task & Productivity Data',
                              description:
                              'Tasks, schedules, notes and '
                                  'work-related information entered '
                                  'in the application.',
                              color: Color(0xFF0891B2),
                            ),
                            _InfoItem(
                              icon: Icons.phone_android_rounded,
                              title: 'Technical Data',
                              description:
                              'Device type, operating system '
                                  'and diagnostic information '
                                  'such as crash logs.',
                              color: Color(0xFFEA580C),
                              showDivider: false,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _PolicyCard(
                        number: '03',
                        title: 'How We Use Your Information',
                        icon: Icons.tune_rounded,
                        accentColor: Color(0xFF0891B2),
                        child: const Column(
                          children: [
                            _CheckItem(
                              text:
                              'Provide and maintain the core '
                                  'task-management features.',
                            ),
                            _CheckItem(
                              text:
                              'Manage your account and '
                                  'user profile.',
                            ),
                            _CheckItem(
                              text:
                              'Respond to questions and provide '
                                  'customer support.',
                            ),
                            _CheckItem(
                              text:
                              'Improve application performance '
                                  'and user experience.',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      _PolicyCard(
                        number: '04',
                        title: 'Data Security',
                        icon: Icons.verified_user_outlined,
                        accentColor: Color(0xFF059669),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            const _PolicyText(
                              'We use appropriate security measures '
                                  'designed to protect your personal data '
                                  'against unauthorized access, loss, '
                                  'misuse or disclosure. Access is '
                                  'restricted to authorized personnel '
                                  'with a legitimate business need.',
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: const Color(0xFFECFDF5),
                                borderRadius:
                                BorderRadius.circular(14),
                                border: Border.all(
                                  color: const Color(0xFFD1FAE5),
                                ),
                              ),
                              child: const Row(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF059669),
                                    size: 22,
                                  ),
                                  SizedBox(width: 11),
                                  Expanded(
                                    child: Text(
                                      'Your privacy and data security '
                                          'are important to us.',
                                      style: TextStyle(
                                        color: Color(0xFF047857),
                                        fontSize: 13,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const _SectionHeading(
                        title: 'NEED ASSISTANCE?',
                        subtitle:
                        'Have a privacy-related question?',
                      ),

                      const SizedBox(height: 14),

                      _buildContactCard(),

                      const SizedBox(height: 30),

                      Center(child: _buildFooter()),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF102A56),
            Color(0xFF1D4ED8),
            Color(0xFF2563EB),
          ],
        ),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(32),
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned(
            right: -55,
            top: -55,
            child: _decorativeCircle(190, 0.07),
          ),
          Positioned(
            left: -65,
            bottom: -90,
            child: _decorativeCircle(180, 0.06),
          ),
          Positioned(
            right: 40,
            bottom: 35,
            child: _decorativeCircle(60, 0.08),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              24, 30, 24, 36,
            ),
            child: Column(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.12),
                    border: Border.all(
                      color:
                      Colors.white.withValues(alpha: 0.22),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.12,
                            ),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: _blue,
                        size: 38,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Your Privacy Matters',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  'Transparency. Trust. Protection.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.82),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.13),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color:
                      Colors.white.withValues(alpha: 0.18),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_month_outlined,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Updated October 19, 2026',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
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

  Widget _decorativeCircle(double size, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: opacity),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF2FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFD7E6FF),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.privacy_tip_outlined,
            color: _blue,
            size: 25,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A Commitment to Transparency',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _navy,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'This policy explains how PSN Task Pro '
                      'handles your information and helps you '
                      'understand our privacy practices.',
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.55,
                    color: Color(0xFF476080),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF102A56),
            Color(0xFF1E40AF),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: _navy.withValues(alpha: 0.16),
            blurRadius: 20,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(width: 13),
              const Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Our Support Team',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'We are here to help.',
                      style: TextStyle(
                        color: Color(0xFFCBDCFB),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.alternate_email_rounded,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
                SizedBox(width: 11),
                Expanded(
                  child: SelectableText(
                    'support@psntaskpro.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
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

  Widget _buildFooter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFFE5EDFC),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.handyman_rounded,
            color: _blue,
            size: 25,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'PSN TASK PRO',
          style: TextStyle(
            fontSize: 13,
            color: _navy,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Work Smarter. Stay Connected.',
          style: TextStyle(
            fontSize: 11,
            color: _muted,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: 55,
          height: 1,
          color: const Color(0xFFD8E1ED),
        ),
        const SizedBox(height: 14),
        const Text(
          '© 2026 PSN Task Pro. All rights reserved.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: _muted,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final String number;
  final String title;
  final IconData icon;
  final Color accentColor;
  final Widget child;

  const _PolicyCard({
    required this.number,
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE8EDF5),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E293B)
                .withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color:
                    accentColor.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    icon,
                    color: accentColor,
                    size: 23,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                ),
                Text(
                  number,
                  style: TextStyle(
                    color:
                    accentColor.withValues(alpha: 0.38),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: const Color(0xFFF0F3F8),
            ),
            const SizedBox(height: 15),
            child,
          ],
        ),
      ),
    );
  }
}

class _PolicyText extends StatelessWidget {
  final String text;

  const _PolicyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        color: Color(0xFF52637B),
        height: 1.7,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final bool showDivider;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF253858),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: Color(0xFF64748B),
                      height: 1.55,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (showDivider) ...[
          const SizedBox(height: 14),
          const Divider(
            height: 1,
            color: Color(0xFFF0F3F8),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  final bool isLast;

  const _CheckItem({
    required this.text,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: isLast ? 0 : 15,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 23,
            height: 23,
            decoration: const BoxDecoration(
              color: Color(0xFFE0F2FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Color(0xFF0284C7),
              size: 15,
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF52637B),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
