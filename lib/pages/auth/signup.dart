// pages/auth/signup.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:capstone_prototype/theme/app_theme.dart';
import 'package:capstone_prototype/pages/auth/login.dart' as auth;

// ── Palette ──────────────────────────────────────────────────────────────
class _SignupColors {
  static const Color tealDark = Color(0xFF0F9B9B);
  static const Color tealDarkest = Color(0xFF0B7D7D);
  static const Color tealLight = Color(0xFF2DD4CF);
  static const Color iconTeal = Color(0xFF14B8A6);
  static const Color mintChipBg = Color(0xFFDFF5F3);
  static const Color pageBg = Color(0xFFF4F7F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color headingText = Colors.black;
  static const Color bodyText = Colors.black;
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = true;

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.inter(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE11D48) : _SignupColors.tealDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(RadiusTokens.md),
        ),
        margin: const EdgeInsets.all(SpacingTokens.md),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isLoading = false);

    _showSnack('Account created successfully!');
    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const auth.LoginPage(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(-0.05, 0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                )),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
        ),
      );
    });
  }

  // ─── Web Left Panel Feature Card ───────────────────────────────────────────
  Widget _buildWebFeatureCard(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(RadiusTokens.lg),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Web Input Decoration ──────────────────────────────────────────────────
  InputDecoration _webInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.black),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: const BorderSide(color: _SignupColors.tealDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: const BorderSide(color: Color(0xFFE11D48)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(RadiusTokens.md),
        borderSide: const BorderSide(color: Color(0xFFE11D48), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: GoogleFonts.inter(
        color: Colors.black,
        fontSize: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SpacingTokens.md,
        vertical: SpacingTokens.md,
      ),
    );
  }

  // ─── MOBILE LAYOUT (preserved exactly from original) ───────────────────────
  Widget _buildMobileLayout() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _SignupColors.tealDark,
              _SignupColors.tealLight,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: _buildMobileSignupForm(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileSignupForm() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: _SignupColors.cardWhite.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Decorative accent bar
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_SignupColors.tealDark, _SignupColors.tealLight],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Create Account',
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _SignupColors.headingText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to get started with TalaanScan',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: _SignupColors.bodyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // First Name
            TextFormField(
              controller: _firstNameController,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter your first name' : null,
            ),
            const SizedBox(height: 16),
            // Last Name
            TextFormField(
              controller: _lastNameController,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.person_outline,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Enter your last name' : null,
            ),
            const SizedBox(height: 16),
            // Email
            TextFormField(
              controller: _emailController,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Username
            TextFormField(
              controller: _usernameController,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.account_circle_outlined,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Choose a username' : null,
            ),
            const SizedBox(height: 16),
            // Password
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: _SignupColors.bodyText,
                  ),
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.length < 6 ? 'Password must be at least 6 characters' : null,
            ),
            const SizedBox(height: 16),
            // Confirm Password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: GoogleFonts.inter(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: GoogleFonts.inter(color: _SignupColors.bodyText),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: _SignupColors.iconTeal,
                ),
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: _SignupColors.bodyText,
                  ),
                ),
                filled: true,
                fillColor: _SignupColors.pageBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: _SignupColors.tealDark,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
              validator: (value) =>
                  value == null || value.length < 6 ? 'Confirm your password' : null,
            ),
            const SizedBox(height: 20),
            // Sign Up button
            SizedBox(
              width: double.infinity,
              child: _buildGradientButton(
                onPressed: _isLoading ? null : _signUp,
                isLoading: _isLoading,
                child: Text(
                  'Create Account',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Sign in link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Already have an account?',
                  style: GoogleFonts.inter(
                    color: _SignupColors.bodyText,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(builder: (_) => const auth.LoginPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: _SignupColors.tealDark,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                  child: Text(
                    'Sign In',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton({
    required VoidCallback? onPressed,
    required bool isLoading,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [
            _SignupColors.tealDark,
            _SignupColors.tealLight,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _SignupColors.tealDark.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: _SignupColors.cardWhite,
                      strokeWidth: 2.5,
                    ),
                  )
                : child,
          ),
        ),
      ),
    );
  }

  // ─── WEB LAYOUT (split-screen, matching login web design) ─────────────────
  Widget _buildWebLayout() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          // ── Left Panel ──────────────────────────────────────────────────────
          Expanded(
            flex: 45,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_SignupColors.tealDark, _SignupColors.tealDarkest],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(SpacingTokens.xxl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo
                      Container(
                        width: 220,
                        height: 220,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(RadiusTokens.lg),
                        ),
                        child: Image.asset(
                          'assets/images/talaanscan.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 22),
                      // Heading
                      Text(
                        'Start your journey',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      Text(
                        'Join thousands of teams using TalaanScan to collect, analyze, and share survey insights.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Feature Cards Grid
                      Expanded(
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 420),
                            child: GridView.count(
                              shrinkWrap: true,
                              crossAxisCount: 2,
                              mainAxisSpacing: SpacingTokens.md,
                              crossAxisSpacing: SpacingTokens.md,
                              childAspectRatio: 1.35,
                              physics: const NeverScrollableScrollPhysics(),
                              children: [
                                _buildWebFeatureCard(
                                  Icons.bolt_outlined,
                                  'Real-time',
                                  'Live response tracking',
                                ),
                                _buildWebFeatureCard(
                                  Icons.shield_outlined,
                                  'Secure',
                                  'Enterprise-grade privacy',
                                ),
                                _buildWebFeatureCard(
                                  Icons.bar_chart_outlined,
                                  'Visual',
                                  'Beautiful dashboards',
                                ),
                                _buildWebFeatureCard(
                                  Icons.auto_fix_high_outlined,
                                  'Automated',
                                  'AI-powered insights',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // ── Right Panel ─────────────────────────────────────────────────────
          Expanded(
            flex: 55,
            child: Center(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Padding(
                    padding: const EdgeInsets.all(SpacingTokens.xxl),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand Header
                            Row(
                              children: [
                                Container(
                                  width: 80,
                                  height: 80,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: _SignupColors.tealDark.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(RadiusTokens.md),
                                  ),
                                  child: Image.asset(
                                    'assets/images/talaanscan.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'TalaanScan',
                                  style: GoogleFonts.inter(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // Welcome Text
                            Text(
                              'Create your account',
                              style: GoogleFonts.inter(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Enter your details to get started with TalaanScan.',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: Colors.black,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Form
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // First Name + Last Name row
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller: _firstNameController,
                                          textInputAction: TextInputAction.next,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF111827),
                                            fontSize: 14,
                                          ),
                                          decoration: _webInputDecoration(
                                            label: 'First name',
                                            hint: 'John',
                                            icon: Icons.person_outline,
                                          ),
                                          validator: (value) => value == null ||
                                                  value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: TextFormField(
                                          controller: _lastNameController,
                                          textInputAction: TextInputAction.next,
                                          style: GoogleFonts.inter(
                                            color: const Color(0xFF111827),
                                            fontSize: 14,
                                          ),
                                          decoration: _webInputDecoration(
                                            label: 'Last name',
                                            hint: 'Doe',
                                            icon: Icons.person_outline,
                                          ),
                                          validator: (value) => value == null ||
                                                  value.trim().isEmpty
                                              ? 'Required'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Email
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                    ),
                                    decoration: _webInputDecoration(
                                      label: 'Email address',
                                      hint: 'hello@example.com',
                                      icon: Icons.email_outlined,
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Email is required';
                                      }
                                      if (!value.contains('@') ||
                                          !value.contains('.')) {
                                        return 'Enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Username
                                  TextFormField(
                                    controller: _usernameController,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                    ),
                                    decoration: _webInputDecoration(
                                      label: 'Username',
                                      hint: 'johndoe',
                                      icon: Icons.account_circle_outlined,
                                    ),
                                    validator: (value) => value == null ||
                                            value.trim().isEmpty
                                        ? 'Username is required'
                                        : null,
                                  ),
                                  const SizedBox(height: 16),
                                  // Password
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.next,
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                    ),
                                    decoration: _webInputDecoration(
                                      label: 'Password',
                                      hint: 'Min. 6 characters',
                                      icon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword = !_obscurePassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password is required';
                                      }
                                      if (value.length < 6) {
                                        return 'Minimum 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Confirm Password
                                  TextFormField(
                                    controller: _confirmPasswordController,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) => _signUp(),
                                    style: GoogleFonts.inter(
                                      color: const Color(0xFF111827),
                                      fontSize: 14,
                                    ),
                                    decoration: _webInputDecoration(
                                      label: 'Confirm password',
                                      hint: 'Repeat your password',
                                      icon: Icons.lock_outline_rounded,
                                      suffixIcon: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          size: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirm your password';
                                      }
                                      if (value.length < 6) {
                                        return 'Minimum 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  // Terms checkbox
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: Checkbox(
                                          value: _agreeToTerms,
                                          onChanged: (v) => setState(
                                              () => _agreeToTerms = v ?? true),
                                          activeColor: _SignupColors.tealDark,
                                          side: const BorderSide(
                                            color: Color(0xFFD1D5DB),
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text.rich(
                                          TextSpan(
                                            style: GoogleFonts.inter(
                                              fontSize: 13,
                                              color: Colors.black,
                                            ),
                                            children: [
                                              const TextSpan(
                                                  text: 'I agree to the '),
                                              TextSpan(
                                                text: 'Terms of Service',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      _SignupColors.tealDark,
                                                ),
                                              ),
                                              const TextSpan(text: ' and '),
                                              TextSpan(
                                                text: 'Privacy Policy',
                                                style: GoogleFonts.inter(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      _SignupColors.tealDark,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Create Account Button
                                  SizedBox(
                                    height: 48,
                                    child: FilledButton.icon(
                                      onPressed:
                                          _isLoading || !_agreeToTerms
                                              ? null
                                              : _signUp,
                                      icon: _isLoading
                                          ? const SizedBox.shrink()
                                          : const Icon(
                                              Icons.arrow_forward,
                                              size: 18,
                                            ),
                                      label: _isLoading
                                          ? const SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  Colors.white,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'Create Account',
                                              style: GoogleFonts.inter(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor:
                                            _SignupColors.tealDark,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor:
                                            _SignupColors.tealDark
                                                .withValues(alpha: 0.5),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            RadiusTokens.md,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Divider
                                  Row(
                                    children: [
                                      const Expanded(
                                        child: Divider(
                                          color: Color(0xFFE5E7EB),
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Text(
                                          'or continue with',
                                          style: GoogleFonts.inter(
                                            fontSize: 13,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        child: Divider(
                                          color: Color(0xFFE5E7EB),
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  // Google Button
                                  SizedBox(
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: () {
                                        _showSnack('Continue with Google');
                                      },
                                      icon: const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: _GoogleLogo(),
                                      ),
                                      label: Text(
                                        'Google',
                                        style: GoogleFonts.inter(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black,
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor:
                                            Colors.black,
                                        side: const BorderSide(
                                          color: Color(0xFFE5E7EB),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            RadiusTokens.md,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 32),
                                  // Sign in link
                                  Center(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      spacing: 6,
                                      children: [
                                        Text(
                                          'Already have an account?',
                                          style: GoogleFonts.inter(
                                            color: Colors.black,
                                            fontSize: 14,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            Navigator.of(context)
                                                .pushReplacement(
                                              PageRouteBuilder(
                                                pageBuilder: (context,
                                                        animation,
                                                        secondaryAnimation) =>
                                                    const auth.LoginPage(),
                                                transitionsBuilder: (context,
                                                    animation,
                                                    secondaryAnimation,
                                                    child) {
                                                  return FadeTransition(
                                                    opacity: animation,
                                                    child: SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(
                                                            -0.05, 0),
                                                        end: Offset.zero,
                                                      ).animate(
                                                        CurvedAnimation(
                                                          parent: animation,
                                                          curve: Curves
                                                              .easeOutCubic,
                                                        ),
                                                      ),
                                                      child: child,
                                                    ),
                                                  );
                                                },
                                                transitionDuration:
                                                    const Duration(
                                                        milliseconds: 400),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Sign in',
                                            style: GoogleFonts.inter(
                                              color: _SignupColors.tealDark,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 14,
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
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── SMALL WEB LAYOUT (narrow desktop/tablet) ──────────────────────────────
  Widget _buildSmallWebLayout() {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(SpacingTokens.xl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(SpacingTokens.xxl),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(RadiusTokens.xl),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Brand
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: _SignupColors.tealDark
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(RadiusTokens.md),
                              ),
                              child: Image.asset(
                                'assets/images/talaanscan.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'TalaanScan',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF111827),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Create your account',
                          style: GoogleFonts.inter(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF111827),
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Enter your details to get started with TalaanScan.',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 28),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // First + Last name row
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: _firstNameController,
                                      textInputAction: TextInputAction.next,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF111827),
                                        fontSize: 14,
                                      ),
                                      decoration: _webInputDecoration(
                                        label: 'First name',
                                        hint: 'John',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (value) => value == null ||
                                              value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _lastNameController,
                                      textInputAction: TextInputAction.next,
                                      style: GoogleFonts.inter(
                                        color: const Color(0xFF111827),
                                        fontSize: 14,
                                      ),
                                      decoration: _webInputDecoration(
                                        label: 'Last name',
                                        hint: 'Doe',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (value) => value == null ||
                                              value.trim().isEmpty
                                          ? 'Required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF111827),
                                  fontSize: 14,
                                ),
                                decoration: _webInputDecoration(
                                  label: 'Email address',
                                  hint: 'hello@example.com',
                                  icon: Icons.email_outlined,
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!value.contains('@') ||
                                      !value.contains('.')) {
                                    return 'Enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              // Username
                              TextFormField(
                                controller: _usernameController,
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF111827),
                                  fontSize: 14,
                                ),
                                decoration: _webInputDecoration(
                                  label: 'Username',
                                  hint: 'johndoe',
                                  icon: Icons.account_circle_outlined,
                                ),
                                validator: (value) => value == null ||
                                        value.trim().isEmpty
                                    ? 'Username is required'
                                    : null,
                              ),
                              const SizedBox(height: 14),
                              // Password
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.next,
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF111827),
                                  fontSize: 14,
                                ),
                                decoration: _webInputDecoration(
                                  label: 'Password',
                                  hint: 'Min. 6 characters',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (value.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              // Confirm Password
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _obscureConfirmPassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) => _signUp(),
                                style: GoogleFonts.inter(
                                  color: const Color(0xFF111827),
                                  fontSize: 14,
                                ),
                                decoration: _webInputDecoration(
                                  label: 'Confirm password',
                                  hint: 'Repeat your password',
                                  icon: Icons.lock_outline_rounded,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _obscureConfirmPassword =
                                            !_obscureConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _obscureConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      size: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Confirm your password';
                                  }
                                  if (value.length < 6) {
                                    return 'Minimum 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              // Terms
                              Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: Checkbox(
                                      value: _agreeToTerms,
                                      onChanged: (v) => setState(
                                          () => _agreeToTerms = v ?? true),
                                      activeColor: _SignupColors.tealDark,
                                      side: const BorderSide(
                                        color: Color(0xFFD1D5DB),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text.rich(
                                      TextSpan(
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          const TextSpan(
                                              text: 'I agree to the '),
                                          TextSpan(
                                            text: 'Terms',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              color: _SignupColors.tealDark,
                                            ),
                                          ),
                                          const TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy',
                                            style: GoogleFonts.inter(
                                              fontWeight: FontWeight.w600,
                                              color: _SignupColors.tealDark,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 46,
                                child: FilledButton.icon(
                                  onPressed:
                                      _isLoading || !_agreeToTerms
                                          ? null
                                          : _signUp,
                                  icon: _isLoading
                                      ? const SizedBox.shrink()
                                      : const Icon(
                                          Icons.arrow_forward,
                                          size: 18,
                                        ),
                                  label: _isLoading
                                      ? const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Create Account',
                                          style: GoogleFonts.inter(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: _SignupColors.tealDark,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: _SignupColors
                                        .tealDark
                                        .withValues(alpha: 0.5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        RadiusTokens.md,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE5E7EB),
                                      thickness: 1,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(
                                      'or continue with',
                                      style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(
                                      color: Color(0xFFE5E7EB),
                                      thickness: 1,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 46,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _showSnack('Continue with Google');
                                  },
                                  icon: const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: _GoogleLogo(),
                                  ),
                                  label: Text(
                                    'Google',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    side: const BorderSide(
                                      color: Color(0xFFE5E7EB),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        RadiusTokens.md,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Center(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Text(
                                      'Already have an account?',
                                      style: GoogleFonts.inter(
                                        color: Colors.black,
                                        fontSize: 13,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushReplacement(
                                          PageRouteBuilder(
                                            pageBuilder: (context, animation,
                                                    secondaryAnimation) =>
                                                const auth.LoginPage(),
                                            transitionsBuilder: (context,
                                                animation,
                                                secondaryAnimation,
                                                child) {
                                              return FadeTransition(
                                                opacity: animation,
                                                child: SlideTransition(
                                                  position: Tween<Offset>(
                                                    begin:
                                                        const Offset(-0.05, 0),
                                                    end: Offset.zero,
                                                  ).animate(
                                                    CurvedAnimation(
                                                      parent: animation,
                                                      curve:
                                                          Curves.easeOutCubic,
                                                    ),
                                                  ),
                                                  child: child,
                                                ),
                                              );
                                            },
                                            transitionDuration:
                                                const Duration(
                                                    milliseconds: 400),
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'Sign in',
                                        style: GoogleFonts.inter(
                                          color: _SignupColors.tealDark,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13,
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
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Mobile: < 600px
        if (constraints.maxWidth < 600) {
          return _buildMobileLayout();
        }
        // Small web/tablet: 600px - 899px
        if (constraints.maxWidth < 900) {
          return _buildSmallWebLayout();
        }
        // Desktop web: >= 900px
        return _buildWebLayout();
      },
    );
  }
}

/// A lightweight, dependency-free rendering of the multicolor Google "G"
/// mark (blue / green / yellow / red ring with a blue crossbar), drawn with
/// CustomPainter so no extra image asset or SVG package is required.
class _GoogleLogo extends StatelessWidget {
  const _GoogleLogo();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _GoogleLogoPainter());
  }
}

class _GoogleLogoPainter extends CustomPainter {
  static const Color _blue = Color(0xFF4285F4);
  static const Color _green = Color(0xFF34A853);
  static const Color _yellow = Color(0xFFFBBC05);
  static const Color _red = Color(0xFFEA4335);

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.shortestSide / 2;
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double strokeWidth = radius * 0.46;
    final Rect rect = Rect.fromCircle(
      center: center,
      radius: radius - strokeWidth / 2,
    );

    Paint ringPaint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    // Angles are in radians, measured clockwise from 3 o'clock.
    const double start1 = -0.35, sweep1 = 1.95; // blue: right arc
    const double start2 = start1 + sweep1, sweep2 = 1.35; // green: bottom
    const double start3 = start2 + sweep2, sweep3 = 1.15; // yellow: left
    const double start4 = start3 + sweep3, sweep4 = 1.87; // red: top

    canvas.drawArc(rect, start1, sweep1, false, ringPaint(_blue));
    canvas.drawArc(rect, start2, sweep2, false, ringPaint(_green));
    canvas.drawArc(rect, start3, sweep3, false, ringPaint(_yellow));
    canvas.drawArc(rect, start4, sweep4, false, ringPaint(_red));

    // Crossbar of the "G", extending from the center to the right edge.
    final Paint barPaint = Paint()..color = _blue;
    final double barHeight = strokeWidth * 0.62;
    final Rect barRect = Rect.fromLTWH(
      center.dx - strokeWidth * 0.06,
      center.dy - barHeight / 2,
      radius * 0.92,
      barHeight,
    );
    canvas.drawRect(barRect, barPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
