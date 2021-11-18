package com.jhoogstraat.fast_barcode_scanner.scanner

import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.jhoogstraat.fast_barcode_scanner.ImageInvertor
import com.jhoogstraat.fast_barcode_scanner.types.ImageInversion

class ImagePreprocessor(
    imageInversion: ImageInversion,
    private val fixedRotationDegrees: Int?,
) {
    private val invertor = ImageInvertor(imageInversion)

    @ExperimentalGetImage
    fun preprocessImage(imageProxy: ImageProxy): InputImage {
        val originalImage = imageProxy.image!!
        invertor.invertImageIfNeeded(originalImage)
        return InputImage.fromMediaImage(originalImage, fixedRotationDegrees ?: imageProxy.imageInfo.rotationDegrees)
    }
}