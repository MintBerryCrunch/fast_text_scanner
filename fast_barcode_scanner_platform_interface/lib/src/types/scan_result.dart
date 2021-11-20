import 'package:fast_barcode_scanner_platform_interface/fast_barcode_scanner_platform_interface.dart';
import 'package:fast_barcode_scanner_platform_interface/src/types/barcode_value_type.dart';
import 'package:flutter/foundation.dart';

/// Describes a ScanResult.
///
/// It always contain a value, and also contains
/// either a barcode description (type and value type)
/// or a recognized text description (type).
/// [ScanResult] is value-equatable.
class ScanResult {
  /// Creates a [ScanResult] from a Flutter Message Protocol
  ScanResult(List<dynamic> data)
      : value = data[0],
        barcodeType = data[1] == null
            ? null
            : BarcodeType.values.firstWhere((e) => describeEnum(e) == data[1]),
        barcodeValueType = data[2] == null
            ? null
            : BarcodeValueType.values
                .firstWhere((e) => describeEnum(e) == data[2]),
        textRecognitionType = data[3] == null
            ? null
            : TextRecognitionType.values
                .firstWhere((e) => describeEnum(e) == data[3]);

  /// The actual value of the barcode.
  ///
  ///
  final String value;

  /// The type of the barcode.
  ///
  ///
  final BarcodeType? barcodeType;

  /// The type of content of the barcode.
  ///
  /// On available on Android.
  /// Returns [null] on iOS.
  final BarcodeValueType? barcodeValueType;

  /// The type of the recognized text.
  ///
  ///
  final TextRecognitionType? textRecognitionType;

  @override
  bool operator ==(Object other) =>
      other is ScanResult &&
      other.value == value &&
      other.barcodeType == barcodeType &&
      other.barcodeValueType == barcodeValueType &&
      other.textRecognitionType == textRecognitionType;

  @override
  int get hashCode =>
      Object.hash(value, barcodeType, barcodeValueType, textRecognitionType);

  @override
  String toString() {
    return '''
    ScanResult {
      value: $value,
      barcodeType: $barcodeType,
      barcodeValueType: $barcodeValueType,
      textRecognitionType: $textRecognitionType
    }
    ''';
  }
}
