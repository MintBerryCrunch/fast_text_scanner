import 'package:fast_barcode_scanner_platform_interface/fast_barcode_scanner_platform_interface.dart';

/// The configuration of the camera and scanner.
///
/// Holds detailed information about the running camera session.
class ScannerConfiguration {
  const ScannerConfiguration(
    this.resolution,
    this.framerate,
    this.position,
    this.detectionMode,
    this.scanMode,
    this.barcodeTypes,
    this.textRecognitionTypes,
    this.imageInversion,
  );

  /// The target resolution of the camera feed.
  ///
  /// This is experimental, but functional. Should not be set higher
  /// than necessary.
  final Resolution resolution;

  /// The target framerate of the camera feed.
  ///
  /// This is experimental, but functional on iOS. Should not be set higher
  /// than necessary.
  final Framerate framerate;

  /// The physical position of the camera being used.
  final CameraPosition position;

  /// Determines how the camera reacts to detected barcodes.
  final DetectionMode detectionMode;

  final ScanMode scanMode;

  /// The types the scanner should look out for.
  ///
  /// If a barcode type is not in this list, it will not be detected.
  final List<BarcodeType> barcodeTypes;

  /// The types the scanner should look out for.
  ///
  /// If a barcode type is not in this list, it will not be detected.
  final List<TextRecognitionType> textRecognitionTypes;

  final ImageInversion imageInversion;

  ScannerConfiguration copyWith({
    Resolution? resolution,
    Framerate? framerate,
    DetectionMode? detectionMode,
    CameraPosition? position,
    ScanMode? scanMode,
    List<BarcodeType>? barcodeTypes,
    List<TextRecognitionType>? textRecognitionTypes,
    ImageInversion? imageInversion,
  }) {
    return ScannerConfiguration(
      resolution ?? this.resolution,
      framerate ?? this.framerate,
      position ?? this.position,
      detectionMode ?? this.detectionMode,
      scanMode ?? this.scanMode,
      barcodeTypes ?? this.barcodeTypes,
      textRecognitionTypes ?? this.textRecognitionTypes,
      imageInversion ?? this.imageInversion,
    );
  }
}
