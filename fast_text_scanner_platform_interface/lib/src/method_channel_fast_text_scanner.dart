import 'dart:async';

import 'fast_text_scanner_platform_interface.dart';
import 'types/image_source.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'types/barcode_type.dart';
import 'types/preview_configuration.dart';
import 'types/scan_result.dart';
import 'types/scanner_configuration.dart';
import 'types/text_recognition_type.dart';

class MethodChannelFastTextScanner extends FastTextScannerPlatform {
  static const MethodChannel _channel =
      MethodChannel('com.redflag/fast_text_scanner');
  static const EventChannel _detectionEvents =
      EventChannel('com.redflag/fast_text_scanner/detections');

  final Stream<dynamic> _detectionEventStream =
      _detectionEvents.receiveBroadcastStream();
  StreamSubscription<dynamic>? _barcodeEventStreamSubscription;
  void Function(List<ScanResult>)? _onDetectHandler;

  @override
  Future<PreviewConfiguration> init(
    Resolution resolution,
    Framerate framerate,
    DetectionMode detectionMode,
    CameraPosition position,
    ScanMode scanMode, [
    // Ignored if scanMode != barcode
    List<BarcodeType> barcodeTypes = const [],
    // Ignored if scanMode != textRecognition
    List<TextRecognitionType> textRecognitionTypes = const [],
    ImageInversion imageInversion = ImageInversion.none,
  ]) async {
    final response = await _channel.invokeMethod('init', {
      'mode': detectionMode.name,
      'res': resolution.name,
      'fps': framerate.name,
      'pos': position.name,
      'scanMode': scanMode.name,
      'barcodeTypes': barcodeTypes.map((e) => e.name).toList(growable: false),
      'textRecognitionTypes':
          textRecognitionTypes.map((e) => e.name).toList(growable: false),
      'inv': imageInversion.name,
    });
    return PreviewConfiguration(response);
  }

  @override
  void setOnDetectHandler(void Function(List<ScanResult>) handler) async {
    _onDetectHandler = handler;
    _barcodeEventStreamSubscription ??=
        _detectionEventStream.listen(_handlePlatformBarcodeEvent);
  }

  @override
  Future<void> start() => _channel.invokeMethod('start');

  @override
  Future<void> stop() => _channel.invokeMethod('stop');

  @override
  Future<void> startDetector() => _channel.invokeMethod('startDetector');

  @override
  Future<void> stopDetector() => _channel.invokeMethod('stopDetector');

  @override
  Future<void> dispose() async {
    await _barcodeEventStreamSubscription?.cancel();
    _barcodeEventStreamSubscription = null;
    _onDetectHandler = null;
    return _channel.invokeMethod('dispose');
  }

  @override
  Future<bool> toggleTorch() =>
      _channel.invokeMethod('torch').then<bool>((isOn) => isOn);
  @override
  Future<bool> setTorch(bool on) =>
      _channel.invokeMethod('setTorch', on).then<bool>((isOn) => isOn);

  @override
  Future<PreviewConfiguration> changeConfiguration({
    Resolution? resolution,
    Framerate? framerate,
    DetectionMode? detectionMode,
    CameraPosition? position,
    ScanMode? scanMode,
    List<BarcodeType>? barcodeTypes,
    List<TextRecognitionType>? textRecognitionTypes,
    ImageInversion? imageInversion,
  }) async {
    final response = await _channel.invokeMethod('config', {
      if (detectionMode != null) 'mode': detectionMode.name,
      if (resolution != null) 'res': resolution.name,
      if (framerate != null) 'fps': framerate.name,
      if (position != null) 'pos': position.name,
      if (scanMode != null) 'scanMode': scanMode.name,
      if (barcodeTypes != null)
        'barcodeTypes': barcodeTypes.map((e) => e.name).toList(),
      if (textRecognitionTypes != null)
        'textRecognitionTypes':
            textRecognitionTypes.map((e) => e.name).toList(),
      if (imageInversion != null) 'inv': imageInversion.name,
    });
    return PreviewConfiguration(response);
  }

  @override
  Future<List<ScanResult>?> scanImage(ImageSource source) async {
    final List<Object?>? response = await _channel.invokeMethod(
      'scan',
      source.data,
    );

    return response?.map((e) => ScanResult(e as List<dynamic>)).toList();
  }

  void _handlePlatformBarcodeEvent(dynamic data) {
    // This might fail if the code type is not present in the list of available code types.
    // Barcode init will throw in this case. Ignore this cases and continue as if nothing happened.
    try {
      final entries =
          (data as List<dynamic>).map((e) => ScanResult(e)).toList();
      _onDetectHandler?.call(entries);
      // ignore: empty_catches
    } catch (e) {
      debugPrint("====== Error in handling scan result: $e");
    }
  }
}
