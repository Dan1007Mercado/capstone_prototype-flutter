import 'package:flutter/material.dart';
import 'package:capstone_prototype/pages/auth/login.dart' as auth;

// ── Palette ──────────────────────────────────────────────────────────────
class _SignupColors {
  static const Color tealDark = Color(0xFF0F9B9B);
  static const Color tealLight = Color(0xFF2DD4CF);
  static const Color iconTeal = Color(0xFF14B8A6);
  static const Color mintChipBg = Color(0xFFDFF5F3);
  static const Color pageBg = Color(0xFFF4F7F8);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color headingText = Color(0xFF0E2A2E);
  static const Color bodyText = Color(0xFF7C8A90);
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
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

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {Color? color}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color ?? _SignupColors.tealDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnack('Passwords do not match', color: Colors.red);
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
        MaterialPageRoute<void>(
          builder: (_) => const auth.LoginPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                child: _buildSignupForm(context),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm(BuildContext context) {
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
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: _SignupColors.headingText,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sign up to get started with TalaanScan',
              style: TextStyle(
                fontSize: 14,
                color: _SignupColors.bodyText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            // First Name
            TextFormField(
              controller: _firstNameController,
              style: TextStyle(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'First Name',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
              style: TextStyle(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Last Name',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
              style: TextStyle(color: _SignupColors.headingText),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
              style: TextStyle(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
              style: TextStyle(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
              style: TextStyle(color: _SignupColors.headingText),
              decoration: InputDecoration(
                labelText: 'Confirm Password',
                labelStyle: TextStyle(color: _SignupColors.bodyText),
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
                child: const Text(
                  'Create Account',
                  style: TextStyle(
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
                  style: TextStyle(
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
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
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
}