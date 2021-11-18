package com.jhoogstraat.fast_barcode_scanner.scanner

import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.text.TextRecognition
import com.google.mlkit.vision.text.latin.TextRecognizerOptions
import com.jhoogstraat.fast_barcode_scanner.types.ImageInversion
import com.jhoogstraat.fast_barcode_scanner.types.RecognizedText
import com.jhoogstraat.fast_barcode_scanner.types.TextRecognitionType

class MLKitTextScanner(
    textRecognitionTypes: List<TextRecognitionType>,
    imageInversion: ImageInversion,
    private val successListener: (List<RecognizedText>) -> Unit,
    private val failureListener: (Exception) -> Unit
) : ImageAnalysis.Analyzer {
    private val textRecognizer = TextRecognition.getClient(TextRecognizerOptions.DEFAULT_OPTIONS)
    private val imagePreprocessor = ImagePreprocessor(imageInversion, 90)

    @ExperimentalGetImage
    override fun analyze(imageProxy: ImageProxy) {
        // TODO textRecognitionTypes
        val inputImage = imagePreprocessor.preprocessImage(imageProxy)
        textRecognizer.process(inputImage)
            .addOnSuccessListener { result ->
                val mapped = result.textBlocks
                    .flatMap { it.lines }
                    // TODO textRecognitionTypes
                    .map { RecognizedText(it.text, TextRecognitionType.peruMask) }
                successListener(mapped)
            }
            .addOnFailureListener(failureListener)
            .addOnCompleteListener { imageProxy.close() }
    }
}
