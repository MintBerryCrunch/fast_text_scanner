package com.jhoogstraat.fast_barcode_scanner.mapper

import com.google.mlkit.vision.barcode.Barcode
import com.jhoogstraat.fast_barcode_scanner.types.RecognizedText
import com.jhoogstraat.fast_barcode_scanner.types.barcodeStringMap

class CallResultMapper {
    companion object {
        private const val TAG = "fast_barcode_scanner"
    }

    fun mapBarcodesToScanResult(barcodes: List<Barcode>?): List<List<*>> {
        if (barcodes == null) {
            return emptyList()
        }
        return barcodes.map { mapBarcodeToScanResult(it) }
    }

    private fun mapBarcodeToScanResult(barcode: Barcode): List<*> {
        return listOf(
            barcode.rawValue,
            barcodeStringMap[barcode.format],
            null,
            null
        )
    }

    fun mapTextToScanResult(entries: List<RecognizedText>?): List<List<*>> {
        if (entries == null) {
            return emptyList()
        }
        return entries.map { mapTextToScanResult(it) }
    }

    private fun mapTextToScanResult(text: RecognizedText): List<*> {
        return listOf(
            text.value,
            null,
            null,
            text.recognitionType.name
        )
    }
}