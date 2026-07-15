import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      backgroundColor: AppPalette.teal50,
      appBar: AppBar(
        title: const Text('OMR Scanner'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.tealDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppPalette.teal50, Color(0xFFF8FBFC)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
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
                          icon: const Icon(Icons.camera_alt_outlined, size: 18),
                          label: Text(_supportsCamera ? 'Open Camera' : 'Camera Unsupported'),
                        ),
                        OutlinedButton.icon(
                          onPressed: _uploadImages,
                          icon: const Icon(Icons.upload_file_outlined, size: 18),
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.image_outlined, size: 48, color: AppColors.textDisabled),
                              SizedBox(height: 12),
                              Text(
                                'No pages selected yet. Use the camera repeatedly until you finish, or upload a batch of images.',
                                style: TextStyle(color: AppColors.textSecondary),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
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
                                    onReviewChanged: () {
                                      setState(() {
                                        _images[i].reviewed = !_images[i].reviewed;
                                      });
                                    },
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${_images.length} image${_images.length == 1 ? '' : 's'} selected • ${_images.where((img) => img.reviewed).length} marked for review',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
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
        ),
      ),
    );
  }

  // NOTE: the live camera + simulated document-detection overlay is currently
  // implemented for Android/iOS only. Other platforms fall back to Upload.
  bool get _supportsCamera =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> _capturePage() async {
    if (!mounted) return;
    final result = await Navigator.of(context).push<List<_ScanImage>>(
      MaterialPageRoute(
        builder: (_) => _CameraScannerPage(
          initialImages: _images,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _images.clear();
        _images.addAll(result);
      });
    }
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
    // Filter only reviewed images
    final reviewedImages = _images.where((img) => img.reviewed).toList();

    final choice = await showDialog<_ProcessingMode>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Process Scanner Output'),
          content: Text(
            'Processing ${reviewedImages.length} image${reviewedImages.length == 1 ? '' : 's'}.\n\nWould you like to wait for the scan to finish or run it in the background?',
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
    return SurfaceCard(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            survey.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.tealDark),
          ),
          const SizedBox(height: 10),
          DetailRow(label: 'Survey ID', value: survey.id),
          const SizedBox(height: 6),
          DetailRow(label: 'Template', value: survey.templateUsed),
          const SizedBox(height: 6),
          DetailRow(label: 'Category', value: survey.category),
          const SizedBox(height: 6),
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
    required this.onReviewChanged,
  });

  final _ScanImage image;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onReviewChanged;

  String _getQualityLabel(ImageQuality quality) {
    return switch (quality) {
      ImageQuality.good => 'Good',
      ImageQuality.poor => 'Poor Quality',
      ImageQuality.notClear => 'Not Clear',
    };
  }

  Color _getQualityColor(ImageQuality quality) {
    return switch (quality) {
      ImageQuality.good => const Color(0xFF4CAF50),
      ImageQuality.poor => const Color(0xFFFF9800),
      ImageQuality.notClear => const Color(0xFFF44336),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: image.reviewed ? AppColors.primary : AppColors.divider,
          width: image.reviewed ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.inputBg,
              borderRadius: BorderRadius.circular(12),
              border: image.reviewed ? Border.all(color: AppColors.primary, width: 2) : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(image.path),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.image_not_supported_outlined, size: 32, color: AppColors.primary),
                      );
                    },
                  ),
                ),
                if (image.quality != ImageQuality.good)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getQualityColor(image.quality),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getQualityLabel(image.quality),
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                if (image.reviewed)
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(Icons.check, color: Colors.white, size: 20),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Page $index',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 3),
          Text(
            image.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            _getQualityLabel(image.quality),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _getQualityColor(image.quality)),
          ),
          const SizedBox(height: 8),
          // Button row with proper layout to prevent overflow
          if (image.quality == ImageQuality.good)
            LayoutBuilder(
              builder: (context, constraints) {
                final actionWidth = constraints.maxWidth > 220 ? (constraints.maxWidth - 6) / 2 : constraints.maxWidth;
                return Row(
                  children: [
                    SizedBox(
                      width: actionWidth,
                      child: TextButton(
                        onPressed: onReviewChanged,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(image.reviewed ? 'Unmark' : 'Mark Review'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 62,
                      child: TextButton(
                        onPressed: onRemove,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Remove'),
                        ),
                      ),
                    ),
                  ],
                );
              },
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final flagWidth = constraints.maxWidth > 220 ? (constraints.maxWidth - 6) / 2 : constraints.maxWidth;
                return Row(
                  children: [
                    SizedBox(
                      width: flagWidth,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: Text(
                          'Auto-flagged',
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 62,
                      child: TextButton(
                        onPressed: onRemove,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text('Remove'),
                        ),
                      ),
                    ),
                  ],
                );
              },
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
        const Text('Processing Scanner Output', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        const SizedBox(height: 8),
        const Text(
          'The scanner is extracting and validating OMR responses.',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(value: progress == 0 ? null : progress, minHeight: 6),
        ),
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
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 120,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percent <= 0 ? null : percent / 100,
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '${percent.clamp(0, 100).toStringAsFixed(0)}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
    this.reviewed = false,
    this.quality = ImageQuality.good,
  });

  final String path;
  final String name;
  bool reviewed;
  ImageQuality quality;
}

