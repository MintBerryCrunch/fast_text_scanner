import 'package:flutter/foundation.dart';

/// Supported resolutions. Not all devices support all resolutions!
enum Resolution { sd480, hd720, hd1080, hd4k }

extension ResolutionName on Resolution {
  String get name => describeEnum(this);
}

/// Supported Framerates. Not all devices support all framerates!
enum Framerate { fps30, fps60, fps120, fps240 }

extension FramerateName on Framerate {
  String get name => describeEnum(this);
}

/// Dictates how the camera reacts to detections
enum DetectionMode {
  /// Pauses the detection of further barcodes when a barcode is detected.
  /// The camera feed continues.
  pauseDetection,

  /// Pauses the camera feed on detection.
  /// This will inevitably stop the detection of barcodes.
  pauseVideo,

  /// Does nothing on detection. May need to throttle detections using continuous.
  continuous
}

extension DetectionModeName on DetectionMode {
  String get name => describeEnum(this);
}

/// The position of the camera.
enum CameraPosition { front, back }

extension CameraPositionName on CameraPosition {
  String get name => describeEnum(this);
}

/// Image inversion mode (to support barcodes in inverted colors).
/// The inversion is applied to the recognition stream only. Camera preview always stays unchanged.
/// Currently, only images of YUV_420_888 format can be inverted.
///
/// This is an Android-only feature.
/// (Apparently, Google ML kit does not support inverted data matrix barcodes, and this is a workaround to support them.
/// On the other hand, iOS Vision supports them out-of-the-box, so no manual inversion is needed.)
enum ImageInversion {
  /// All frames are kept as is. This is the default option.
  none,

  /// Every frame is inverted.
  invertAllFrames,

  /// Every 2nd frame is inverted. Useful if both inverted and not inverted barcodes should be recognized.
  alternateFrameInversion
}

extension ImageInversionName on ImageInversion {
  String get name => describeEnum(this);
}

enum ScanMode {
  /// Use Barcode scanner flow
  barcode,

  /// Use Text Recognition flow
  textRecognition,
}

extension ScanModeName on ScanMode {
  String get name => describeEnum(this);
}

/// The configuration by which the camera feed can be laid out in the UI.
class PreviewConfiguration {
  /// The width of the camera feed in points.
  final int width;

  /// The height of the camera feed in points.
  final int height;

  /// Expresses how many quarters the texture has to be rotated to be upright
  /// in clockwise direction.
  final int targetRotation;

  /// A id of a texture which contains the camera feed.
  ///
  /// Can be consumed by a [Texture] widget.
  final int textureId;

  /// The resolution which is used when scanning for barcodes.
  final String analysisResolution;

  PreviewConfiguration(Map<dynamic, dynamic> response)
      : textureId = response["textureId"],
        targetRotation = response["targetRotation"],
        height = response["height"],
        width = response["width"],
        analysisResolution = response["analysis"];

  @override
  bool operator ==(Object other) =>
      other is PreviewConfiguration &&
      other.textureId == textureId &&
      other.height == height &&
      other.width == width &&
      other.targetRotation == targetRotation &&
      other.analysisResolution == analysisResolution;

  @override
  int get hashCode =>
      super.hashCode ^
      textureId.hashCode ^
      height.hashCode ^
      width.hashCode ^
      targetRotation.hashCode ^
      analysisResolution.hashCode;
}
