package com.jhoogstraat.fast_barcode_scanner.scanner

import android.util.Log
import com.jhoogstraat.fast_barcode_scanner.types.TextRecognitionType

class TextRecognitionMask(
    private val textRecognitionTypes: List<TextRecognitionType>
) {
    companion object {
        private const val TAG = "fast_barcode_scanner"
    }

    private val invalidCharactersRegexp = Regex("[^A-Za-z0-9]+")
    private val zeroShapedUppercaseLetters = Regex("[QODECG]")
    private val oneShapedUppercaseLetters = Regex("[JIL]")
    private val fourShapedUppercaseLetters = Regex("[A]")
    private val sixShapedUppercaseLetters = Regex("[B]")

    private val validNumberLength = 11
    private val validPrefix = "010IM"
    private val prefixLength = validPrefix.length
    private val minPrefixMatches = 3
    private val minSequentialPartMatches = 3

    fun applyMask(source: String): List<String> {
        if (!textRecognitionTypes.contains(TextRecognitionType.peruMask)) {
            // Other masks are not supported yet
            return emptyList()
        }
        return applyPeruMask(source)
    }

    //Peru: 010IM 123456
    private fun applyPeruMask(source: String): List<String> {
        val preprocessed = source.replace(invalidCharactersRegexp, "").uppercase()
        if (preprocessed.length != validNumberLength) {
            return emptyList()
        }
        val prefix = preprocessed.substring(0, prefixLength)
        val sequentialPart = preprocessed.substring(prefixLength)
        val prefixMatchesCount = countPrefixMatches(prefix)
        val digitsMatchesCount = countDigits(sequentialPart)

        if (prefixMatchesCount < minPrefixMatches) {
            return emptyList()
        }
        if (digitsMatchesCount < minSequentialPartMatches) {
            return emptyList()
        }

        val correctedSequentialPart = sequentialPart
            .replace(zeroShapedUppercaseLetters, "0")
            .replace(oneShapedUppercaseLetters, "1")
            .replace(fourShapedUppercaseLetters, "4")
            .replace(sixShapedUppercaseLetters, "6")

        return listOf("$validPrefix$correctedSequentialPart")
    }

    private fun countPrefixMatches(prefix: String): Int {
        if (prefix.length != validPrefix.length) {
            Log.e(TAG, "Peru mask is misconfigured: prefix length does not match")
            return 0
        }
        return (prefix.indices).count { prefix[it] == validPrefix[it] }
    }

    private fun countDigits(sequentialPart: String): Int {
        return sequentialPart.count { it.isDigit() }
    }
}
