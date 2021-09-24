package com.jhoogstraat.fast_barcode_scanner

import android.graphics.ImageFormat
import android.media.Image
import java.nio.ByteBuffer
import kotlin.experimental.inv

/**
 * The given image is inverted in-place, the process uses O(n) additional memory, though.
 * Only YUV_420_888 format is supported (images in other formats are never inverted).
 *
 * Every instance of this class manages its state (in the alternating mode) separately. It is not thread-safe.
 */
class ImageInvertor(
        private val inversionMode: ImageInversion
) {

    // Android camera preview format
    private val imageFormatSupportedForInversion = ImageFormat.YUV_420_888

    // Alternating flag - only for alternateFrameInversion mode.
    private var invertImage = false

    /**
     * Inverts image according to the selected mode.
     */
    fun invertImageIfNeeded(image: Image) {
        when (inversionMode) {
            ImageInversion.none -> return
            ImageInversion.invertAllFrames -> invertImage(image)
            ImageInversion.alternateFrameInversion -> invertImageAlternating(image)
        }
    }

    private fun invertImageAlternating(image: Image) {
        invertImage = !invertImage
        if (!invertImage) {
            return
        }
        invertImage(image)
    }

    private fun invertImage(image: Image) {
        if (image.format != imageFormatSupportedForInversion) {
            return
        }
        image.planes
                .filter { it.buffer != null }
                .forEach { invertPlaneBuffer(it.buffer) }
    }

    private fun invertPlaneBuffer(buffer: ByteBuffer) {
        if (buffer.limit() == 0) {
            return
        }
        val cachedState = ByteArray(buffer.limit())
        buffer.rewind()
        buffer.get(cachedState)
        cachedState.forEachIndexed { index, byte ->
            cachedState[index] = byte.inv()
        }
        buffer.rewind()
        buffer.put(cachedState)
    }
}
