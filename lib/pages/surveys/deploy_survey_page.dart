import 'package:flutter/material.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class DeploySurveyPage extends StatefulWidget {
  const DeploySurveyPage({super.key});

  @override
  State<DeploySurveyPage> createState() => _DeploySurveyPageState();
}

class _DeploySurveyPageState extends State<DeploySurveyPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _targetController = TextEditingController(text: '250');
  String _template = 'Community Health Survey';
  DateTime? _startDate;
  DateTime? _endDate;

  // Color constants matching the reference design
  static const Color _tealDark = Color.fromARGB(255, 13, 232, 232);
  static const Color _tealLight = Color(0xFF2DD4CF);
  static const Color _iconTeal = Color(0xFF14B8A6);
  static const Color _mintChipBg = Color(0xFFDFF5F3);
  static const Color _pageBg = Color(0xFFF4F7F8);
  static const Color _cardWhite = Color(0xFFFFFFFF);
  static const Color _headingText = Color(0xFF0E2A2E);
  static const Color _bodyText = Color(0xFF7C8A90);
  static const Color _successGreen = Color(0xFF16A34A);
  static const Color _infoBlue = Color(0xFF2563EB);
  static const Color _border = Color(0xFFDDECEF);

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      backgroundColor: _pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _headingText,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Deploy New Survey',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _mintChipBg,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.info_outline, size: 14, color: _iconTeal),
                const SizedBox(width: 4),
                Text(
                  'Mock Form',
                  style: TextStyle(
                    color: _iconTeal,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _border.withValues(alpha: 0.5),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Hero Banner
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_tealLight, _tealDark],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.20),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Decorative circles
                    Positioned(
                      right: -40,
                      top: -70,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.17),
                        ),
                      ),
                    ),
                    Positioned(
                      left: -60,
                      bottom: -80,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.13),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Icon(
                                Icons.rocket_launch_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Create a Survey',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    'Launch a new survey experience with the same polished workflow.',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Colors.white
                                              .withValues(alpha: 0.90),
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Form Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section Header
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _mintChipBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.description_outlined,
                              size: 18,
                              color: _iconTeal,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Survey Information',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _headingText,
                                      letterSpacing: -0.1,
                                    ),
                              ),
                              Text(
                                'Mock deploy form with frontend-only state updates',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: _bodyText,
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Survey Title
                      TextFormField(
                        controller: _titleController,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _headingText,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Survey Title',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          hintText: 'Enter survey title',
                          hintStyle: TextStyle(
                            color: _bodyText.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.title_rounded,
                              size: 20,
                              color: _iconTeal,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FCFD),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _iconTeal,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE11D48)),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Survey title is required'
                                : null,
                      ),
                      const SizedBox(height: 14),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _headingText,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Description',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          hintText: 'Describe your survey purpose',
                          hintStyle: TextStyle(
                            color: _bodyText.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.only(bottom: 48),
                            child: Icon(
                              Icons.article_rounded,
                              size: 20,
                              color: _iconTeal,
                            ),
                          ),
                          alignLabelWithHint: true,
                          filled: true,
                          fillColor: const Color(0xFFF8FCFD),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _iconTeal,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE11D48)),
                          ),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                                ? 'Description is required'
                                : null,
                      ),
                      const SizedBox(height: 14),

                      // Template Selection
                      DropdownButtonFormField<String>(
                        value: _template,
                        items: const [
                          DropdownMenuItem(
                            value: 'Community Health Survey',
                            child: Text('Community Health Survey'),
                          ),
                          DropdownMenuItem(
                            value: 'Educational Satisfaction Survey',
                            child: Text('Educational Satisfaction Survey'),
                          ),
                          DropdownMenuItem(
                            value: 'Barangay Assessment Form',
                            child: Text('Barangay Assessment Form'),
                          ),
                          DropdownMenuItem(
                            value: 'Healthcare Access Survey',
                            child: Text('Healthcare Access Survey'),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => _template = value ?? _template),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _headingText,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Template Selection',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.dashboard_rounded,
                              size: 20,
                              color: _iconTeal,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FCFD),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _iconTeal,
                              width: 1.5,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _bodyText,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 14),

                      // Target Response Count
                      DropdownButtonFormField<String>(
                        value: _targetController.text,
                        items: const [
                          DropdownMenuItem(value: '100', child: Text('100')),
                          DropdownMenuItem(value: '250', child: Text('250')),
                          DropdownMenuItem(value: '500', child: Text('500')),
                          DropdownMenuItem(value: '1000', child: Text('1000')),
                        ],
                        onChanged: (value) => setState(
                            () => _targetController.text = value ?? '250'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _headingText,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Target Response Count',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          prefixIcon: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(
                              Icons.people_alt_rounded,
                              size: 20,
                              color: _iconTeal,
                            ),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF8FCFD),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: _iconTeal,
                              width: 1.5,
                            ),
                          ),
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: _bodyText,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      const SizedBox(height: 14),

                      // Date Fields
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final wide = constraints.maxWidth > 760;

                          if (wide) {
                            return Row(
                              children: [
                                Expanded(
                                  child: _DateField(
                                    label: 'Start Date',
                                    value: _startDate,
                                    icon: Icons.calendar_today_rounded,
                                    onTap: () async {
                                      final picked = await _pickDate(
                                          context,
                                          _startDate ?? DateTime.now());
                                      if (picked != null)
                                        setState(() => _startDate = picked);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DateField(
                                    label: 'End Date',
                                    value: _endDate,
                                    icon: Icons.event_rounded,
                                    onTap: () async {
                                      final picked = await _pickDate(
                                        context,
                                        _endDate ??
                                            DateTime.now()
                                                .add(const Duration(days: 7)),
                                      );
                                      if (picked != null)
                                        setState(() => _endDate = picked);
                                    },
                                  ),
                                ),
                              ],
                            );
                          }

                          return Column(
                            children: [
                              _DateField(
                                label: 'Start Date',
                                value: _startDate,
                                icon: Icons.calendar_today_rounded,
                                onTap: () async {
                                  final picked = await _pickDate(
                                      context, _startDate ?? DateTime.now());
                                  if (picked != null)
                                    setState(() => _startDate = picked);
                                },
                              ),
                              const SizedBox(height: 12),
                              _DateField(
                                label: 'End Date',
                                value: _endDate,
                                icon: Icons.event_rounded,
                                onTap: () async {
                                  final picked = await _pickDate(
                                    context,
                                    _endDate ??
                                        DateTime.now()
                                            .add(const Duration(days: 7)),
                                  );
                                  if (picked != null)
                                    setState(() => _endDate = picked);
                                },
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Divider
                      Container(
                        height: 1,
                        color: _border,
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _bodyText,
                              side: const BorderSide(color: _border),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () {
                              if (!_formKey.currentState!.validate()) return;
                              final deployed = appState.deploySurvey(
                                title: _titleController.text.trim(),
                                description:
                                    _descriptionController.text.trim(),
                                templateName: _template,
                                targetResponses: _targetController.text,
                                startDate: _startDate ?? DateTime.now(),
                                endDate: _endDate ??
                                    DateTime.now()
                                        .add(const Duration(days: 7)),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${deployed.name} deployed successfully',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.rocket_launch_rounded, size: 16),
                            label: const Text('Deploy Survey'),
                            style: FilledButton.styleFrom(
                              backgroundColor: _iconTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(BuildContext context, DateTime initial) {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2025),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: _iconTeal,
                ),
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final DateTime? value;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              size: 20,
              color: const Color(0xFF14B8A6),
            ),
          ),
          suffixIcon: const Padding(
            padding: EdgeInsets.all(12),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: Color(0xFF7C8A90),
            ),
          ),
          filled: true,
          fillColor: const Color(0xFFF8FCFD),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDECEF)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFDDECEF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF14B8A6),
              width: 1.5,
            ),
          ),
        ),
        child: Text(
          value == null
              ? 'Select date'
              : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}',
          style: TextStyle(
            color: value == null
                ? const Color(0xFF7C8A90).withValues(alpha: 0.6)
                : const Color(0xFF0E2A2E),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}