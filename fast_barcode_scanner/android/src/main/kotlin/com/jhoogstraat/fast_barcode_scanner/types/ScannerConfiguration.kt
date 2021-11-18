package com.jhoogstraat.fast_barcode_scanner.types

import com.google.mlkit.vision.barcode.Barcode

data class ScannerConfiguration(
    val detectionMode: DetectionMode,
    val resolution: Resolution,
    val framerate: Framerate,
    val position: CameraPosition,
    val scanMode: ScanMode,
    val barcodeTypesEncoded: IntArray,
    val textRecognitionTypes: List<TextRecognitionType>,
    val inversion: ImageInversion,
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as ScannerConfiguration

        if (detectionMode != other.detectionMode) return false
        if (resolution != other.resolution) return false
        if (framerate != other.framerate) return false
        if (position != other.position) return false
        if (scanMode != other.scanMode) return false
        if (!barcodeTypesEncoded.contentEquals(other.barcodeTypesEncoded)) return false
        if (textRecognitionTypes != other.textRecognitionTypes) return false
        if (inversion != other.inversion) return false

        return true
    }

    override fun hashCode(): Int {
        var result = detectionMode.hashCode()
        result = 31 * result + resolution.hashCode()
        result = 31 * result + framerate.hashCode()
        result = 31 * result + position.hashCode()
        result = 31 * result + scanMode.hashCode()
        result = 31 * result + barcodeTypesEncoded.contentHashCode()
        result = 31 * result + textRecognitionTypes.hashCode()
        result = 31 * result + inversion.hashCode()
        return result
    }
}

val barcodeFormatMap = hashMapOf(
    "aztec" to Barcode.FORMAT_AZTEC,
    "code128" to Barcode.FORMAT_CODE_128,
    "code39" to Barcode.FORMAT_CODE_39,
    "code93" to Barcode.FORMAT_CODE_93,
    "codabar" to Barcode.FORMAT_CODABAR,
    "dataMatrix" to Barcode.FORMAT_DATA_MATRIX,
    "ean13" to Barcode.FORMAT_EAN_13,
    "ean8" to Barcode.FORMAT_EAN_8,
    "itf" to Barcode.FORMAT_ITF,
    "pdf417" to Barcode.FORMAT_PDF417,
    "qr" to Barcode.FORMAT_QR_CODE,
    "upcA" to Barcode.FORMAT_UPC_A,
    "upcE" to Barcode.FORMAT_UPC_E
)

val barcodeStringMap = barcodeFormatMap.entries.associateBy({ it.value }) { it.key }