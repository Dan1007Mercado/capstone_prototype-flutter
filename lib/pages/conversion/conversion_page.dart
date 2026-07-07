import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'review_extracted_components_page.dart';

class SurveyConverterPage extends StatefulWidget {
  const SurveyConverterPage({
    super.key,
    this.onNotifications,
    this.onSettings,
    this.unreadNotifications = 0,
  });

  final VoidCallback? onNotifications;
  final VoidCallback? onSettings;
  final int unreadNotifications;

  @override
  State<SurveyConverterPage> createState() => _SurveyConverterPageState();
}

class _SurveyConverterPageState extends State<SurveyConverterPage> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);
    final files = appState.uploadedConversionFiles;
    final hasFiles = files.isNotEmpty;
    final isBusy = appState.surveyExtractionRunning || _isProcessing;

    return Scaffold(
      backgroundColor: AppPalette.teal50,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final theme = context.appTheme;
          final maxWidth = constraints.maxWidth >= 920 ? 960.0 : 560.0;
          final horizontalPadding = constraints.maxWidth >= 760 ? 24.0 : 16.0;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        16,
                        horizontalPadding,
                        0,
                      ),
                      child: PageHeader(
                        title: 'Survey Converter',
                        onNotifications: widget.onNotifications,
                        onSettings: widget.onSettings,
                        unreadNotifications: widget.unreadNotifications,
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalPadding,
                        20,
                        horizontalPadding,
                        0,
                      ),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 26),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppPalette.teal300, AppPalette.teal600],
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(18)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Survey Converter',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload questionnaire images or PDFs and start AI-powered extraction.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.88),
                                  ),
                            ),
                            const SizedBox(height: 18),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: [
                                SizedBox(
                                  height: 44,
                                  child: FilledButton.icon(
                                    onPressed: _pickImages,
                                    icon: const Icon(Icons.photo_library_outlined, size: 18),
                                    label: const Text('Upload Images'),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size(160, 44),
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppPalette.teal700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 44,
                                  child: OutlinedButton.icon(
                                    onPressed: _pickPdf,
                                    icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                                    label: const Text('Upload PDF'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(160, 44),
                                      padding: const EdgeInsets.symmetric(horizontal: 18),
                                      backgroundColor: Colors.white.withValues(alpha: 0.14),
                                      foregroundColor: Colors.white,
                                      side: BorderSide(color: Colors.white.withValues(alpha: 0.28)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  18,
                  horizontalPadding,
                  24,
                ),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: SurfaceCard(
                        color: Colors.white,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                              title: 'Selected Sources',
                              subtitle: 'Review uploaded files before starting the extraction flow.',
                            ),
                            const SizedBox(height: 16),
                            LayoutBuilder(
                              builder: (context, rowConstraints) {
                                final isNarrow = rowConstraints.maxWidth < 420;
                                return Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    AccentChip(
                                      label: '${files.length} selected items',
                                      color: AppPalette.teal700,
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: OutlinedButton.icon(
                                        onPressed: _pickImages,
                                        icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                                        label: const Text('Add Images'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppPalette.teal700,
                                          side: BorderSide(color: theme.outlineVariant),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 40,
                                      child: FilledButton.icon(
                                        onPressed: _pickPdf,
                                        icon: const Icon(Icons.attach_file_outlined, size: 18),
                                        label: const Text('Add PDF'),
                                        style: FilledButton.styleFrom(
                                          backgroundColor: AppPalette.teal50,
                                          foregroundColor: AppPalette.teal700,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          textStyle: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                            if (appState.surveyExtractionRunning)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                margin: const EdgeInsets.only(bottom: 14),
                                decoration: BoxDecoration(
                                  color: theme.secondary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: theme.secondary.withValues(alpha: 0.24)),
                                ),
                                child: Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        appState.surveyExtractionStatus,
                                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (!hasFiles)
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.folder_open_outlined, size: 48, color: theme.onSurfaceVariant),
                                      const SizedBox(height: 12),
                                      Text(
                                        'No files selected yet. Add one or more image files or a PDF to begin.',
                                        style: TextStyle(color: theme.onSurfaceVariant),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else ...[
                              Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  for (final file in files)
                                    file.isPdf
                                        ? _PdfFileCard(
                                            file: file,
                                            onRemove: () => _removeFile(appState, file.id),
                                          )
                                        : _ImageFileCard(
                                            file: file,
                                            onRemove: () => _removeFile(appState, file.id),
                                          ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: _pickImages,
                                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 18),
                                      label: const Text('Add Images'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: theme.primary,
                                        side: BorderSide(color: theme.outlineVariant),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: FilledButton.icon(
                                      onPressed: isBusy ? null : () => _proceed(appState),
                                      icon: const Icon(Icons.play_arrow_outlined, size: 18),
                                      label: const Text('Start Extraction'),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: AppPalette.teal600,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _pickImages() async {
    final appState = AppStateScope.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null || !mounted) return;

    final files = result.files
        .where((file) => file.name.isNotEmpty)
        .map(
          (file) => ConversionFileItem(
            id: '${file.name}-${DateTime.now().microsecondsSinceEpoch}',
            name: file.name,
            type: 'image',
            path: kIsWeb ? null : file.path,
            bytes: file.bytes,
          ),
        )
        .toList();

    if (files.isNotEmpty) {
      appState.addUploadedConversionFiles(files);
    }
  }

  Future<void> _pickPdf() async {
    final appState = AppStateScope.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
      withData: true,
      allowMultiple: true,
    );

    if (result == null || !mounted) return;

    final files = result.files
        .where((file) => file.name.isNotEmpty)
        .map(
          (file) => ConversionFileItem(
            id: '${file.name}-${DateTime.now().microsecondsSinceEpoch}',
            name: file.name,
            type: 'pdf',
            path: kIsWeb ? null : file.path,
            bytes: file.bytes,
          ),
        )
        .toList();

    if (files.isNotEmpty) {
      appState.addUploadedConversionFiles(files);
    }
  }

  void _removeFile(AppState appState, String id) {
    appState.removeUploadedConversionFile(id);
  }

  Future<void> _showPopup({required String title, required String message, String actionLabel = 'OK'}) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  Future<void> _proceed(AppState appState) async {
    if (appState.uploadedConversionFiles.isEmpty) {
      await _showPopup(
        title: 'No files selected',
        message: 'Please choose at least one image or PDF before starting extraction.',
      );
      return;
    }

    if (appState.surveyExtractionRunning || _isProcessing) {
      await _showPopup(
        title: 'Extraction in progress',
        message: 'A conversion is already running. Please wait for it to finish before starting another.',
      );
      return;
    }

    final choice = await showDialog<_ProcessingMode>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('How would you like to process the extraction?'),
          content: const Text(
            'Choose to run the extraction in the background or wait and observe the progress on this screen.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, _ProcessingMode.wait),
              child: const Text('Wait Until Completed'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, _ProcessingMode.background),
              child: const Text('Run in Background'),
            ),
          ],
        );
      },
    );

    if (!mounted || choice == null) return;

    if (choice == _ProcessingMode.background) {
      setState(() => _isProcessing = false);
      unawaited(appState.startSurveyExtraction(fileCount: appState.uploadedConversionFiles.length).then((_) {
        if (!mounted) return;
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(builder: (_) => const ReviewExtractedComponentsPage()),
        );
      }));
      await _showPopup(
        title: 'Background conversion started',
        message: 'Extraction is running in the background. When it completes, you will be taken to the review screen.',
        actionLabel: 'Got it',
      );
      return;
    }

    setState(() => _isProcessing = true);
    try {
      await appState.startSurveyExtraction(fileCount: appState.uploadedConversionFiles.length);
      if (!mounted) return;
      await _showPopup(
        title: 'Extraction complete',
        message: 'Extraction finished successfully. Review the extracted components next.',
      );
      if (!mounted) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const ReviewExtractedComponentsPage()),
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}

enum _ProcessingMode { wait, background }

class _ImageFileCard extends StatelessWidget {
  const _ImageFileCard({required this.file, required this.onRemove});

  final ConversionFileItem file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 96,
            decoration: BoxDecoration(
              color: theme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: file.bytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      file.bytes!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      errorBuilder: (_, _, _) => Center(
                        child: Icon(Icons.image_outlined, color: AppPalette.teal700, size: 28),
                      ),
                    ),
                  )
                : Center(
                    child: Icon(Icons.image_outlined, color: AppPalette.teal700, size: 28),
                  ),
          ),
          const SizedBox(height: 10),
          Text(
            file.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: theme.onSurface,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Image source',
            style: TextStyle(color: theme.onSurfaceVariant, fontSize: 12),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRemove,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                foregroundColor: theme.secondary,
              ),
              child: const Text('Remove'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PdfFileCard extends StatelessWidget {
  const _PdfFileCard({required this.file, required this.onRemove});

  final ConversionFileItem file;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.appTheme;
    return Container(
      width: 220,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppPalette.teal700.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined, color: AppPalette.teal700, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text('PDF document', style: TextStyle(color: theme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          IconButton(onPressed: onRemove, icon: Icon(Icons.close_outlined, size: 18, color: theme.onSurfaceVariant)),
        ],
      ),
    );
  }
}