enum ImageQuality { good, poor, notClear }

class _ScanStage {
  _ScanStage(this.title);

  final String title;
  double percent = 0;
}

enum _ProcessingMode { wait, background }

/// ---------------------------------------------------------------------
/// Camera capture flow with a *simulated* live document-edge detection
/// overlay (the blue/green quad you see in real scanner apps).
///
/// This is intentionally NOT running real computer vision — there's no
/// OpenCV / ML Kit contour detection here. It's a lightweight animation
/// that behaves like one (wobbles, "loses" and "re-finds" the page,
/// locks green when steady) purely for prototyping purposes. The photo
/// itself IS real, taken with the device's actual camera.
/// ---------------------------------------------------------------------
class _CameraScannerPage extends StatefulWidget {
  const _CameraScannerPage({
    required this.initialImages,
  });

  final List<_ScanImage> initialImages;

  @override
  State<_CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<_CameraScannerPage> with WidgetsBindingObserver {
  late List<_ScanImage> _capturedImages;
  bool _showPreview = false;
  bool _showOnlyFlagged = true;
  bool _autoCapture = true;
  bool _isCapturing = false;

  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? _cameraError;

  // --- Simulated document-detection state -------------------------------
  final Random _rng = Random();
  List<Offset> _quad = _idealQuad;
  Timer? _detectionTimer;
  double _steadyMs = 0;
  bool _isSteady = false;

  static const _tickMs = 110;
  static const _steadyThresholdMs = 1100;
  static const List<Offset> _idealQuad = [
    Offset(0.12, 0.10),
    Offset(0.88, 0.10),
    Offset(0.88, 0.86),
    Offset(0.12, 0.86),
  ];

  bool get _isMobilePlatform =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    _capturedImages = List.from(widget.initialImages);
    WidgetsBinding.instance.addObserver(this);
    if (_isMobilePlatform) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      _detectionTimer?.cancel();
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  List<_ScanImage> get _filteredImages {
    if (!_showOnlyFlagged) return _capturedImages;
    return _capturedImages.where((img) => img.quality != ImageQuality.good).toList();
  }

  Future<void> _setupCamera() async {
    setState(() => _cameraError = null);
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _cameraError = 'No camera was found on this device.');
        return;
      }
      final backCamera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      setState(() {
        _cameraController = controller;
        _initializeControllerFuture = controller.initialize();
      });

