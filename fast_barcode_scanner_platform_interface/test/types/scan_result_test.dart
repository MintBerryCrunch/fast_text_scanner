import 'package:fast_barcode_scanner_platform_interface/fast_barcode_scanner_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Should initialize barcode type and value with list', () {
    final barcodeEan13 = ScanResult(["1234", "ean13", null, null]);
    final barcodeQR = ScanResult(["This is a QR Code", "qr", null, null]);

    expect(barcodeEan13.barcodeType, BarcodeType.ean13);
    expect(barcodeEan13.value, "1234");

    expect(barcodeQR.barcodeType, BarcodeType.qr);
    expect(barcodeQR.value, "This is a QR Code");
  });

  test('Should initialize recognized text type and value with list', () {
    final barcodeEan13 = ScanResult(["1234", null, null, "peruMask"]);

    expect(barcodeEan13.textRecognitionType, TextRecognitionType.peruMask);
    expect(barcodeEan13.value, "1234");
  });

  test("Should throw A StateError if invalid type is provided", () {
    expect(() => ScanResult([ "1234", "invalid_type", null, null]), throwsStateError);
    expect(() => ScanResult(["1234", 1234, null, null]), throwsStateError);
  });

  test("Should throw a TypeError if value is not of type String", () {
    expect(() => ScanResult([1234, "ean13", null, null]), throwsA(isA<TypeError>()));
    expect(() => ScanResult([12.34, "ean13", null, null]), throwsA(isA<TypeError>()));
  });

  test('Should be value-equatable', () {
    final barcode1 = ScanResult(["1234", "ean13", null, null]);
    final barcode1Copy = ScanResult(["1234", "ean13", null, null]);

    final barcode2 = ScanResult(["4321", "qr", null, null]);
    final barcode2Copy = ScanResult(["4321", "qr", null, null]);

    expect(barcode1 == barcode1, true);
    expect(barcode2 == barcode2, true);
    expect(barcode1 == barcode2, false);
    expect(barcode1 == barcode1Copy, true);
    expect(barcode2 == barcode2Copy, true);
  });
}
