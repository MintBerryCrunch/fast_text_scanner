import 'package:fast_text_scanner/fast_text_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../history_screen/history_screen.dart';
import '../scan_history.dart';

class ScansCounter extends StatefulWidget {
  const ScansCounter({Key? key}) : super(key: key);

  @override
  _ScansCounterState createState() => _ScansCounterState();
}

class _ScansCounterState extends State<ScansCounter> {
  @override
  void initState() {
    super.initState();
    history.addListener(onBarcodeListener);
  }

  @override
  void dispose() {
    history.removeListener(onBarcodeListener);
    super.dispose();
  }

  void onBarcodeListener() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final barcode = history.recent;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      child: Row(
        children: [
          Expanded(
            child: barcode != null
                ? _barcodeDescription(barcode)
                : const SizedBox.shrink(),
          ),
          TextButton(
              onPressed: () async {
                final controller = TextScannerController();
                controller.pauseCamera();
                await Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HistoryScreen()));
                controller.resumeCamera();
              },
              child: const Text('History'))
        ],
      ),
    );
  }

  Text _barcodeDescription(ScanResult barcode) {
    if (barcode.barcodeType == null) {
      return Text("${history.count(barcode)}x\n${barcode.value}");
    }
    return Text(
        "${history.count(barcode)}x\n${describeEnum(barcode.barcodeType!)} - ${(barcode.barcodeValueType != null ? describeEnum(barcode.barcodeValueType!) : "")}: ${barcode.value}");
  }
}
