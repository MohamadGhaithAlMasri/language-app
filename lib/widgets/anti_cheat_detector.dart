import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../core/theme.dart';

class AntiCheatDetector extends StatefulWidget {
  final VoidCallback onMultipleFacesDetected;
  final VoidCallback onNoFaceDetected;

  const AntiCheatDetector({
    super.key,
    required this.onMultipleFacesDetected,
    required this.onNoFaceDetected,
  });

  @override
  State<AntiCheatDetector> createState() => _AntiCheatDetectorState();
}

class _AntiCheatDetectorState extends State<AntiCheatDetector> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitializing = true;
  bool _hasError = false;
  bool _isPulseOn = false;
  Timer? _pulseTimer;

  // Drag position state
  double _top = 90.0;
  double _left = 16.0;

  // Face Detection members
  FaceDetector? _faceDetector;
  bool _isProcessing = false;
  bool _noFaceDetected = false;
  Timer? _noFaceTimer;
  Timer? _multipleFacesTimer;
  DateTime? _lastProcessedTime;

  @override
  void initState() {
    super.initState();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.fast,
      ),
    );
    _initializeCamera();
    _startPulse();
  }

  void _startPulse() {
    _pulseTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (mounted) {
        setState(() {
          _isPulseOn = !_isPulseOn;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
        return;
      }

      // Find the front camera
      CameraDescription? frontCamera;
      for (var camera in _cameras!) {
        if (camera.lensDirection == CameraLensDirection.front) {
          frontCamera = camera;
          break;
        }
      }

      // Fallback to any camera if front is not found
      frontCamera ??= _cameras!.first;

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });

        // Start processing camera stream frames with throttling (1 frame per 500ms)
        _controller!.startImageStream((CameraImage image) {
          if (_isProcessing || _faceDetector == null) return;
          
          final now = DateTime.now();
          if (_lastProcessedTime != null && 
              now.difference(_lastProcessedTime!).inMilliseconds < 500) {
            return; // Skip this frame to save CPU
          }
          
          _isProcessing = true;
          _lastProcessedTime = now;
 
          _processCameraImage(image).then((_) {
            _isProcessing = false;
          }).catchError((e) {
            debugPrint('Error in face detection stream: $e');
            _isProcessing = false;
          });
        });
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _hasError = true;
        });
      }
    }
  }

  InputImageRotation _getRotation(CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;
    int rotationCompensation = 0;
    if (Platform.isAndroid && _controller != null) {
      final deviceOrientation = _controller!.value.deviceOrientation;
      switch (deviceOrientation) {
        case DeviceOrientation.portraitUp:
          rotationCompensation = 0;
          break;
        case DeviceOrientation.landscapeLeft:
          rotationCompensation = 90;
          break;
        case DeviceOrientation.portraitDown:
          rotationCompensation = 180;
          break;
        case DeviceOrientation.landscapeRight:
          rotationCompensation = 270;
          break;
      }
    }

    int degrees = 0;
    if (camera.lensDirection == CameraLensDirection.front) {
      // Front-facing camera: add compensation
      degrees = (sensorOrientation + rotationCompensation) % 360;
    } else {
      // Back-facing camera: subtract compensation
      degrees = (sensorOrientation - rotationCompensation + 360) % 360;
    }

    switch (degrees) {
      case 0:
        return InputImageRotation.rotation0deg;
      case 90:
        return InputImageRotation.rotation90deg;
      case 180:
        return InputImageRotation.rotation180deg;
      case 270:
        return InputImageRotation.rotation270deg;
      default:
        return InputImageRotation.rotation0deg;
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_faceDetector == null || _cameras == null || _cameras!.isEmpty) return;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final camera = _cameras?.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    if (camera == null) return;

    final rotation = _getRotation(camera);

    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : (InputImageFormatValue.fromRawValue(image.format.raw) ?? InputImageFormat.bgra8888);

    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes[0].bytesPerRow,
    );

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: metadata,
    );

    List<Face> faces = [];
    try {
      faces = await _faceDetector!.processImage(inputImage);
    } catch (e, stackTrace) {
      debugPrint('Error processing camera image: $e\n$stackTrace');
      faces = []; // Treat errors (e.g. dark/covered camera causing errors) as no face detected
    }
    
    if (mounted) {
      setState(() {
        _noFaceDetected = faces.isEmpty;
      });
    }
    
    // Handle No Face detection (grace period of 3 seconds)
    if (faces.isEmpty) {
      _noFaceTimer ??= Timer(const Duration(seconds: 3), () {
        if (mounted) {
          widget.onNoFaceDetected();
        }
      });
    } else {
      _noFaceTimer?.cancel();
      _noFaceTimer = null;
    }

    // Check if more than one face is detected (grace period of 2 seconds)
    if (faces.length > 1) {
      _multipleFacesTimer ??= Timer(const Duration(seconds: 2), () {
        if (mounted) {
          widget.onMultipleFacesDetected();
        }
      });
    } else {
      _multipleFacesTimer?.cancel();
      _multipleFacesTimer = null;
    }
  }

  @override
  void dispose() {
    _pulseTimer?.cancel();
    _noFaceTimer?.cancel();
    _multipleFacesTimer?.cancel();
    _isProcessing = true;
    _faceDetector?.close();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Positioned(
      top: _top,
      left: _left,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _top = (_top + details.delta.dy).clamp(0.0, size.height - 120.0);
            _left = (_left + details.delta.dx).clamp(0.0, size.width - 90.0);
          });
        },
        child: Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _hasError ? AppColors.error : AppColors.primary,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: Stack(
            children: [
              // Camera Preview or Status placeholder
              if (_isInitializing)
                const Center(
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              else if (_hasError || _controller == null || !_controller!.value.isInitialized)
                const Center(
                  child: Icon(
                    Icons.videocam_off,
                    color: Colors.white54,
                    size: 24,
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      // Mirror front camera preview
                      transform: Matrix4.rotationY(3.14159),
                      child: CameraPreview(_controller!),
                    ),
                  ),
                ),

              // Overlay if no face is detected
              if (!_isInitializing && !_hasError && _controller != null && _controller!.value.isInitialized && _noFaceDetected)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.75),
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.face_retouching_off,
                              color: AppColors.error,
                              size: 20,
                            ),
                            SizedBox(height: 4),
                            Text(
                              'يرجى إظهار الوجه\n(سيتم الإلغاء بعد ٣ ثوانٍ)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              // Scanning Overlay / Pulse indicators
              Positioned(
                top: 6,
                right: 6,
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isPulseOn ? AppColors.error : Colors.transparent,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'REC',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Label
              Positioned(
                bottom: 4,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  color: Colors.black54,
                  child: const Text(
                    'مراقبة الغش',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