      await _initializeControllerFuture;
      if (!mounted) return;
      _startSimulatedDetection();
      setState(() {});
    } on CameraException catch (e) {
      setState(() => _cameraError = e.description ?? 'Camera permission denied or unavailable.');
    } catch (e) {
      setState(() => _cameraError = 'Could not start the camera.');
    }
  }

  /// Drives a small "spring + jitter" random walk of the quad corners so
  /// the overlay wobbles around the ideal frame the way a real detector's
  /// output would while you hold the device — including occasional larger
  /// jumps that mimic briefly losing / re-acquiring the page edges.
  void _startSimulatedDetection() {
    _detectionTimer?.cancel();
    _detectionTimer = Timer.periodic(const Duration(milliseconds: _tickMs), (_) {
      if (!mounted || _isCapturing) return;

      final loseTrack = _rng.nextDouble() < 0.025;
      final jitter = loseTrack ? 0.045 : 0.007;
      double frameMovement = 0;

      final next = <Offset>[];
      for (var i = 0; i < _quad.length; i++) {
        final corner = _quad[i];
        final ideal = _idealQuad[i];
        final pull = (ideal - corner) * 0.04;
        final dx = (_rng.nextDouble() - 0.5) * jitter + pull.dx;
        final dy = (_rng.nextDouble() - 0.5) * jitter + pull.dy;
        frameMovement += sqrt(dx * dx + dy * dy);
        next.add(Offset((corner.dx + dx).clamp(0.03, 0.97), (corner.dy + dy).clamp(0.03, 0.97)));
      }

      setState(() {
        _quad = next;
        if (frameMovement < 0.018) {
          _steadyMs += _tickMs;
        } else {
          _steadyMs = 0;
        }
        _isSteady = _steadyMs >= _steadyThresholdMs;
      });

      if (_isSteady && _autoCapture && !_isCapturing) {
        _captureImage();
      }
    });
  }

  void _setShowPreview(bool value) {
    setState(() => _showPreview = value);
    if (value) {
      _detectionTimer?.cancel();
    } else if (_isMobilePlatform && _cameraController != null) {
      _startSimulatedDetection();
    }
  }

  Future<void> _captureImage() async {
    if (_isCapturing) return;

    if (!_isMobilePlatform) {
      await _pickImagesForWeb();
      return;
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Camera is not ready yet.')),
      );
      return;
    }

    setState(() => _isCapturing = true);
    _detectionTimer?.cancel();

    try {
      final XFile file = await controller.takePicture();

      // Simulate quality detection - randomly flag some images as poor quality
      final random = (DateTime.now().millisecondsSinceEpoch % 3);
      ImageQuality quality = ImageQuality.good;
      if (random == 1) {
        quality = ImageQuality.notClear;
      } else if (random == 2) {
        quality = ImageQuality.poor;
      }

      if (!mounted) return;
      setState(() {
        _capturedImages.add(
          _ScanImage(
            path: file.path,
            name: 'Capture ${_capturedImages.length + 1}',
            quality: quality,
          ),
        );
        _steadyMs = 0;
        _isSteady = false;
        _quad = _idealQuad;
      });

      await Future.delayed(const Duration(milliseconds: 450));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCapturing = false);
        _startSimulatedDetection();
      }
    }
  }

  Future<void> _pickImagesForWeb() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: false,
      dialogTitle: 'Select OMR Images',
    );

    if (result != null) {
      setState(() {
        for (final file in result.files) {
          final path = file.path;
          if (path == null) continue;
          if (_capturedImages.any((image) => image.path == path)) continue;
          _capturedImages.add(
            _ScanImage(
              path: path,
              name: file.name,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, _capturedImages);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capture OMR Pages'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context, _capturedImages),
          ),
        ),
        body: _showPreview ? _buildGalleryPreview() : _buildCaptureView(),
      ),
    );
  }

  Widget _buildCaptureView() {
    if (!_isMobilePlatform) {
      return _buildUploadFallbackView();
    }
    if (_cameraError != null) {
      return _buildCameraErrorView();
    }
    if (_cameraController == null || _initializeControllerFuture == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          );
        }
        final controller = _cameraController!;
        final previewSize = controller.value.previewSize;

        return Column(
          children: [
            Expanded(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: Colors.black),
                    if (previewSize != null)
                      Center(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            // Android/iOS report preview size in landscape terms.
                            width: previewSize.height,
                            height: previewSize.width,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DetectedFramePainter(
                          corners: _quad,
                          color: _isSteady ? const Color(0xFF34D399) : const Color(0xFF2F6BFF),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              _isCapturing
                                  ? 'Capturing…'
                                  : _isSteady
                                      ? 'Steady — capturing'
                                      : 'Scanning… hold steady',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.info_outline, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  'Batch mode • ${_capturedImages.length} captured',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 14,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _ModeChip(
                                label: 'Manual',
                                selected: !_autoCapture,
                                onTap: () => setState(() => _autoCapture = false),
                              ),
                              _ModeChip(
                                label: 'Auto capture',
                                selected: _autoCapture,
                                onTap: () => setState(() => _autoCapture = true),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCaptureControls(),
          ],
        );
      },
    );
  }

  Widget _buildCameraErrorView() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Colors.white54, size: 48),
              const SizedBox(height: 16),
              Text(
                _cameraError ?? 'Camera unavailable',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _setupCamera,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImagesForWeb,
                icon: const Icon(Icons.upload_file, color: Colors.white70),
                label: const Text('Upload Instead', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUploadFallbackView() {
    return Column(
      children: [
        Expanded(
          child: Container(
            color: Colors.grey[100],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 64, color: AppColors.primary),
                        const SizedBox(height: 20),
                        const Text(
                          'Upload OMR Images',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Live camera scanning is available on Android/iOS. Select images from your device instead.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _pickImagesForWeb,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Choose Images'),
                          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_capturedImages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                          const SizedBox(width: 8),
                          Text(
                            '${_capturedImages.length} image${_capturedImages.length == 1 ? '' : 's'} selected',
                            style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        if (_capturedImages.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _setShowPreview(true),
                    icon: const Icon(Icons.photo_library),
                    label: Text('Review (${_capturedImages.length})'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _showScanCompleteDialog,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Complete Scan'),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCaptureControls() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: OutlinedButton.icon(
              onPressed: _capturedImages.isEmpty ? null : () => _setShowPreview(true),
              icon: const Icon(Icons.photo_library),
              label: Text('Gallery (${_capturedImages.length})'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
            ),
          ),
          SizedBox(
            width: 70,
            height: 70,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isCapturing ? null : _captureImage,
                  customBorder: const CircleBorder(),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isCapturing ? Colors.white38 : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 150),
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, _capturedImages),
              icon: const Icon(Icons.check),
              label: const Text('Done'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGalleryPreview() {
    final filtered = _filteredImages;
    final flaggedCount = _capturedImages.where((img) => img.quality != ImageQuality.good).length;

    return Container(
      color: AppPalette.teal50,
      child: Column(
        children: [
          if (flaggedCount > 0)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.24)),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$flaggedCount image${flaggedCount == 1 ? '' : 's'} flagged for review',
                      style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _showOnlyFlagged = !_showOnlyFlagged);
                    },
                    child: Text(_showOnlyFlagged ? 'Show All' : 'Show Flagged Only'),
                  ),
                ],
              ),
            ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, size: 64, color: AppColors.success),
                        const SizedBox(height: 16),
                        const Text('All images are clear!', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth >= 720
                          ? 3
                          : constraints.maxWidth >= 480
                              ? 2
                              : 1;

                      return GridView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.72,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final image = filtered[index];
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: image.quality != ImageQuality.good ? AppColors.error.withValues(alpha: 0.35) : AppColors.divider,
                                width: image.quality != ImageQuality.good ? 2 : 1,
                              ),
                              boxShadow: AppColors.shadowSm,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.file(
                                        File(image.path),
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Container(
                                          color: AppColors.surface,
                                          alignment: Alignment.center,
                                          child: const Icon(Icons.image, color: AppColors.textSecondary, size: 32),
                                        ),
                                      ),
                                      if (image.quality != ImageQuality.good)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          right: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: image.quality == ImageQuality.notClear ? AppColors.error : AppColors.warning,
                                              borderRadius: BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              image.quality == ImageQuality.notClear ? 'Not Clear' : 'Poor',
                                              style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: IconButton(
                                          icon: const Icon(Icons.close, size: 18),
                                          onPressed: () {
                                            setState(() {
                                              _capturedImages.remove(image);
                                            });
                                          },
                                          splashRadius: 16,
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Capture ${index + 1}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        image.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: 150,
                  child: OutlinedButton.icon(
                    onPressed: () => _setShowPreview(false),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Capture More'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: FilledButton.icon(
                    onPressed: _capturedImages.isEmpty ? null : _showScanCompleteDialog,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Complete Scan'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScanCompleteDialog() {
    final reviewedCount = _capturedImages.where((img) => img.reviewed).length;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Scan Complete'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${_capturedImages.length} Sheet${_capturedImages.length == 1 ? '' : 's'} Scanned',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '$reviewedCount marked for review',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _setShowPreview(false);
              },
              child: const Text('Capture More'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context, _capturedImages);
              },
              child: const Text('Review Sheets'),
            ),
          ],
        );
      },
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Paints the animated "document detected" quad — a blue (or green, once
/// steady) outline with a faint fill, matching the live-scanning overlay
/// look of apps like Jotform / Adobe Scan / Office Lens.
class _DetectedFramePainter extends CustomPainter {
  _DetectedFramePainter({required this.corners, required this.color});

  final List<Offset> corners;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = corners.map((c) => Offset(c.dx * size.width, c.dy * size.height)).toList();
    final path = Path()..addPolygon(points, true);

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

    // Corner dots, like a lot of real scanners draw at each detected vertex.
    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DetectedFramePainter oldDelegate) {
    return oldDelegate.color != color || !_listEquals(oldDelegate.corners, corners);
  }

  bool _listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}