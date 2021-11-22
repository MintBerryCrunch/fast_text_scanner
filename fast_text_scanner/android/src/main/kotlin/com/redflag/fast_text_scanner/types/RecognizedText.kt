package com.redflag.fast_text_scanner.types

data class RecognizedText(
    val value: String,
    val recognitionType: TextRecognitionType
)