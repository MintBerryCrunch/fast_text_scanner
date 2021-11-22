import 'package:fast_text_scanner_platform_interface/src/types/scanner_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CameraPosition should contain 2 options', () {
    const values = CameraPosition.values;
    expect(values.length, 2);
  });

  test("CameraPosition extension returns correct values", () {
    expect(CameraPosition.front.name, 'front');
    expect(CameraPosition.back.name, 'back');
  });
}
