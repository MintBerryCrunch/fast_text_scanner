import 'package:fast_text_scanner_platform_interface/fast_text_scanner_platform_interface.dart';
import 'package:fast_text_scanner_platform_interface/src/method_channel_fast_text_scanner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('$MethodChannelFastTextScanner is the default implementation', () {
    expect(FastTextScannerPlatform.instance,
        isA<MethodChannelFastTextScanner>());
  });

  test('Cannot be implemented with `implements`', () {
    expect(() {
      FastTextScannerPlatform.instance = ImplementsFastTextScannerPlatform();
    }, throwsNoSuchMethodError);
  });

  test('Can be extended', () {
    FastTextScannerPlatform.instance = ExtendsFastTextScannerPlatform();
  });
}

class ImplementsFastTextScannerPlatform implements FastTextScannerPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ExtendsFastTextScannerPlatform extends FastTextScannerPlatform {}
