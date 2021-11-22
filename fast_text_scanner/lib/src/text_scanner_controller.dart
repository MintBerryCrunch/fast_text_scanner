import 'dart:async';

import 'package:fast_text_scanner_platform_interface/fast_text_scanner_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../fast_text_scanner.dart';
import 'types/scanner_configuration.dart';

class TextScannerState {
  PreviewConfiguration? _previewConfig;
  ScannerConfiguration? _scannerConfig;
  bool _torch = false;
  Object? _error;

  PreviewConfiguration? get previewConfig => _previewConfig;
  ScannerConfiguration? get scannerConfig => _scannerConfig;
  bool get torchState => _torch;
  bool get isInitialized => _previewConfig != null;
  bool get hasError => _error != null;
  Object? get error => _error;
}

/// Middleman, handling the communication with native platforms.
///
/// Allows for custom backends.
abstract class TextScannerController {
  static final _instance = _TextScannerCameraController._internal();

  factory TextScannerController() => _instance;

  /// The cumulated state of the barcode scanner.
  ///
  /// Contains information about the configuration, torch,
  /// errors and events.
  final state = TextScannerState();

  /// A [ValueNotifier] for camera state events.
  ///
  ///
  final ValueNotifier<ScannerEvent> events =
      ValueNotifier(ScannerEvent.uninitialized);

  /// Informs the platform to initialize the camera.
  ///
  /// Events and errors are received via the current state's eventNotifier.
  Future<void> initialize(
    Resolution resolution,
    Framerate framerate,
    DetectionMode detectionMode,
    CameraPosition position,
    ScanMode scanMode,
    void Function(List<ScanResult>)? onScan, [
    // Ignored if scanMode != barcode
    List<BarcodeType> barcodeTypes = const [],
    // Ignored if scanMode != textRecognition
    List<TextRecognitionType> textRecognitionTypes = const [],
    ImageInversion imageInversion = ImageInversion.none,
  ]);

  /// Stops the camera and disposes all associated resources.
  ///
  ///
  Future<void> dispose();

  /// Resumes the preview on the platform level.
  ///
  ///
  Future<void> resumeCamera();

  /// Pauses the preview on the platform level.
  ///
  ///
  Future<void> pauseCamera();

  /// Resumes the scanner on the platform level.
  ///
  ///
  Future<void> resumeScanner();

  /// Pauses the scanner on the platform level.
  ///
  ///
  Future<void> pauseScanner();

  /// Toggles the torch, if available.
  ///
  ///
  Future<bool> toggleTorch();

  /// Set the torch state, if available.
  ///
  ///
  Future<bool> setTorch(bool on);

  /// Reconfigure the scanner.
  ///
  /// Can be called while running.
  Future<void> configure({
    Resolution? resolution,
    Framerate? framerate,
    DetectionMode? detectionMode,
    CameraPosition? position,
    ScanMode? scanMode,
    List<BarcodeType>? barcodeTypes,
    List<TextRecognitionType>? textRecognitionTypes,
    ImageInversion? imageInversion,
    void Function(List<ScanResult>)? onScan,
  });

  /// Analyze a still image, which can be chosen from an image picker.
  ///
  /// It is recommended to pause the live scanner before calling this.
  Future<List<ScanResult>?> scanImage(ImageSource source);
}

class _TextScannerCameraController implements TextScannerController {
  _TextScannerCameraController._internal() : super();

  final FastTextScannerPlatform _platform = FastTextScannerPlatform.instance;

  @override
  final state = TextScannerState();

  @override
  final events = ValueNotifier(ScannerEvent.uninitialized);

  /// Indicates if the torch is currently switching.
  ///
  /// Used to prevent command-spamming.
  bool _togglingTorch = false;

  /// Indicates if the camera is currently configuring itself.
  ///
  /// Used to prevent command-spamming.
  bool _configuring = false;

  /// User-defined handler, called when a barcode is detected
  void Function(List<ScanResult>)? _onScan;

