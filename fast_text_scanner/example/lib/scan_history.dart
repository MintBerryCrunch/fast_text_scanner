import 'package:fast_text_scanner/fast_text_scanner.dart';
import 'package:flutter/cupertino.dart';

final history = ScanHistory();

class ScanHistory extends ChangeNotifier {
  final scans = <ScanResult>[];
  final counter = <String, int>{};

  ScanResult? get recent => scans.isNotEmpty ? scans.last : null;
  int count(ScanResult of) => counter[of.value] ?? 0;

  void add(ScanResult barcode) {
    scans.add(barcode);
    counter.update(barcode.value, (value) => value + 1, ifAbsent: () => 1);
    notifyListeners();
  }

  void clear() {
    scans.clear();
    counter.clear();
    notifyListeners();
  }
}
