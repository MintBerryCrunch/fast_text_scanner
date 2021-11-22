import 'dart:ui';

import 'package:fast_text_scanner/fast_text_scanner.dart';
import 'package:fast_text_scanner/src/text_scanner_controller.dart';
import 'package:fast_text_scanner_platform_interface/fast_text_scanner_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

typedef ErrorCallback = Widget Function(BuildContext context, Object? error);

Widget _defaultOnError(BuildContext context, Object? error) {
  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Center(
      child: Text(
        "Error:\n$error",
        style: const TextStyle(color: Colors.white),
      ),
    ),
  );
}

/// The main class connecting the platform code to the UI.
///
/// This class is used in the widget tree and connects to the camera
/// as soon as didChangeDependencies gets called.
class TextScannerCamera extends StatefulWidget {
  const TextScannerCamera({
    Key? key,
    this.detectionMode = DetectionMode.pauseVideo,
    this.resolution = Resolution.hd720,
    this.framerate = Framerate.fps30,
    this.position = CameraPosition.back,
    this.scanMode = ScanMode.barcode,
    this.barcodeTypes = const [],
    this.textRecognitionTypes = const [],
    this.imageInversion = ImageInversion.none,
    this.onScan,
    this.children = const [],
    this.dispose = true,
    ErrorCallback? onError,
  })  : onError = onError ?? _defaultOnError,
        super(key: key);

  final Resolution resolution;
  final Framerate framerate;
  final DetectionMode detectionMode;
  final CameraPosition position;
  final ScanMode scanMode;
  final List<BarcodeType> barcodeTypes;
  final List<TextRecognitionType> textRecognitionTypes;
  final ImageInversion imageInversion;
  final void Function(List<ScanResult>)? onScan;
  final List<Widget> children;
  final ErrorCallback onError;
  final bool dispose;

  @override
  TextScannerCameraState createState() => TextScannerCameraState();
}

class TextScannerCameraState extends State<TextScannerCamera> {
  var _opacity = 0.0;
  var showingError = false;

  final scannerController = TextScannerController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final configurationFuture = scannerController.state.isInitialized
        ? scannerController.configure(
            resolution: widget.resolution,
            framerate: widget.framerate,
            position: widget.position,
            scanMode: widget.scanMode,
            barcodeTypes: widget.barcodeTypes,
            textRecognitionTypes: widget.textRecognitionTypes,
            imageInversion: widget.imageInversion,
            onScan: widget.onScan,
          )
        : scannerController.initialize(
            widget.resolution,
            widget.framerate,
            widget.detectionMode,
            widget.position,
            widget.scanMode,
            widget.onScan,
            widget.barcodeTypes,
            widget.textRecognitionTypes,
            widget.imageInversion,
          );

    configurationFuture
        .whenComplete(() => setState(() => _opacity = 1.0))
        .onError((error, stackTrace) => setState(() => showingError = true));

    scannerController.events.addListener(onScannerEvent);
  }

  void onScannerEvent() {
    if (scannerController.events.value != ScannerEvent.error && showingError) {
      setState(() => showingError = false);
    } else if (scannerController.events.value == ScannerEvent.error) {
      setState(() => showingError = true);
    }
  }

  @override
  void dispose() {
    if (widget.dispose) {
      scannerController.dispose();
    } else {
      scannerController.pauseCamera();
    }

    scannerController.events.removeListener(onScannerEvent);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = scannerController.state;
    return ColoredBox(
      color: Colors.black,
      child: AnimatedOpacity(
        opacity: _opacity,
        duration: const Duration(milliseconds: 260),
        child: scannerController.events.value == ScannerEvent.error
            ? widget.onError(
                context,
                cameraState.error ?? "Unknown error occured",
              )
            : Stack(
                fit: StackFit.expand,
                children: [
                  if (cameraState.isInitialized)
                    _buildPreview(cameraState.previewConfig!),
                  ...widget.children
                ],
              ),
      ),
    );
  }

  Widget _buildPreview(PreviewConfiguration config) {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: config.width.toDouble(),
        height: config.height.toDouble(),
        child: Builder(
          builder: (_) {
            switch (defaultTargetPlatform) {
              case TargetPlatform.android:
                return Texture(
                  textureId: config.textureId,
                  filterQuality: FilterQuality.none,
                );
              case TargetPlatform.iOS:
                return const UiKitView(
                  viewType: "fast_text_scanner.preview",
                  creationParamsCodec: StandardMessageCodec(),
                );
              default:
                throw UnsupportedError("Unsupported platform");
            }
          },
        ),
      ),
    );
  }
}
