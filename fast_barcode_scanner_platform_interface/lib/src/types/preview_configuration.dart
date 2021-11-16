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
