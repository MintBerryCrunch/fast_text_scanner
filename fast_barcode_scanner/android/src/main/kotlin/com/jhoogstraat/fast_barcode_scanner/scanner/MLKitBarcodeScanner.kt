package com.jhoogstraat.fast_barcode_scanner.scanner

import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import com.google.android.gms.tasks.OnFailureListener
import com.google.android.gms.tasks.OnSuccessListener
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage

class MLKitBarcodeScanner(
    options: BarcodeScannerOptions,
    imageInversion: ImageInversion,
    private val successListener: OnSuccessListener<List<Barcode>>,
    private val failureListener: OnFailureListener
) : ImageAnalysis.Analyzer {
    private val scanner = BarcodeScanning.getClient(options)
    private val invertor = ImageInvertor(imageInversion)

    @ExperimentalGetImage
    override fun analyze(imageProxy: ImageProxy) {
        val inputImage = preprocessImage(imageProxy)
        scanner.process(inputImage)
                .addOnSuccessListener(successListener)
                .addOnFailureListener(failureListener)
                .addOnCompleteListener { imageProxy.close() }
    }

    @ExperimentalGetImage
    private fun preprocessImage(imageProxy: ImageProxy): InputImage {
        val originalImage = imageProxy.image!!
        invertor.invertImageIfNeeded(originalImage)
        return InputImage.fromMediaImage(originalImage, imageProxy.imageInfo.rotationDegrees)
    }
}
