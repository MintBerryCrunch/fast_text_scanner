import 'package:fast_text_scanner_platform_interface/src/types/scanner_configuration.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DetectionMode should contain 3 options', () {
    const values = DetectionMode.values;
    expect(values.length, 3);
  });

  test("DetectionMode extension returns correct values", () {
    expect(DetectionMode.pauseDetection.name, 'pauseDetection');
    expect(DetectionMode.pauseVideo.name, 'pauseVideo');
    expect(DetectionMode.continuous.name, 'continuous');
  });
}
