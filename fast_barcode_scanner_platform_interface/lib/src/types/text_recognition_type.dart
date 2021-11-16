import 'package:flutter/foundation.dart';

/// Contains all currently supported text recognition types (on iOS and Android).
/// For now, all types use hard-coded text masks (see the implementation).
enum TextRecognitionType {
  peruMask,
  regularMask,
}

extension TextRecognitionTypeName on TextRecognitionType {
  String get name => describeEnum(this);
}
