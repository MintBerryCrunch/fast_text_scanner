package com.jhoogstraat.fast_barcode_scanner

import android.util.Log
import com.jhoogstraat.fast_barcode_scanner.types.*

class CallArgumentsMapper {
    companion object {
        private const val TAG = "fast_barcode_scanner"
    }

    fun parseInitArgs(args: Map<String, Any>): ScannerConfiguration {
        val barcodeTypes = (args["barcodeTypes"] as List<String>)
        val textRecognitionTypes = (args["textRecognitionTypes"] as List<String>)

        try {
            val scannerConfiguration = ScannerConfiguration(
                detectionMode = DetectionMode.valueOf(args["mode"] as String),
                resolution = Resolution.valueOf(args["res"] as String),
                framerate = Framerate.valueOf(args["fps"] as String),
                position = CameraPosition.valueOf(args["pos"] as String),
                scanMode = ScanMode.valueOf(args["scanMode"] as String),
                barcodeTypesEncoded = barcodeTypes.mapNotNull { barcodeFormatMap[it] }
                    .toIntArray(),
                textRecognitionTypes = textRecognitionTypes.map { TextRecognitionType.valueOf(it) },
                inversion = ImageInversion.valueOf(args["inv"] as String),
            )

            // Report to the user if any types are not supported
            if (barcodeTypes.count() != scannerConfiguration.barcodeTypesEncoded.count()) {
                val unsupportedTypes = barcodeTypes.filter { !barcodeFormatMap.containsKey(it) }
                Log.d(TAG, "WARNING: Unsupported barcode types selected: $unsupportedTypes")
            }

            return scannerConfiguration
        } catch (e: Exception) {
            throw ScannerException.InvalidArguments(args)
        }
    }

    fun parseChangeConfigArgs(
        args: Map<String, Any>,
        currentConfiguration: ScannerConfiguration
    ): ScannerConfiguration {
        try {
            val detectionMode =
                if (args.containsKey("mode")) DetectionMode.valueOf(args["mode"] as String) else currentConfiguration.detectionMode
            val resolution =
                if (args.containsKey("res")) Resolution.valueOf(args["res"] as String) else currentConfiguration.resolution
            val framerate =
                if (args.containsKey("fps")) Framerate.valueOf(args["fps"] as String) else currentConfiguration.framerate
            val position =
                if (args.containsKey("pos")) CameraPosition.valueOf(args["pos"] as String) else currentConfiguration.position
            val scanMode =
                if (args.containsKey("scanMode")) ScanMode.valueOf(args["scanMode"] as String) else currentConfiguration.scanMode
            val barcodeTypesEncoded = if (args.containsKey("barcodeTypes")) (args["barcodeTypes"] as List<String>).map {
                barcodeFormatMap[it] ?: throw ScannerException.InvalidCodeType(it)
            }.toIntArray() else currentConfiguration.barcodeTypesEncoded
            val textRecognitionTypes =
                if (args.containsKey("textRecognitionTypes")) (args["textRecognitionTypes"] as List<String>).map {
                    TextRecognitionType.valueOf(it)
                } else currentConfiguration.textRecognitionTypes
            val inversion =
                if (args.containsKey("inv")) ImageInversion.valueOf(args["inv"] as String) else currentConfiguration.inversion

            return currentConfiguration.copy(
                detectionMode = detectionMode,
                resolution = resolution,
                framerate = framerate,
                position = position,
                scanMode = scanMode,
                barcodeTypesEncoded = barcodeTypesEncoded,
                textRecognitionTypes = textRecognitionTypes,
                inversion = inversion
            )
        } catch (e: ScannerException) {
            throw e
        } catch (e: Exception) {
            throw ScannerException.InvalidArguments(args)
        }
    }
}