  @override
  Future<void> initialize(
    Resolution resolution,
    Framerate framerate,
    DetectionMode detectionMode,
    CameraPosition position,
    ScanMode scanMode,
    void Function(List<ScanResult>)? onScan, [
    // Ignored if scanMode != barcode
    List<BarcodeType> barcodeTypes = const [],
    // Ignored if scanMode != textRecognition
    List<TextRecognitionType> textRecognitionTypes = const [],
    ImageInversion imageInversion = ImageInversion.none,
  ]) async {
    try {
      state._previewConfig = await _platform.init(
        resolution,
        framerate,
        detectionMode,
        position,
        scanMode,
        barcodeTypes,
        textRecognitionTypes,
        imageInversion,
      );

      _onScan = onScan;

      _platform.setOnDetectHandler(_onDetectHandler);

      state._scannerConfig = ScannerConfiguration(
          resolution,
          framerate,
          position,
          detectionMode,
          scanMode,
          barcodeTypes,
          textRecognitionTypes,
          imageInversion);

      state._error = null;

      events.value = ScannerEvent.resumed;
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      await _platform.dispose();
      state._scannerConfig = null;
      state._previewConfig = null;
      state._torch = false;
      state._error = null;
      events.value = ScannerEvent.uninitialized;
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<void> pauseCamera() async {
    try {
      await _platform.stop();
      events.value = ScannerEvent.paused;
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<void> resumeCamera() async {
    try {
      await _platform.start();
      events.value = ScannerEvent.resumed;
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<void> pauseScanner() async {
    try {
      await _platform.stopDetector();
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<void> resumeScanner() async {
    try {
      await _platform.startDetector();
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  @override
  Future<bool> toggleTorch() async {
    if (!_togglingTorch) {
      _togglingTorch = true;

      try {
        state._torch = await _platform.toggleTorch();
      } catch (error) {
        state._error = error;
        events.value = ScannerEvent.error;
        rethrow;
      }

      _togglingTorch = false;
    }

    return state._torch;
  }

  @override
  Future<void> configure({
    Resolution? resolution,
    Framerate? framerate,
    DetectionMode? detectionMode,
    CameraPosition? position,
    ScanMode? scanMode,
    List<BarcodeType>? barcodeTypes,
    List<TextRecognitionType>? textRecognitionTypes,
    ImageInversion? imageInversion,
    void Function(List<ScanResult>)? onScan,
  }) async {
    if (state.isInitialized && !_configuring) {
      final _scannerConfig = state._scannerConfig!;
      _configuring = true;

      try {
        state._previewConfig = await _platform.changeConfiguration(
          resolution: resolution,
          framerate: framerate,
          detectionMode: detectionMode,
          position: position,
          scanMode: scanMode,
          barcodeTypes: barcodeTypes,
          textRecognitionTypes: textRecognitionTypes,
          imageInversion: imageInversion,
        );

        state._scannerConfig = _scannerConfig.copyWith(
          resolution: resolution,
          framerate: framerate,
          detectionMode: detectionMode,
          position: position,
          scanMode: scanMode,
          barcodeTypes: barcodeTypes,
          textRecognitionTypes: textRecognitionTypes,
          imageInversion: imageInversion,
        );

        if (onScan != null) {
          _onScan = onScan;
        }
      } catch (error) {
        state._error = error;
        events.value = ScannerEvent.error;
        rethrow;
      }

      _configuring = false;
    }
  }

  @override
  Future<List<ScanResult>?> scanImage(ImageSource source) async {
    try {
      return _platform.scanImage(source);
    } catch (error) {
      state._error = error;
      events.value = ScannerEvent.error;
      rethrow;
    }
  }

  void _onDetectHandler(List<ScanResult> code) {
    events.value = ScannerEvent.detected;
    _onScan?.call(code);
  }

  @override
  Future<bool> setTorch(bool on) async {
    if (!_togglingTorch) {
      _togglingTorch = true;
      try {
        state._torch = await _platform.setTorch(on);
      } catch (error) {
        state._error = error;
        events.value = ScannerEvent.error;
        rethrow;
      }

      _togglingTorch = false;
    }

    return state._torch;
  }
}
