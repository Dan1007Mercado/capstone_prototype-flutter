import 'package:flutter/material.dart';
import 'package:capstone_prototype/pages/auth/login.dart' as auth;
import '../../pages/auth/login.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const Color _heroStart = Color(0xFF82E1E6);
  static const Color _heroEnd = Color(0xFF1FB9C1);
  static const Color _brandDeep = Color(0xFF153D4A);
  static const Color _mutedText = Color(0xFF7D8790);

  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Daniel');
  final _lastNameController = TextEditingController(text: 'Mercado');
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

  void _logout() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    title: 'AI Conversion',
                    subtitle:
                        'Configure AI Engine workflow and review thresholds for document conversion.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _conversionThresholdController,
                          decoration: const InputDecoration(
                            labelText: 'Confidence Threshold (%)',
                            prefixIcon: Icon(Icons.tune_outlined, size: 20),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _autoReviewConfidenceController,
                          decoration: const InputDecoration(
                            labelText: 'Auto-Review Confidence',
                            prefixIcon: Icon(
                              Icons.auto_awesome_outlined,
                              size: 20,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Enable Auto-Processing'),
                          value: _enableAutoProcessing,
                          onChanged: (value) =>
                              setState(() => _enableAutoProcessing = value),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saveSettings,
                          style: FilledButton.styleFrom(
                            backgroundColor: _heroEnd,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Settings'),
                        ),
                      ],
                    ),
                  ),
                  _buildPreferenceCard(
                    title: 'Notifications',
                    subtitle: 'Manage how and when you receive notifications.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Email Notifications'),
                          value: _emailNotifications,
                          onChanged: (value) =>
                              setState(() => _emailNotifications = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Survey Completion Alerts'),
                          value: _surveyAlerts,
                          onChanged: (value) =>
                              setState(() => _surveyAlerts = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Conversion Errors Only'),
                          value: _conversionErrorsOnly,
                          onChanged: (value) =>
                              setState(() => _conversionErrorsOnly = value),
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
                    title: 'Data & Privacy',
                    subtitle: 'Manage data retention and privacy settings.',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextFormField(
                          controller: _retentionController,
                          decoration: const InputDecoration(
                            labelText: 'Data Retention Period (days)',
                            prefixIcon: Icon(
                              Icons.calendar_today_outlined,
                              size: 20,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Anonymize User Data'),
                          value: _anonymizeUserData,
                          onChanged: (value) =>
                              setState(() => _anonymizeUserData = value),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeColor: _heroEnd,
                          title: const Text('Encrypted Backups'),
                          value: _encryptedBackups,
                          onChanged: (value) =>
                              setState(() => _encryptedBackups = value),
                        ),
                        const SizedBox(height: 12),
                        FilledButton(
                          onPressed: _saveSettings,
                          style: FilledButton.styleFrom(
                            backgroundColor: _heroEnd,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Save Settings'),
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
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[1]),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: cards[2]),
                          const SizedBox(width: 16),
                          Expanded(child: cards[3]),
                        ],
                      ),
                    ],
                  );
                }

                return Column(
                  children: [
                    cards[0],
                    cardSpacing,
                    cards[1],
                    cardSpacing,
                    cards[2],
                    cardSpacing,
                    cards[3],
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _logout,
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
}