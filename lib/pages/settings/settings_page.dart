import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../pages/auth/login.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/web_sidebar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _heroStart = Color(0xFF82E1E6);
  static const Color _heroEnd = Color(0xFF1FB9C1);
  static const Color _brandDeep = Colors.black;
  static const Color _mutedText = Colors.black;

  // ─────────────────────────────────────────────────────────────────────
  // Web palette (mirrors Surveys / Analytics / Online Forms web layouts)
  // ─────────────────────────────────────────────────────────────────────
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _tealDark = Color.fromARGB(255, 13, 232, 232);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Colors.black;
  static const Color _bodyText = Colors.black;
  static const Color _border = Color(0xFFDDECEF);

  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Daniel');
  final _lastNameController = TextEditingController(text: 'Mercado');
  final _genderController = TextEditingController(text: 'Male');
  final _emailController = TextEditingController(
    text: 'dmercado@talanscan.local',
  );
  final _phoneController = TextEditingController(text: '+1 (555) 000-0000');
  final _conversionThresholdController = TextEditingController(text: '85');
  final _autoReviewConfidenceController = TextEditingController(text: '95');
  final _retentionController = TextEditingController(text: '365');
  bool _emailNotifications = true;
  bool _surveyAlerts = true;
  bool _conversionErrorsOnly = false;
  bool _enableAutoProcessing = true;
  bool _anonymizeUserData = true;
  bool _encryptedBackups = true;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _conversionThresholdController.dispose();
    _autoReviewConfidenceController.dispose();
    _retentionController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_profileFormKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile changes saved.')));
    }
  }

  void _saveSettings() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Settings saved.')));
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon with gradient background
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.error, Color(0xFFE74C3C)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.error.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),

                // Title
                Text(
                  'Confirm Logout',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: _brandDeep,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),

                // Message
                Text(
                  'Are you sure you want to log out of your account? You will need to sign in again to access your surveys and data.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _mutedText,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _brandDeep,
                          side: BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _logout();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.error,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          elevation: 0,
                        ),
                        child: const Text('Log Out'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 900) {
          return _buildWebLayout(context);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // MOBILE LAYOUT (preserved from original — do not modify)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildMobileLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings & Preferences')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: _brandDeep,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your account information and preferences.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _mutedText,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [_heroStart, _heroEnd],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Text(
                            'DM',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daniel Mercado',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: _brandDeep,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Premium User • dmercado@talanscan.local',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: _mutedText),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 32, color: AppColors.divider),
                  Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final compact = constraints.maxWidth < 560;
                            final firstNameField = TextFormField(
                              controller: _firstNameController,
                              decoration: const InputDecoration(
                                labelText: 'First Name',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            );
                            final lastNameField = TextFormField(
                              controller: _lastNameController,
                              decoration: const InputDecoration(
                                labelText: 'Last Name',
                                prefixIcon: Icon(
                                  Icons.person_outline,
                                  size: 20,
                                ),
                              ),
                              validator: (value) =>
                                  value == null || value.isEmpty
                                  ? 'Required'
                                  : null,
                            );
                            if (compact) {
                              return Column(
                                children: [
                                  firstNameField,
                                  const SizedBox(height: 14),
                                  lastNameField,
                                ],
                              );
                            }
                            return Row(
                              children: [
                                Expanded(child: firstNameField),
                                const SizedBox(width: 16),
                                Expanded(child: lastNameField),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (!value.contains('@')) {
                              return 'Enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _genderController,
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            prefixIcon: Icon(Icons.boy_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            prefixIcon: Icon(Icons.phone_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _saveProfile,
                                style: FilledButton.styleFrom(
                                  backgroundColor: _heroEnd,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Save Changes'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  _firstNameController.text = 'Daniel';
                                  _lastNameController.text = 'Mercado';
                                  _emailController.text =
                                      'dmercado@talanscan.local';
                                  _phoneController.text = '+1 (555) 000-0000';
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Changes canceled.'),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: _brandDeep,
                                  side: BorderSide(color: _heroEnd),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Password & Security',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _brandDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Last changed 90 days ago',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedText),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Change password flow is a placeholder.',
                          ),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _heroEnd,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.key_outlined, size: 18),
                    label: const Text('Change Password'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Two-Factor Authentication',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: _brandDeep,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enhance your account security with 2FA.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: _mutedText),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('2FA setup is a placeholder.'),
                        ),
                      );
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: _heroEnd,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.shield_outlined, size: 18),
                    label: const Text('Enable 2FA'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 760;
                final cardSpacing = const SizedBox(height: 16);
                final cards = [

                  _buildPreferenceCard(
                    title: 'Notifications',
                    subtitle: 'Manage how and when you receive notifications.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: _heroEnd,
                          title: const Text('Email Notifications'),
                          value: _emailNotifications,
                          onChanged: (value) =>
                              setState(() => _emailNotifications = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: _heroEnd,
                          title: const Text('Survey Completion Alerts'),
                          value: _surveyAlerts,
                          onChanged: (value) =>
                              setState(() => _surveyAlerts = value),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saveSettings,
                          style: FilledButton.styleFrom(
                            backgroundColor: _heroEnd,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Preferences'),
                        ),
                      ],
                    ),
                  ),
                  _buildPreferenceCard(
                    title: 'System Information',
                    subtitle: 'View system and application details.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoRow('Application Version', '2.1.0'),
                        _buildInfoRow('Last Updated', '2024-06-15'),
                        _buildInfoRow('Database', 'Active'),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Check for updates is a placeholder.',
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _brandDeep,
                            side: BorderSide(color: _heroEnd),
                          ),
                          icon: const Icon(Icons.autorenew, size: 18),
                          label: const Text('Check Updates'),
                        ),
                      ],
                    ),
                  ),
                ];

                if (isWide) {
                  final rows = <Widget>[];
                  for (var i = 0; i < cards.length; i += 2) {
                    rows.add(Row(
                      children: [
                        Expanded(child: cards[i]),
                        if (i + 1 < cards.length) ...[
                          const SizedBox(width: 16),
                          Expanded(child: cards[i + 1]),
                        ],
                      ],
                    ));
                    if (i + 2 < cards.length) {
                      rows.add(const SizedBox(height: 16));
                    }
                  }
                  return Column(children: rows);
                }

                final columnChildren = <Widget>[];
                for (var i = 0; i < cards.length; i += 1) {
                  if (i > 0) {
                    columnChildren.add(cardSpacing);
                  }
                  columnChildren.add(cards[i]);
                }
                return Column(children: columnChildren);
              },
            ),


            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _confirmLogout, // Updated to use confirmation dialog
                icon: const Icon(Icons.logout_outlined, size: 18),
                label: const Text('Log Out'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: _brandDeep,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              color: _mutedText,
              height: 1.4,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _mutedText, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: _brandDeep,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WEB LAYOUT (modern dashboard, matches Surveys/Analytics/Forms design)
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildWebLayout(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Row(
        children: [
          WebSidebar(
            currentIndex: 4,
            onNavigate: (index) {
              if (index == 4) return;
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            onLogout: _confirmLogout,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(SpacingTokens.xxl),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1280),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _WebSettingsHeader(onLogout: _confirmLogout),
                      const SizedBox(height: SpacingTokens.xxl),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 980;
                          final leftColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _webCard(
                                child: _buildProfileSectionWeb(context),
                              ),
                              const SizedBox(height: SpacingTokens.lg),
                              LayoutBuilder(
                                builder: (context, innerConstraints) {
                                  final wideInner = innerConstraints.maxWidth > 560;
                                  final security = _webCard(
                                    child: _buildSecuritySectionWeb(),
                                  );
                                  final twoFa = _webCard(
                                    child: _build2FASectionWeb(),
                                  );
                                  if (wideInner) {
                                    return Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Expanded(child: security),
                                        const SizedBox(width: SpacingTokens.lg),
                                        Expanded(child: twoFa),
                                      ],
                                    );
                                  }
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      security,
                                      const SizedBox(height: SpacingTokens.lg),
                                      twoFa,
                                    ],
                                  );
                                },
                              ),
                            ],
                          );

                          final rightColumn = Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _webCard(child: _buildNotificationsSectionWeb()),
                              const SizedBox(height: SpacingTokens.lg),
                              _webCard(child: _buildSystemInfoSectionWeb()),
                            ],
                          );

                          if (wide) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: leftColumn),
                                const SizedBox(width: SpacingTokens.lg),
                                Expanded(flex: 2, child: rightColumn),
                              ],
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              leftColumn,
                              const SizedBox(height: SpacingTokens.lg),
                              rightColumn,
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: SpacingTokens.xxl),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _webCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _webSectionTitle(String title, {String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _headingText,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _bodyText,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProfileSectionWeb(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_tealLight, _tealDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text(
                  'DM',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daniel Mercado',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _headingText,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Premium User • dmercado@talanscan.local',
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: _bodyText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Divider(height: 32, color: _border),
        Form(
          key: _profileFormKey,
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 480;
                  final firstNameField = TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First Name',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  );
                  final lastNameField = TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last Name',
                      prefixIcon: Icon(Icons.person_outline, size: 20),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? 'Required' : null,
                  );
                  if (compact) {
                    return Column(
                      children: [
                        firstNameField,
                        const SizedBox(height: 14),
                        lastNameField,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: firstNameField),
                      const SizedBox(width: 16),
                      Expanded(child: lastNameField),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  prefixIcon: Icon(Icons.email_outlined, size: 20),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Required';
                  }
                  if (!value.contains('@')) {
                    return 'Enter a valid email';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _genderController,
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  prefixIcon: Icon(Icons.boy_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _saveProfile,
                      style: FilledButton.styleFrom(
                        backgroundColor: _iconTeal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Save Changes'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _firstNameController.text = 'Daniel';
                        _lastNameController.text = 'Mercado';
                        _emailController.text = 'dmercado@talanscan.local';
                        _phoneController.text = '+1 (555) 000-0000';
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Changes canceled.')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _headingText,
                        side: BorderSide(color: _iconTeal),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySectionWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _webSectionTitle('Password & Security', subtitle: 'Last changed 90 days ago'),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Change password flow is a placeholder.')),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: _iconTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.key_outlined, size: 18),
          label: const Text('Change Password'),
        ),
      ],
    );
  }

  Widget _build2FASectionWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _webSectionTitle(
          'Two-Factor Authentication',
          subtitle: 'Enhance your account security with 2FA.',
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('2FA setup is a placeholder.')),
            );
          },
          style: FilledButton.styleFrom(
            backgroundColor: _iconTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.shield_outlined, size: 18),
          label: const Text('Enable 2FA'),
        ),
      ],
    );
  }

  Widget _buildNotificationsSectionWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _webSectionTitle(
          'Notifications',
          subtitle: 'Manage how and when you receive notifications.',
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: _iconTeal,
          title: const Text('Email Notifications'),
          value: _emailNotifications,
          onChanged: (value) => setState(() => _emailNotifications = value),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          activeThumbColor: _iconTeal,
          title: const Text('Survey Completion Alerts'),
          value: _surveyAlerts,
          onChanged: (value) => setState(() => _surveyAlerts = value),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: _saveSettings,
          style: FilledButton.styleFrom(
            backgroundColor: _iconTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Save Preferences'),
        ),
      ],
    );
  }

  Widget _buildSystemInfoSectionWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _webSectionTitle(
          'System Information',
          subtitle: 'View system and application details.',
        ),
        const SizedBox(height: 16),
        _webInfoRow('Application Version', '2.1.0'),
        _webInfoRow('Last Updated', '2024-06-15'),
        _webInfoRow('Database', 'Active'),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Check for updates is a placeholder.')),
            );
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: _headingText,
            side: const BorderSide(color: _iconTeal),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.autorenew, size: 18),
          label: const Text('Check Updates'),
        ),
      ],
    );
  }

  Widget _webInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 12.5, color: _bodyText, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
              color: _headingText,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WEB WIDGETS
// ═══════════════════════════════════════════════════════════════════════════

class _WebSettingsHeader extends StatelessWidget {
  const _WebSettingsHeader({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SpacingTokens.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _SettingsPageState._tealLight,
            _SettingsPageState._tealDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _SettingsPageState._tealDark.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Settings & Preferences',
                  style: GoogleFonts.inter(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Manage your account information and preferences.',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
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
