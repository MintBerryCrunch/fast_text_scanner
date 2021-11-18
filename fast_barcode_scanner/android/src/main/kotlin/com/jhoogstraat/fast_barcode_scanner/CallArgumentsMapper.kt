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
}