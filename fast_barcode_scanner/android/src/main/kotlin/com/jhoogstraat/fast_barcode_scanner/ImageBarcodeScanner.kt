package com.jhoogstraat.fast_barcode_scanner

import android.app.Activity
import android.content.Intent
import android.graphics.BitmapFactory
import android.net.Uri
import android.provider.MediaStore
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.android.gms.tasks.Tasks
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.google.mlkit.vision.barcode.BarcodeScanning
import com.google.mlkit.vision.common.InputImage
import com.jhoogstraat.fast_barcode_scanner.types.ScannerException
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import java.io.IOException

// Encapsulates `scanImage` related code
class ImageBarcodeScanner {

    private var pickImageCompleter: TaskCompletionSource<Uri?>? = null

    fun scanImage(providedActivityBinding: ActivityPluginBinding?, source: Any?): Task<List<Barcode>?> {
        val options =
            BarcodeScannerOptions.Builder().setBarcodeFormats(Barcode.FORMAT_ALL_FORMATS).build()
        val scanner = BarcodeScanning.getClient(options)

        return when (source) {
            // Binary
            is List<*> -> scanner.process(
                InputImage.fromBitmap(
                    BitmapFactory.decodeByteArray(
                        source[0] as ByteArray,
                        0,
                        (source[0] as ByteArray).size
                    ),
                    source[1] as Int
                )
            )
            // Picker
            else -> {
                if (pickImageCompleter?.task?.isComplete == false)
                    throw ScannerException.AlreadyPicking()

                val activityBinding =
                    providedActivityBinding ?: throw ScannerException.ActivityNotConnected()

                val intent = Intent(
                    Intent.ACTION_PICK,
                    MediaStore.Images.Media.INTERNAL_CONTENT_URI
                )
                intent.type = "image/*"

                this.pickImageCompleter = TaskCompletionSource<Uri?>()

                activityBinding.activity.startActivityForResult(intent, 1)

                return pickImageCompleter!!.task.continueWithTask {
                    if (it.result == null) Tasks.forResult(null) else
                        scanner.process(InputImage.fromFilePath(activityBinding.activity, it.result))
                }
            }
        }
    }

    // Activity Result Listener for picking images from Intent
    // Should be called from the plugin class
    fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != 1) {
            return false
        }

        val completer = pickImageCompleter ?: return false

        when (resultCode) {
            Activity.RESULT_OK -> {
                try {
                    completer.setResult(data?.data)
                } catch (e: IOException) {
                    completer.setException(ScannerException.LoadingFailed(e))
                }
            }
            else -> {
                completer.setResult(null)
            }
        }

        pickImageCompleter = null

        return true
    }
}