import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class WebSidebar extends StatelessWidget {
  const WebSidebar({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    required this.onLogout,
  });

  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final VoidCallback onLogout;

  static const Color _primary = Color(0xFF2563EB); // From Laravel prototype
  static const Color _bgLight = Color(0xFFF8FAFC);
  static const Color _textMain = Color(0xFF1E293B);
  static const Color _textMuted = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: _bgLight,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _SidebarItem(
                  icon: Icons.home_outlined,
                  label: 'Overview',
                  isSelected: currentIndex == 0,
                  onTap: () => onNavigate(0),
                ),
                _SidebarItem(
                  icon: Icons.assignment,
                  label: 'Surveys',
                  isSelected: currentIndex == 1,
                  onTap: () => onNavigate(1),
                ),
                _SidebarItem(
                  icon: Icons.auto_awesome,
                  label: 'Online Forms',
                  isSelected: currentIndex == 3,
                  onTap: () => onNavigate(3),
                ),
                _SidebarItem(
                  icon: Icons.description_outlined,
                  label: 'Templates',
                  isSelected: currentIndex == 2,
                  onTap: () => onNavigate(2),
                ),
                _SidebarItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  isSelected: currentIndex == 4,
                  onTap: () => onNavigate(4),
                ),
              ],
            ),
          ),
          // Logout Button at the bottom
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 36,
            child: Image.asset(
              'assets/images/talaanscan.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'TalaanScan',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: InkWell(
        onTap: () => _showLogoutConfirmation(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.red.withOpacity(0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.logout_rounded,
                color: Colors.red,
                size: 20,
              ),
              const SizedBox(width: 16),
              Text(
                'Log Out',
                style: GoogleFonts.inter(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: Colors.white,
          child: Container(
            width: 440, // Set a fixed width
            height: 280, // Set a fixed height > width (560 > 440)
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.max, // Important: Fill the container height
              mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push top content up, buttons down
              children: [
                // Top Section: Icon and Messages
                Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Confirm Logout',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _textMain,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Are you sure you want to log out of your account? You will need to sign in again to access your surveys and data.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: _textMuted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
                
                // Bottom Section: Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _textMain,
                          side: const BorderSide(color: Color(0xFFE2E8F0)),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: GoogleFonts.inter(
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
                          onLogout();
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          textStyle: GoogleFonts.inter(
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
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? WebSidebar._primary : WebSidebar._textMuted;
    final bgColor = isSelected ? WebSidebar._primary.withOpacity(0.1) : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 16),
              Text(
                label,
                style: GoogleFonts.inter(
                  color: isSelected ? WebSidebar._primary : WebSidebar._textMain,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
