package com.jhoogstraat.fast_barcode_scanner.types

data class RecognizedText(
    val value: String,
    val recognitionType: TextRecognitionType
)