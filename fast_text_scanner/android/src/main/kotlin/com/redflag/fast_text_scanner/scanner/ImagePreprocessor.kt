package com.redflag.fast_text_scanner.scanner

import androidx.camera.core.ExperimentalGetImage
import androidx.camera.core.ImageProxy
import com.google.mlkit.vision.common.InputImage
import com.redflag.fast_text_scanner.ImageInvertor
import com.redflag.fast_text_scanner.types.ImageInversion

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