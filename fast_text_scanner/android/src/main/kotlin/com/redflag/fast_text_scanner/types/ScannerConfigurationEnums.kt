package com.redflag.fast_text_scanner.types

import android.util.Size

enum class Framerate {
    fps30, fps60, fps120, fps240;

    fun intValue(): Int = when (this) {
        fps30 -> 30
        fps60 -> 60
        fps120 -> 120
        fps240 -> 240
    }

    fun duration(): Long = 1 / intValue().toLong()
}

enum class Resolution {
    sd480, hd720, hd1080, hd4k;

    private fun width(): Int = when (this) {
        sd480 -> 640
        hd720 -> 1280
        hd1080 -> 1920
        hd4k -> 3840
    }

    private fun height(): Int = when (this) {
        sd480 -> 480
        hd720 -> 720
        hd1080 -> 1080
        hd4k -> 2160
    }

    fun landscape(): Size = Size(width(), height())
    fun portrait(): Size = Size(height(), width())
}

enum class DetectionMode {
    pauseDetection, pauseVideo, continuous;
}

enum class CameraPosition {
    front, back;
}

enum class ScanMode {
    barcode, textRecognition;
}

enum class TextRecognitionType {
    peruMask, regularMask;
}

enum class ImageInversion {
    none, invertAllFrames, alternateFrameInversion;
}