import 'package:flutter/material.dart';

import '../../pages/auth/login.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _profileFormKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController(text: 'Daniel');
  final _lastNameController = TextEditingController(text: 'Mercado');
  final _emailController = TextEditingController(text: 'dmercado@talanscan.local');
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile changes saved.')),
      );
    }
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved.')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Account Profile',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage your account information and preferences.',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Center(
                          child: Text(
                            'DM',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 22,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Daniel Mercado', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            SizedBox(height: 4),
                            Text(
                              'Premium User • dmercado@talanscan.local',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.inputBorder),
                  Form(
                    key: _profileFormKey,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(labelText: 'First Name'),
                                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(labelText: 'Last Name'),
                                validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email Address'),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (!value.contains('@')) return 'Enter a valid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(labelText: 'Phone Number'),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: _saveProfile,
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
                  const Text('Password & Security', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                  const Text('Last changed 90 days ago', style: TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Change password flow is a placeholder.')),
                      );
                    },
                    icon: const Icon(Icons.key_outlined),
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
                  const Text('Two-Factor Authentication', style: TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  const Text(
                    'Enhance your account security with 2FA.',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('2FA setup is a placeholder.')),
                      );
                    },
                    icon: const Icon(Icons.shield_outlined),
                    label: const Text('Enable 2FA'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(builder: (context, constraints) {
              final isWide = constraints.maxWidth > 760;
              final cardSpacing = const SizedBox(height: 16);
              final cards = [
                _buildPreferenceCard(
                  title: 'AI Conversion',
                  subtitle: 'Configure AI Engine workflow and review thresholds for document conversion.',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _conversionThresholdController,
                        decoration: const InputDecoration(labelText: 'Confidence Threshold (%)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _autoReviewConfidenceController,
                        decoration: const InputDecoration(labelText: 'Auto-Review Confidence'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Enable Auto-Processing'),
                        value: _enableAutoProcessing,
                        onChanged: (value) => setState(() => _enableAutoProcessing = value),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _saveSettings,
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
                        title: const Text('Email Notifications'),
                        value: _emailNotifications,
                        onChanged: (value) => setState(() => _emailNotifications = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Survey Completion Alerts'),
                        value: _surveyAlerts,
                        onChanged: (value) => setState(() => _surveyAlerts = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Conversion Errors Only'),
                        value: _conversionErrorsOnly,
                        onChanged: (value) => setState(() => _conversionErrorsOnly = value),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _saveSettings,
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
                        decoration: const InputDecoration(labelText: 'Data Retention Period (days)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Anonymize User Data'),
                        value: _anonymizeUserData,
                        onChanged: (value) => setState(() => _anonymizeUserData = value),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Encrypted Backups'),
                        value: _encryptedBackups,
                        onChanged: (value) => setState(() => _encryptedBackups = value),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _saveSettings,
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
                            const SnackBar(content: Text('Check for updates is a placeholder.')),
                          );
                        },
                        icon: const Icon(Icons.autorenew),
                        label: const Text('Check Updates'),
                      ),
                    ],
                  ),
                ),
              ];

              if (isWide) {
                return Column(
                  children: [
                    Row(children: [Expanded(child: cards[0]), const SizedBox(width: 16), Expanded(child: cards[1])]),
                    const SizedBox(height: 16),
                    Row(children: [Expanded(child: cards[2]), const SizedBox(width: 16), Expanded(child: cards[3])]),
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
            }),
            const SizedBox(height: 30),
            FilledButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout_outlined),
              label: const Text('Log Out'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreferenceCard({required String title, required String subtitle, required Widget child}) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, height: 1.4)),
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
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
