package com.jhoogstraat.fast_barcode_scanner

import com.google.mlkit.vision.barcode.Barcode
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
            barcode.valueType,
            null
        )
    }
}