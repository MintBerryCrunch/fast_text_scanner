package com.redflag.fast_text_scanner.scanner

import android.util.Log
import com.redflag.fast_text_scanner.types.TextRecognitionType

class TextRecognitionMask(
    private val textRecognitionTypes: List<TextRecognitionType>
) {
    companion object {
        private const val TAG = "fast_text_scanner"
    }

    private val invalidCharactersRegexp = Regex("[^A-Za-z0-9]+")
    private val zeroShapedUppercaseLetters = Regex("[QODCGU]")
    private val oneShapedUppercaseLetters = Regex("[JILKV]")
    private val twoShapedUppercaseLetters = Regex("[ZRW]")
    private val threeShapedUppercaseLetters = Regex("[E]")
    private val fourShapedUppercaseLetters = Regex("[AHMN]")
    private val fiveShapedUppercaseLetters = Regex("[S]")
    private val sixShapedUppercaseLetters = Regex("[]")
    private val sevenShapedUppercaseLetters = Regex("[TZ]")
    private val eightShapedUppercaseLetters = Regex("[BFPX]")
    private val nineShapedUppercaseLetters = Regex("[Y]")

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
            .replace(twoShapedUppercaseLetters, "2")
            .replace(threeShapedUppercaseLetters, "3")
            .replace(fourShapedUppercaseLetters, "4")
            .replace(fiveShapedUppercaseLetters, "5")
            .replace(sixShapedUppercaseLetters, "6")
            .replace(sevenShapedUppercaseLetters, "7")
            .replace(eightShapedUppercaseLetters, "8")
            .replace(nineShapedUppercaseLetters, "9")

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
