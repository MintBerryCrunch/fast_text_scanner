package com.jhoogstraat.fast_barcode_scanner.scanner

import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.jhoogstraat.fast_barcode_scanner.types.ImageInversion

class MLKitBarcodeScanner(
    options: BarcodeScannerOptions,
    imageInversion: ImageInversion,
    private val successListener: (List<Barcode>) -> Unit,
    private val failureListener: (Exception) -> Unit
) : ImageAnalysis.Analyzer {
    private val scanner = BarcodeScanning.getClient(options)
    private val imagePreprocessor = ImagePreprocessor(imageInversion, null)

    @ExperimentalGetImage
    override fun analyze(imageProxy: ImageProxy) {
        val inputImage = imagePreprocessor.preprocessImage(imageProxy)
        scanner.process(inputImage)
                .addOnSuccessListener(successListener)
                .addOnFailureListener(failureListener)
                .addOnCompleteListener { imageProxy.close() }
    }
}
