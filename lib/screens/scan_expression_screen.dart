import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mediapipe_face_mesh/mediapipe_face_mesh.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/theme/app_colors.dart';

class ExpressionResult {
  final int moodLevel;
  final String emoji;
  final String label;

  const ExpressionResult({
    required this.moodLevel,
    required this.emoji,
    required this.label,
  });
}

enum _ScanState { initializing, ready, scanning, done, error }

class ScanExpressionScreen extends StatefulWidget {
  const ScanExpressionScreen({super.key});

  @override
  State<ScanExpressionScreen> createState() => _ScanExpressionScreenState();
}

class _ScanExpressionScreenState extends State<ScanExpressionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _pulseController;
  late final AnimationController _scanController;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _scanAnim;

  _ScanState _state = _ScanState.initializing;
  ExpressionResult? _result;
  ExpressionResult? _liveResult;
  String? _errorMessage;

  CameraController? _cameraController;
  FaceMeshIsolatePipeline? _pipeline;
  FaceBlendshapesProcessor? _blendshapesProcessor;

  bool _isProcessingFrame = false;
  DateTime _lastFrameTime = DateTime(0);
  final List<ExpressionResult> _scanBuffer = [];
  int _noFaceCount = 0;
  bool _noFaceWarning = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _scanAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.linear),
    );
    WidgetsBinding.instance.addObserver(this);
    _initAll();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _scanController.dispose();
    _disposeAll();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _disposeCamera();
    } else if (state == AppLifecycleState.resumed) {
      if (mounted) setState(() => _state = _ScanState.initializing);
      _initCamera();
    }
  }

  Future<void> _disposeCamera() async {
    try {
      if (_cameraController?.value.isStreamingImages == true) {
        await _cameraController!.stopImageStream();
      }
      await _cameraController?.dispose();
      _cameraController = null;
    } catch (_) {}
  }

  Future<void> _disposeAll() async {
    await _disposeCamera();
    _pipeline?.close();
    _pipeline = null;
    _blendshapesProcessor?.close();
    _blendshapesProcessor = null;
  }

  Future<void> _initAll() async {
    try {
      _pipeline ??= await FaceMeshIsolatePipeline.spawn(
        _createPipeline,
        FaceMeshModel.v2,
      );
      _blendshapesProcessor ??= await FaceBlendshapesProcessor.create();
    } catch (e) {
      _setError('Gagal inisialisasi AI: $e');
      return;
    }
    await _initCamera();
  }

  Future<void> _initCamera() async {
    await _disposeCamera();
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _setError('Izin kamera ditolak. Aktifkan di pengaturan aplikasi.');
        return;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _setError('Tidak ada kamera yang ditemukan.');
        return;
      }
      final cam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );
      _cameraController = CameraController(
        cam,
        ResolutionPreset.low,
        imageFormatGroup: Platform.isIOS
            ? ImageFormatGroup.bgra8888
            : ImageFormatGroup.yuv420,
        enableAudio: false,
      );
      for (int i = 0; i < 3; i++) {
        try {
          await _cameraController!.initialize();
          break;
        } on CameraException catch (e) {
          if (i == 2) rethrow;
          if (e.code == 'cameraNotReadable' || e.code == 'CameraAccessDenied') {
            await Future.delayed(Duration(milliseconds: 600 * (i + 1)));
          } else {
            rethrow;
          }
        }
      }
      if (mounted) setState(() => _state = _ScanState.ready);
    } catch (e) {
      _setError('Gagal membuka kamera: $e');
    }
  }

  void _setError(String msg) {
    if (mounted) setState(() {
      _state = _ScanState.error;
      _errorMessage = msg;
    });
  }

  Future<void> _startScan() async {
    final ctrl = _cameraController;
    if (ctrl == null || !ctrl.value.isInitialized) return;
    if (_pipeline == null) return;

    setState(() {
      _state = _ScanState.scanning;
      _scanBuffer.clear();
      _liveResult = null;
      _noFaceCount = 0;
      _noFaceWarning = false;
    });
    _scanController.repeat();

    await ctrl.startImageStream(_onFrame);

    final deadline = DateTime.now().add(const Duration(milliseconds: 3000));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (_scanBuffer.length >= 8) break;
    }

    try {
      if (ctrl.value.isStreamingImages) await ctrl.stopImageStream();
    } catch (_) {}

    _scanController.stop();
    if (!mounted) return;

    final result = _pickDominant();
    if (result == null) {
      setState(() {
        _state = _ScanState.ready;
        _liveResult = null;
        _noFaceWarning = true;
      });
      return;
    }
    setState(() {
      _result = result;
      _liveResult = null;
      _state = _ScanState.done;
    });
  }

  void _onFrame(CameraImage image) async {
    if (_isProcessingFrame || _pipeline == null) return;
    final now = DateTime.now();
    if (now.difference(_lastFrameTime).inMilliseconds < 200) return;
    if (_pipeline!.isBusy) return;

    _isProcessingFrame = true;
    _lastFrameTime = now;

    try {
      final frame = _toFrame(image);
      if (frame == null) return;

      final rotation = _sensorRotation();
      final inferResult = await _pipeline!.process(
        frame,
        rotationDegrees: rotation,
        mirrorHorizontal: true,
      );

      if (!mounted) return;

      final meshResult = inferResult.meshResult;
      if (meshResult == null) {
        _noFaceCount++;
        if (_noFaceCount >= 4 && !_noFaceWarning) {
          setState(() => _noFaceWarning = true);
        }
        return;
      }

      _noFaceCount = 0;
      if (_noFaceWarning) setState(() => _noFaceWarning = false);

      final blendshapes = _blendshapesProcessor?.process(meshResult);
      if (blendshapes == null) return;

      final expr = _classify(blendshapes);
      _scanBuffer.add(expr);
      if (mounted) setState(() => _liveResult = expr);
    } catch (_) {
    } finally {
      _isProcessingFrame = false;
    }
  }

  /// Konversi CameraImage ke FaceMeshFrame yang sesuai platform
  FaceMeshFrame? _toFrame(CameraImage image) {
    try {
      if (Platform.isIOS) {
        // iOS: BGRA single plane → FaceMeshImage
        final plane = image.planes.first;
        return FaceMeshImage(
          pixels: plane.bytes,
          width: image.width,
          height: image.height,
          pixelFormat: FaceMeshPixelFormat.bgra,
          bytesPerRow: plane.bytesPerRow,
        );
      }

      // Android: YUV420 (3 plane) → NV21 via helper bawaan paket
      if (image.planes.length == 3) {
        return FaceMeshNv21Image.tryFromYuv420Planes(
          width: image.width,
          height: image.height,
          yPlane: FaceMeshImagePlane(
            bytes: image.planes[0].bytes,
            bytesPerRow: image.planes[0].bytesPerRow,
            bytesPerPixel: image.planes[0].bytesPerPixel,
          ),
          uPlane: FaceMeshImagePlane(
            bytes: image.planes[1].bytes,
            bytesPerRow: image.planes[1].bytesPerRow,
            bytesPerPixel: image.planes[1].bytesPerPixel,
          ),
          vPlane: FaceMeshImagePlane(
            bytes: image.planes[2].bytes,
            bytesPerRow: image.planes[2].bytesPerRow,
            bytesPerPixel: image.planes[2].bytesPerPixel,
          ),
        );
      }

      // CameraX 2-plane NV21 (Y + interleaved VU)
      if (image.planes.length == 2) {
        return FaceMeshNv21Image.tryFromYAndInterleavedVuPlanes(
          width: image.width,
          height: image.height,
          yPlane: FaceMeshImagePlane(
            bytes: image.planes[0].bytes,
            bytesPerRow: image.planes[0].bytesPerRow,
            bytesPerPixel: image.planes[0].bytesPerPixel,
          ),
          vuPlane: FaceMeshImagePlane(
            bytes: image.planes[1].bytes,
            bytesPerRow: image.planes[1].bytesPerRow,
            bytesPerPixel: image.planes[1].bytesPerPixel,
          ),
        );
      }

      // Single-plane fallback
      if (image.planes.length == 1) {
        return FaceMeshNv21Image.tryFromSinglePlane(
          bytes: image.planes.first.bytes,
          width: image.width,
          height: image.height,
          bytesPerRow: image.planes.first.bytesPerRow,
        );
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  int _sensorRotation() {
    final ctrl = _cameraController;
    if (ctrl == null) return 270;
    final sensor = ctrl.description.sensorOrientation;
    if (Platform.isIOS) return sensor;
    final deviceAngle = _orientationAngles[ctrl.value.deviceOrientation] ?? 0;
    if (ctrl.description.lensDirection == CameraLensDirection.front) {
      return (sensor + deviceAngle) % 360;
    }
    return (sensor - deviceAngle + 360) % 360;
  }

  static const _orientationAngles = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  // ── Klasifikasi via 52 blendshapes MediaPipe ──
  // 5=Tenang 😊, 4=Baik 🙂, 3=Biasa 😐, 2=Lelah 😔, 1=Berat 😢

  ExpressionResult _classify(FaceBlendshapes bs) {
    final smileL  = bs[FaceBlendshape.mouthSmileLeft]   ?? 0.0;
    final smileR  = bs[FaceBlendshape.mouthSmileRight]  ?? 0.0;
    final smile   = (smileL + smileR) / 2.0;

    final blinkL  = bs[FaceBlendshape.eyeBlinkLeft]     ?? 0.0;
    final blinkR  = bs[FaceBlendshape.eyeBlinkRight]    ?? 0.0;
    final eyeOpen = 1.0 - (blinkL + blinkR) / 2.0;

    final browDownL = bs[FaceBlendshape.browDownLeft]   ?? 0.0;
    final browDownR = bs[FaceBlendshape.browDownRight]  ?? 0.0;
    final browDown  = (browDownL + browDownR) / 2.0;
    final browInner = bs[FaceBlendshape.browInnerUp]    ?? 0.0;

    final frownL  = bs[FaceBlendshape.mouthFrownLeft]   ?? 0.0;
    final frownR  = bs[FaceBlendshape.mouthFrownRight]  ?? 0.0;
    final frown   = (frownL + frownR) / 2.0;

    final cheekL  = bs[FaceBlendshape.cheekSquintLeft]  ?? 0.0;
    final cheekR  = bs[FaceBlendshape.cheekSquintRight] ?? 0.0;
    final cheek   = (cheekL + cheekR) / 2.0;

    final jawOpen = bs[FaceBlendshape.jawOpen]          ?? 0.0;

    // TENANG: senyum lebar + mata terbuka + pipi naik (senyum tulus)
    if (smile >= 0.55 && eyeOpen >= 0.60 && cheek >= 0.20) {
      return const ExpressionResult(moodLevel: 5, emoji: '😊', label: 'Tenang');
    }
    // BAIK: senyum ringan, mata cukup terbuka, tidak cemberut
    if (smile >= 0.30 && eyeOpen >= 0.50 && frown < 0.25) {
      return const ExpressionResult(moodLevel: 4, emoji: '🙂', label: 'Baik');
    }
    // BERAT: alis turun/naik + cemberut + hampir tidak senyum
    if ((browDown >= 0.35 || browInner >= 0.40) && frown >= 0.30 && smile < 0.15) {
      return const ExpressionResult(moodLevel: 1, emoji: '😢', label: 'Berat');
    }
    // LELAH: mata setengah tutup / alis turun / menguap
    if (eyeOpen < 0.45 || (browDown >= 0.25 && smile < 0.20) ||
        (jawOpen > 0.30 && eyeOpen < 0.55)) {
      return const ExpressionResult(moodLevel: 2, emoji: '😔', label: 'Lelah');
    }
    // BIASA: ekspresi netral
    return const ExpressionResult(moodLevel: 3, emoji: '😐', label: 'Biasa');
  }

  ExpressionResult? _pickDominant() {
    if (_scanBuffer.isEmpty) return null;
    final freq = <int, int>{};
    for (final r in _scanBuffer) {
      freq[r.moodLevel] = (freq[r.moodLevel] ?? 0) + 1;
    }
    final topLevel = freq.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
    return _scanBuffer.firstWhere((r) => r.moodLevel == topLevel);
  }

  void _useMood() {
    if (_result != null) Navigator.pop(context, _result);
  }

  void _rescan() {
    setState(() {
      _state = _ScanState.ready;
      _result = null;
      _liveResult = null;
      _scanBuffer.clear();
      _noFaceWarning = false;
    });
    _scanController.reset();
  }

  Future<void> _retry() async {
    if (mounted) setState(() => _state = _ScanState.initializing);
    await Future.delayed(const Duration(milliseconds: 300));
    await _initAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Scan Ekspresi',
          style: TextStyle(color: AppColors.textDark, fontSize: 17, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildInfoBanner(),
              if (_noFaceWarning && _state == _ScanState.ready)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 18),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Wajah tidak terdeteksi. Pastikan wajahmu masuk ke dalam bingkai dan pencahayaan cukup.',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              Expanded(child: _buildCameraFrame()),
              const SizedBox(height: 28),
              _buildBottomSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.sagePale,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageLight.withValues(alpha: 0.5)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.sage),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Arahkan wajahmu ke kamera. Ekspresi terdeteksi otomatis lalu diisi ke mood hari ini.',
              style: TextStyle(fontSize: 12.5, color: AppColors.textBody, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraFrame() {
    return Center(
      child: ScaleTransition(
        scale: _state == _ScanState.ready ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
        child: Container(
          width: 240,
          height: 300,
          decoration: BoxDecoration(
            color: const Color(0xFFE4EDE0),
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: _state == _ScanState.done ? AppColors.sage : AppColors.sageLight,
              width: _state == _ScanState.done ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.sage.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(34),
            child: Stack(
              alignment: Alignment.center,
              children: [
                _buildCameraContent(),
                CustomPaint(size: const Size(240, 300), painter: _FaceGuidePainter()),
                if (_state == _ScanState.scanning)
                  AnimatedBuilder(
                    animation: _scanAnim,
                    builder: (_, __) => Positioned(
                      top: _scanAnim.value * 280,
                      left: 0, right: 0,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [
                            Colors.transparent,
                            AppColors.sage.withValues(alpha: 0.8),
                            Colors.transparent,
                          ]),
                        ),
                      ),
                    ),
                  ),
                if (_state == _ScanState.scanning && _liveResult != null)
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_liveResult!.emoji}  ${_liveResult!.label}',
                        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                if (_state == _ScanState.scanning && _noFaceWarning)
                  Positioned(
                    top: 16, left: 12, right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.shade700.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Wajah tidak terdeteksi. Arahkan kamera ke wajahmu.',
                              style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_state == _ScanState.done && _result != null)
                  Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_result!.emoji, style: const TextStyle(fontSize: 64)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _result!.label,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ..._corners(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraContent() {
    switch (_state) {
      case _ScanState.initializing:
        return Container(
          color: const Color(0xFFD4E3CF),
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sage)),
        );
      case _ScanState.error:
        return Container(
          color: const Color(0xFFD4E3CF),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam_off_rounded, size: 48, color: AppColors.sage.withValues(alpha: 0.5)),
              const SizedBox(height: 12),
              Text(
                _errorMessage ?? 'Kamera tidak tersedia.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textBody),
              ),
            ],
          ),
        );
      case _ScanState.ready:
      case _ScanState.scanning:
      case _ScanState.done:
        final ctrl = _cameraController;
        if (ctrl != null && ctrl.value.isInitialized) {
          return SizedBox.expand(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: ctrl.value.previewSize?.height ?? 240,
                height: ctrl.value.previewSize?.width ?? 300,
                child: CameraPreview(ctrl),
              ),
            ),
          );
        }
        return Container(color: const Color(0xFFD4E3CF));
    }
  }

  Widget _buildBottomSection() {
    switch (_state) {
      case _ScanState.initializing:
        return const Text('Memuat AI deteksi ekspresi…', style: TextStyle(fontSize: 14, color: AppColors.textMuted));
      case _ScanState.error:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _retry,
            icon: const Icon(Icons.refresh_rounded, size: 20),
            label: const Text('Coba Lagi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sage, foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0,
            ),
          ),
        );
      case _ScanState.ready:
        return Column(
          children: [
            const Text('Siapkan wajahmu di dalam bingkai', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _startScan,
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: const Text('Mulai Deteksi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.sage, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), elevation: 0,
                ),
              ),
            ),
          ],
        );
      case _ScanState.scanning:
        return Column(
          children: [
            const SizedBox(width: 28, height: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.sage)),
            const SizedBox(height: 12),
            const Text('Mendeteksi ekspresi…', style: TextStyle(fontSize: 14, color: AppColors.textMuted)),
          ],
        );
      case _ScanState.done:
        return Column(
          children: [
            Text(
              'Ekspresi terdeteksi: ${_result!.label} ${_result!.emoji}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
            const SizedBox(height: 6),
            Text('Mood level ${_result!.moodLevel} akan diisi otomatis.',
                style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _rescan,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Ulangi'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.sage,
                      side: const BorderSide(color: AppColors.sageLight),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _useMood,
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Gunakan Mood Ini'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.sage, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
    }
  }

  List<Widget> _corners() {
    const size = 22.0;
    const w = 2.5;
    final color = AppColors.sage.withValues(alpha: 0.8);
    return [
      Positioned(top: 12, left: 12, child: _corner(size, w, color, top: true, left: true)),
      Positioned(top: 12, right: 12, child: _corner(size, w, color, top: true, left: false)),
      Positioned(bottom: 12, left: 12, child: _corner(size, w, color, top: false, left: true)),
      Positioned(bottom: 12, right: 12, child: _corner(size, w, color, top: false, left: false)),
    ];
  }

  Widget _corner(double size, double stroke, Color color, {required bool top, required bool left}) {
    return CustomPaint(
      size: Size(size, size),
      painter: _CornerPainter(stroke: stroke, color: color, top: top, left: left),
    );
  }
}

Future<FaceMeshInferencePipeline> _createPipeline(FaceMeshModel model) async {
  return FaceMeshInferencePipeline(
    detector: await FaceDetectorProcessor.create(model: FaceDetectionModel.shortRange),
    mesh: await FaceMeshProcessor.create(model: model, delegate: FaceMeshDelegate.xnnpack),
  );
}

class _FaceGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.sage.withValues(alpha: 0.20)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2 - 10),
        width: size.width * 0.6, height: size.height * 0.62,
      ),
      paint,
    );
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CornerPainter extends CustomPainter {
  final double stroke;
  final Color color;
  final bool top;
  final bool left;
  const _CornerPainter({required this.stroke, required this.color, required this.top, required this.left});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = stroke..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final p = Path();
    final s = size.width;
    if (top && left) { p.moveTo(0, s); p.lineTo(0, 0); p.lineTo(s, 0); }
    else if (top && !left) { p.moveTo(0, 0); p.lineTo(s, 0); p.lineTo(s, s); }
    else if (!top && left) { p.moveTo(0, 0); p.lineTo(0, s); p.lineTo(s, s); }
    else { p.moveTo(0, s); p.lineTo(s, s); p.lineTo(s, 0); }
    canvas.drawPath(p, paint);
  }
  @override
  bool shouldRepaint(covariant _CornerPainter old) => false;
}
