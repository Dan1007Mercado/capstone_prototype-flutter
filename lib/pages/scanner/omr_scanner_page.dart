import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class OmrScannerPage extends StatefulWidget {
  const OmrScannerPage({
    super.key,
    required this.survey,
  });

  final SurveyRecord survey;

  @override
  State<OmrScannerPage> createState() => _OmrScannerPageState();
}

class _OmrScannerPageState extends State<OmrScannerPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final List<_ScanImage> _images = [];
  final List<_ScanStage> _stages = [
    _ScanStage('Detecting Pages'),
    _ScanStage('Reading Bubbles'),
    _ScanStage('Validating Answers'),
    _ScanStage('Building Output'),
  ];

  Timer? _timer;
  double _progress = 0;
  bool _isProcessing = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OMR Scanner'),
        actions: [
          if (appState.backgroundConversionRunning)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: AccentChip(
                  label: 'Background Active',
                  color: AppColors.warning,
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Selected Survey',
                  subtitle: 'Choose a survey first, then capture or upload OMR pages.',
                ),
                const SizedBox(height: 16),
                _SurveyInfoCard(survey: widget.survey),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(
                  title: 'Capture Pages',
                  subtitle: 'Capture one page at a time with the camera, or upload multiple images at once.',
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: _capturePage,
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(_supportsCamera ? 'Open Camera' : 'Camera Unsupported'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _uploadImages,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: const Text('Upload Images'),
                    ),
                    TextButton(
                      onPressed: _images.isEmpty ? null : _clearImages,
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_images.isEmpty)
                  const Text(
                    'No pages selected yet. Use the camera repeatedly until you finish, or upload a batch of images.',
                    style: TextStyle(color: AppColors.textSecondary),
                  )
                else
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final columns = width >= 1000
                          ? 4
                          : width >= 720
                              ? 3
                              : width >= 480
                                  ? 2
                                  : 1;
                      final cardWidth = (width - (columns - 1) * 12) / columns;

                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (var i = 0; i < _images.length; i++)
                            SizedBox(
                              width: cardWidth,
                              child: _ScanImageCard(
                                image: _images[i],
                                index: i + 1,
                                onRemove: () => _removeImage(i),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Text(
                      '${_images.length} image${_images.length == 1 ? '' : 's'} selected',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                    const Spacer(),
                    FilledButton(
                      onPressed: _images.isEmpty || _isProcessing ? null : _promptProcessingMode,
                      child: const Text('Continue'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 20),
            SurfaceCard(
              child: _ProcessingPanel(progress: _progress, stages: _stages),
            ),
          ],
        ],
      ),
    );
  }

  bool get _supportsCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<void> _capturePage() async {
    if (!_supportsCamera) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera capture is not available on this device. Use Upload Images instead.'),
        ),
      );
      return;
    }

    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
    );
    if (!mounted || image == null) return;

    setState(() {
      _images.add(_ScanImage(path: image.path, name: image.name));
    });
  }

  Future<void> _uploadImages() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Image upload is not available in this web preview.'),
          ),
        );
      }
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: false,
      dialogTitle: 'Upload OMR Images',
    );
    if (!mounted || result == null) return;

    setState(() {
      for (final file in result.files) {
        final path = file.path;
        if (path == null) continue;
        if (_images.any((image) => image.path == path)) continue;
        _images.add(
          _ScanImage(
            path: path,
            name: file.name,
          ),
        );
      }
    });
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  void _clearImages() {
    setState(_images.clear);
  }

  Future<void> _promptProcessingMode() async {
    final choice = await showDialog<_ProcessingMode>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          title: const Text('Process Scanner Output'),
          content: const Text(
            'Would you like to wait for the scan to finish or run it in the background while you continue using the app?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, _ProcessingMode.wait),
              child: const Text('Wait'),
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
      AppStateScope.of(context).addNotification(
        title: 'OMR Scan Queued',
        subtitle: '${widget.survey.name} scan is running in the background.',
        icon: Icons.document_scanner_outlined,
      );
      AppStateScope.of(context).startBackgroundConversion();
      Navigator.of(context).pop();
      return;
    }

    _startProcessing();
  }

  void _startProcessing() {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _progress = 0;
      for (final stage in _stages) {
        stage.percent = 0;
      }
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _progress = (_progress + 0.25).clamp(0.0, 1.0);
        final activeIndex = (_progress * _stages.length).floor().clamp(0, _stages.length - 1);

        for (var i = 0; i < _stages.length; i++) {
          if (i < activeIndex) {
            _stages[i].percent = 100;
          } else if (i == activeIndex) {
            _stages[i].percent = (_progress * 100).clamp(0, 100);
          }
        }

        if (_progress >= 1) {
          timer.cancel();
          _isProcessing = false;
          AppStateScope.of(context).addNotification(
            title: 'OMR Scan Completed',
            subtitle: '${widget.survey.name} images were processed successfully.',
            icon: Icons.fact_check_outlined,
          );
        }
      });
    });
  }
}

class _SurveyInfoCard extends StatelessWidget {
  const _SurveyInfoCard({required this.survey});

  final SurveyRecord survey;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            survey.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          DetailRow(label: 'Survey ID', value: survey.id),
          const SizedBox(height: 8),
          DetailRow(label: 'Template', value: survey.templateUsed),
          const SizedBox(height: 8),
          DetailRow(label: 'Category', value: survey.category),
          const SizedBox(height: 8),
          DetailRow(label: 'Status', value: shortStatusLabel(survey.status)),
        ],
      ),
    );
  }
}

class _ScanImageCard extends StatelessWidget {
  const _ScanImageCard({
    required this.image,
    required this.index,
    required this.onRemove,
  });

  final _ScanImage image;
  final int index;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.inputBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 118,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.image_outlined, size: 36, color: AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Page $index',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          Text(
            image.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onRemove,
              child: const Text('Remove'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProcessingPanel extends StatelessWidget {
  const _ProcessingPanel({
    required this.progress,
    required this.stages,
  });

  final double progress;
  final List<_ScanStage> stages;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Processing Scanner Output', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text(
          'The scanner is extracting and validating OMR responses.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: progress == 0 ? null : progress),
        const SizedBox(height: 18),
        for (final stage in stages) ...[
          _ProcessingStageRow(
            title: stage.title,
            percent: stage.percent,
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _ProcessingStageRow extends StatelessWidget {
  const _ProcessingStageRow({
    required this.title,
    required this.percent,
  });

  final String title;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 140,
          child: LinearProgressIndicator(
            value: percent <= 0 ? null : percent / 100,
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 48,
          child: Text(
            '${percent.clamp(0, 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

class _ScanImage {
  _ScanImage({
    required this.path,
    required this.name,
  });

  final String path;
  final String name;
}

class _ScanStage {
  _ScanStage(this.title);

  final String title;
  double percent = 0;
}

enum _ProcessingMode { wait, background }
