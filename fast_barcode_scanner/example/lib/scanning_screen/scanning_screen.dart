import 'package:fast_barcode_scanner/fast_barcode_scanner.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../configure_screen/configure_screen.dart';
import '../scan_history.dart';
import '../utils.dart';
import 'scans_counter.dart';

class ScanningScreen extends StatefulWidget {
  const ScanningScreen({Key? key, required this.dispose}) : super(key: key);

  final bool dispose;

  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  final _torchIconState = ValueNotifier(false);
  final _cameraRunning = ValueNotifier(true);
  final _scannerRunning = ValueNotifier(true);

  final controller = ScannerController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Fast Barcode Scanner',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              final preview = controller.state.previewConfig;
              if (preview != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Preview Config"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Texture Id: ${preview.textureId}"),
                        Text(
                            "Preview (WxH): ${preview.width}x${preview.height}"),
                        Text("Analysis (WxH): ${preview.analysisResolution}"),
                        Text(
                            "Target Rotation (unused): ${preview.targetRotation}"),
                      ],
                    ),
                  ),
                );
              }
            },
          )
        ],
      ),
      body: ScannerCamera(
        resolution: Resolution.hd720,
        framerate: Framerate.fps30,
        detectionMode: DetectionMode.pauseDetection,
        position: CameraPosition.back,
        scanMode: ScanMode.textRecognition,
        textRecognitionTypes: const [TextRecognitionType.peruMask],
        imageInversion: ImageInversion.none,
        onScan: (codes) {
          codes.forEach((code) {
            debugPrint('============ Code: $code ${code.value}');
            history.add(code);
          });
        },
        children: const [
          MaterialPreviewOverlay(),
          // BlurPreviewOverlay()
        ],
        dispose: widget.dispose,
      ),
      bottomSheet: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScansCounter(),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      ValueListenableBuilder<bool>(
                          valueListenable: _cameraRunning,
                          builder: (context, isRunning, _) {
                            return ElevatedButton(
                              onPressed: () {
                                final future = isRunning
                                    ? controller.pauseCamera()
                                    : controller.resumeCamera();

                                future
                                    .then((_) =>
                                        _cameraRunning.value = !isRunning)
                                    .catchError((error, stack) {
                                  presentErrorAlert(context, error, stack);
                                });
                              },
                              child: Text(
                                  isRunning ? 'Pause Camera' : 'Resume Camera'),
                            );
                          }),
                      ValueListenableBuilder<bool>(
                          valueListenable: _scannerRunning,
                          builder: (context, isRunning, _) {
                            return ElevatedButton(
                              onPressed: () {
                                final future = isRunning
                                    ? controller.pauseScanner()
                                    : controller.resumeScanner();

                                future
                                    .then((_) =>
                                        _scannerRunning.value = !isRunning)
                                    .catchError((error, stackTrace) {
                                  presentErrorAlert(context, error, stackTrace);
                                });
                              },
                              child: Text(isRunning
                                  ? 'Pause Scanner'
                                  : 'Resume Scanner'),
                            );
                          }),
                      ValueListenableBuilder<bool>(
                        valueListenable: _torchIconState,
                        builder: (context, isTorchActive, _) => ElevatedButton(
                          onPressed: () {
                            controller
                                .setTorch(!isTorchActive)
                                .then((torchState) =>
                                    _torchIconState.value = torchState)
                                .catchError((error, stackTrace) {
                              presentErrorAlert(context, error, stackTrace);
                            });
                          },
                          child: Text('Torch: ${isTorchActive ? 'on' : 'off'}'),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final config = controller.state.scannerConfig;
                          if (config != null) {
                            // swallow errors
                            controller.pauseCamera().catchError((_, __) {});

                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ConfigureScreen(config),
                              ),
                            );

                            controller.resumeCamera().catchError(
                                (error, stack) =>
                                    presentErrorAlert(context, error, stack));
                          }
                        },
                        child: const Text('Update Configuration'),
                      )
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
