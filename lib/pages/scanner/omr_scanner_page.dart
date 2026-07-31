import 'dart:async';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../models/app_models.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

// ---------------------------------------------------------------------------
// Entry point — OmrScannerPage
// ---------------------------------------------------------------------------

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
  bool _launched = false;

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.of(context);

    // Launch the camera scanner exactly once.
    if (!_launched) {
      _launched = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _openCameraScanner();
      });
    }

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
        child: const SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt_outlined, size: 56, color: AppColors.textSecondary),
                  SizedBox(height: 12),
                  Text(
                    'Opening camera for automatic scanning...',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCameraScanner() async {
    if (!mounted) return;
    final result = await Navigator.of(context).push<List<_ScanImage>>(
      MaterialPageRoute(
        builder: (_) => const _CameraScannerPage(),
      ),
    );

    if (!mounted) return;

    if (result != null && result.isNotEmpty) {
      // Notify user of queued scans.
      try {
        final appState = AppStateScope.of(context);
        appState.addNotification(
          title: 'OMR Scan Complete',
          subtitle: '${result.length} page${result.length == 1 ? '' : 's'} recorded for ${widget.survey.name}.',
          icon: Icons.fact_check_outlined,
        );
      } catch (_) {
        // Ignore in prototype.
      }
    }

    // Pop back to the previous screen after scanner closes.
    if (mounted) Navigator.of(context).pop();
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

class _ScanImage {
  _ScanImage({required this.path, required this.name});

  final String path;
  final String name;
}

// ---------------------------------------------------------------------------
// Scan state machine
// ---------------------------------------------------------------------------

/// Deterministic scan states that prevent infinite capture loops.
enum _ScanState {
  searching,
  detecting,
  locked,
  capturing,
  processing,
  recorded,
  waitingForNextPage,
}

// ---------------------------------------------------------------------------
// Camera scanner page — auto-capture only, state-machine driven
// ---------------------------------------------------------------------------

class _CameraScannerPage extends StatefulWidget {
  const _CameraScannerPage();

  @override
  State<_CameraScannerPage> createState() => _CameraScannerPageState();
}

class _CameraScannerPageState extends State<_CameraScannerPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Captured images.
  final List<_ScanImage> _capturedImages = [];

  // Camera.
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  String? _cameraError;

  // --- State machine ---
  _ScanState _scanState = _ScanState.searching;
  bool _disposed = false;

  // --- Simulated detection ---
  List<Offset> _quad = List.from(_idealQuad);
  Timer? _detectionTimer;
  int _simTickCount = 0;
  bool _paperDetected = false;
  bool _cornersDetected = false;
  bool _blurOk = false;
  bool _lightingOk = false;
  bool _perspectiveOk = false;
  String _statusText = 'Searching document...';

  // --- Animations ---
  late AnimationController _pulseController;
  late AnimationController _scanlineController;
  bool _showGreenFlash = false;
  bool _showSuccessAnimation = false;
  String _successMessage = '';

  // --- Cooldown for duplicate prevention ---
  DateTime? _lastCaptureTime;
  static const _captureCooldown = Duration(seconds: 3);

  // --- Constants ---
  static const _tickMs = 80;

  // Deterministic tick thresholds for smooth simulation progression.
  static const _ticksForPaper = 8; //  ~640ms
  static const _ticksForCorners = 16; // ~1280ms
  static const _ticksForBlur = 22; // ~1760ms
  static const _ticksForLighting = 28; // ~2240ms
  static const _ticksForPerspective = 34; // ~2720ms
  static const _ticksForLock = 40; // ~3200ms

  static const List<Offset> _idealQuad = [
    Offset(0.12, 0.10),
    Offset(0.88, 0.10),
    Offset(0.88, 0.86),
    Offset(0.12, 0.86),
  ];

  bool get _isMobilePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();

    if (_isMobilePlatform) {
      _setupCamera();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _detectionTimer?.cancel();
    _detectionTimer = null;
    _pulseController.dispose();
    _scanlineController.dispose();
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _detectionTimer?.cancel();
      _detectionTimer = null;
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _setupCamera();
    }
  }

  // -----------------------------------------------------------------------
  // Camera setup
  // -----------------------------------------------------------------------

  Future<void> _setupCamera() async {
    if (_disposed) return;
    try {
      final cams = await availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _cameraError = 'No camera devices found.');
        return;
      }
      final camera = cams.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      _initializeControllerFuture = _cameraController!.initialize();
      await _initializeControllerFuture;
      if (!mounted || _disposed) return;
      setState(() {});
      _startSimulatedDetection();
    } on CameraException catch (e) {
      if (mounted) {
        setState(() => _cameraError =
            e.description ?? 'Camera permission denied or unavailable.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cameraError = 'Could not start the camera.');
      }
    }
  }

  // -----------------------------------------------------------------------
  // Deterministic simulated detection
  // -----------------------------------------------------------------------

  void _startSimulatedDetection() {
    _detectionTimer?.cancel();
    _simTickCount = 0;
    _scanState = _ScanState.searching;

    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: _tickMs),
      _onDetectionTick,
    );
  }

  void _onDetectionTick(Timer timer) {
    if (!mounted || _disposed) {
      timer.cancel();
      return;
    }

    // Only advance when in searching/detecting states.
    if (_scanState != _ScanState.searching &&
        _scanState != _ScanState.detecting) {
      return;
    }

    _simTickCount++;

    // Deterministic quad convergence: corners drift toward ideal over time.
    final rng = Random();
    final progress = (_simTickCount / _ticksForLock).clamp(0.0, 1.0);
    final jitter = (1.0 - progress) * 0.03;
    final next = <Offset>[];
    for (var i = 0; i < _idealQuad.length; i++) {
      final ideal = _idealQuad[i];
      final current = _quad[i];
      // Lerp toward ideal with diminishing jitter.
      final dx = current.dx + (ideal.dx - current.dx) * 0.12 +
          (rng.nextDouble() - 0.5) * jitter;
      final dy = current.dy + (ideal.dy - current.dy) * 0.12 +
          (rng.nextDouble() - 0.5) * jitter;
      next.add(Offset(dx.clamp(0.01, 0.99), dy.clamp(0.01, 0.99)));
    }

    setState(() {
      _quad = next;

      // Deterministic check progression — each check turns green at its
      // threshold tick, and stays green. No flickering.
      _paperDetected = _simTickCount >= _ticksForPaper;
      _cornersDetected = _simTickCount >= _ticksForCorners;
      _blurOk = _simTickCount >= _ticksForBlur;
      _lightingOk = _simTickCount >= _ticksForLighting;
      _perspectiveOk = _simTickCount >= _ticksForPerspective;

      if (_simTickCount < _ticksForPaper) {
        _scanState = _ScanState.searching;
        _statusText = 'Searching document...';
      } else if (_simTickCount < _ticksForCorners) {
        _scanState = _ScanState.detecting;
        _statusText = 'Document found — finding corners...';
      } else if (_simTickCount < _ticksForBlur) {
        _scanState = _ScanState.detecting;
        _statusText = 'Checking blur...';
      } else if (_simTickCount < _ticksForLighting) {
        _scanState = _ScanState.detecting;
        _statusText = 'Checking lighting...';
      } else if (_simTickCount < _ticksForPerspective) {
        _scanState = _ScanState.detecting;
        _statusText = 'Checking perspective...';
      } else if (_simTickCount < _ticksForLock) {
        _scanState = _ScanState.detecting;
        _statusText = 'Hold steady...';
      } else {
        _scanState = _ScanState.locked;
        _statusText = 'Page locked — capturing...';
      }
    });

    // Manage pulse animation.
    final isLocked = _scanState == _ScanState.locked;
    if (isLocked && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!isLocked && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }

    // Auto-capture once locked (with cooldown guard).
    if (_scanState == _ScanState.locked) {
      final now = DateTime.now();
      if (_lastCaptureTime != null &&
          now.difference(_lastCaptureTime!) < _captureCooldown) {
        // Still within cooldown — don't capture.
        return;
      }
      _captureImage();
    }
  }

  // -----------------------------------------------------------------------
  // Capture
  // -----------------------------------------------------------------------

  Future<void> _captureImage() async {
    if (_scanState == _ScanState.capturing ||
        _scanState == _ScanState.processing ||
        _scanState == _ScanState.recorded) {
      return;
    }

    if (!_isMobilePlatform) {
      await _pickImagesForWeb();
      return;
    }

    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera is not ready yet.')),
        );
      }
      return;
    }

    setState(() {
      _scanState = _ScanState.capturing;
      _statusText = 'Capturing...';
    });

    // Stop detection ticks during capture.
    _detectionTimer?.cancel();
    _detectionTimer = null;

    try {
      final XFile file = await controller.takePicture();
      if (!mounted || _disposed) return;

      _lastCaptureTime = DateTime.now();

      // Green flash effect.
      setState(() {
        _showGreenFlash = true;
        _scanState = _ScanState.processing;
        _statusText = 'Processing...';
      });

      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted || _disposed) return;
      setState(() => _showGreenFlash = false);

      await Future<void>.delayed(const Duration(milliseconds: 300));
      if (!mounted || _disposed) return;

      // Automatically record the captured image.
      setState(() {
        _capturedImages.add(
          _ScanImage(
            path: file.path,
            name: 'OMR Scan',
          ),
        );
        _scanState = _ScanState.recorded;
        _statusText = 'Recorded Successfully';
        _successMessage = 'Recorded Successfully';
        _showSuccessAnimation = true;
      });

      // Show success animation briefly.
      await Future<void>.delayed(const Duration(milliseconds: 1500));
      if (!mounted || _disposed) return;
      setState(() => _showSuccessAnimation = false);

      // Notify.
      try {
        AppStateScope.of(context).addNotification(
          title: 'Scan Saved',
          subtitle: 'OMR scan recorded and queued for processing.',
          icon: Icons.document_scanner_outlined,
        );
      } catch (_) {
        // Ignore in prototype.
      }

      // Transition to waiting, then restart detection.
      if (!mounted || _disposed) return;
      setState(() {
        _scanState = _ScanState.waitingForNextPage;
        _statusText = 'Waiting for next page...';
        _quad = List.from(_idealQuad);
        _paperDetected = false;
        _cornersDetected = false;
        _blurOk = false;
        _lightingOk = false;
        _perspectiveOk = false;
      });

      // Cooldown before restarting.
      await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted || _disposed) return;

      _startSimulatedDetection();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not capture image: $e')),
        );
        // Recover to searching.
        setState(() {
          _scanState = _ScanState.searching;
          _statusText = 'Searching document...';
        });
        _startSimulatedDetection();
      }
    }
  }



  // -----------------------------------------------------------------------
  // Done / Exit — properly release all resources
  // -----------------------------------------------------------------------

  void _exitScanner() {
    // Cancel all timers first.
    _detectionTimer?.cancel();
    _detectionTimer = null;

    // Stop animations.
    if (_pulseController.isAnimating) {
      _pulseController.stop();
    }
    if (_scanlineController.isAnimating) {
      _scanlineController.stop();
    }

    // Dispose camera.
    _cameraController?.dispose();
    _cameraController = null;

    // Pop immediately.
    if (mounted) {
      Navigator.pop(context, _capturedImages);
    }
  }

  // -----------------------------------------------------------------------
  // Web fallback
  // -----------------------------------------------------------------------

  Future<void> _pickImagesForWeb() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: false,
      dialogTitle: 'Select OMR Images',
    );
    if (result != null && mounted) {
      setState(() {
        for (final file in result.files) {
          final path = file.path;
          if (path == null) continue;
          if (_capturedImages.any((img) => img.path == path)) continue;
          _capturedImages.add(
            _ScanImage(path: path, name: file.name),
          );
        }
      });
    }
  }

  // -----------------------------------------------------------------------
  // Status dot widget
  // -----------------------------------------------------------------------

  Widget _buildStatusDot(String label, bool ok) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: ok ? const Color(0xFF34D399) : Colors.white30,
              shape: BoxShape.circle,
              boxShadow: ok
                  ? [
                      BoxShadow(
                        color: const Color(0xFF34D399).withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: ok ? Colors.white : Colors.white38,
              fontSize: 11,
              fontWeight: ok ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // -----------------------------------------------------------------------
  // Build
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitScanner();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Capture OMR Pages'),
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _exitScanner,
          ),
        ),
        body: _buildCaptureView(),
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
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const ColoredBox(
            color: Colors.black,
            child: Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }
        final controller = _cameraController!;
        final previewSize = controller.value.previewSize;

        final bool isLocked = _scanState == _ScanState.locked ||
            _scanState == _ScanState.capturing ||
            _scanState == _ScanState.processing ||
            _scanState == _ScanState.recorded;

        final Color frameColor =
            isLocked ? const Color(0xFF34D399) : const Color(0xFF2F6BFF);

        return Column(
          children: [
            Expanded(
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera preview.
                    const ColoredBox(color: Colors.black),
                    if (previewSize != null)
                      Center(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: previewSize.height,
                            height: previewSize.width,
                            child: CameraPreview(controller),
                          ),
                        ),
                      ),

                    // Detection quad overlay.
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DetectedFramePainter(
                          corners: _quad,
                          color: frameColor,
                        ),
                      ),
                    ),

                    // Green overlay when locked.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isLocked ? 0.12 : 0.0,
                      child: Container(color: const Color(0xFF34D399)),
                    ),

                    // Green flash after capture.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _showGreenFlash ? 0.4 : 0.0,
                      child: Container(color: const Color(0xFF34D399)),
                    ),

                    // Pulse glow when locked.
                    if (isLocked)
                      Positioned.fill(
                        child: Center(
                          child: IgnorePointer(
                            child: AnimatedBuilder(
                              animation: _pulseController,
                              builder: (context, child) => Transform.scale(
                                scale: 1.0 + (_pulseController.value * 0.08),
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF34D399)
                                        .withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Status HUD.
                    Positioned(
                      top: 20,
                      left: 16,
                      right: 16,
                      child: Column(
                        children: [
                          // Status bar.
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isLocked
                                  ? const Color(0xFF34D399).withValues(alpha: 0.85)
                                  : Colors.black54,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    isLocked
                                        ? Icons.check_circle
                                        : Icons.document_scanner_outlined,
                                    key: ValueKey(isLocked),
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                                    child: Text(
                                      _statusText,
                                      key: ValueKey(_statusText),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black26,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.layers_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_capturedImages.length}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Quality check dots.
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black38,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildStatusDot('Doc', _paperDetected),
                                const SizedBox(width: 8),
                                _buildStatusDot('Corners', _cornersDetected),
                                const SizedBox(width: 8),
                                _buildStatusDot('Blur', _blurOk),
                                const SizedBox(width: 8),
                                _buildStatusDot('Light', _lightingOk),
                                const SizedBox(width: 8),
                                _buildStatusDot('Persp', _perspectiveOk),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Success animation overlay.
                    if (_showSuccessAnimation)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black54,
                          child: Center(
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: Opacity(
                                    opacity: value,
                                    child: child,
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 24,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34D399),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF34D399)
                                          .withValues(alpha: 0.4),
                                      blurRadius: 24,
                                      spreadRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _successMessage,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
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
              const Icon(
                Icons.videocam_off_outlined,
                color: Colors.white54,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _cameraError ?? 'Camera unavailable',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: () {
                  setState(() => _cameraError = null);
                  _setupCamera();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _pickImagesForWeb,
                icon:
                    const Icon(Icons.upload_file, color: Colors.white70),
                label: const Text(
                  'Upload Instead',
                  style: TextStyle(color: Colors.white70),
                ),
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
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.cloud_upload_outlined,
                          size: 64,
                          color: AppColors.primary,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Upload OMR Images',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Live camera scanning is available on Android/iOS.\n'
                          'Select images from your device instead.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: _pickImagesForWeb,
                          icon: const Icon(
                            Icons.add_photo_alternate_outlined,
                          ),
                          label: const Text('Choose Images'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (_capturedImages.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green[700],
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_capturedImages.length} image${_capturedImages.length == 1 ? '' : 's'} selected',
                            style: TextStyle(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
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
        if (_capturedImages.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _exitScanner,
                    icon: const Icon(Icons.check),
                    label: Text('Done (${_capturedImages.length})'),
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
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pages recorded indicator.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _capturedImages.isNotEmpty
                  ? const Color(0xFF34D399).withValues(alpha: 0.15)
                  : Colors.white10,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.layers,
                  color: _capturedImages.isNotEmpty
                      ? const Color(0xFF34D399)
                      : Colors.white54,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_capturedImages.length} page${_capturedImages.length == 1 ? '' : 's'}',
                  style: TextStyle(
                    color: _capturedImages.isNotEmpty
                        ? const Color(0xFF34D399)
                        : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Done button.
          FilledButton.icon(
            onPressed: _exitScanner,
            icon: const Icon(Icons.check),
            label: const Text('Done'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ---------------------------------------------------------------------------
// Detection frame painter
// ---------------------------------------------------------------------------

class _DetectedFramePainter extends CustomPainter {
  _DetectedFramePainter({required this.corners, required this.color});

  final List<Offset> corners;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final points = corners
        .map((c) => Offset(c.dx * size.width, c.dy * size.height))
        .toList();
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

    final dotPaint = Paint()..color = color;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DetectedFramePainter oldDelegate) {
    return oldDelegate.color != color ||
        !_listEquals(oldDelegate.corners, corners);
  }

  bool _listEquals(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
