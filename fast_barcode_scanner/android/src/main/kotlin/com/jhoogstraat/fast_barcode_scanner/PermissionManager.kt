package com.jhoogstraat.fast_barcode_scanner

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.jhoogstraat.fast_barcode_scanner.types.ScannerException

class PermissionManager {
    companion object {
        private const val TAG = "fast_barcode_scanner"
        private const val PERMISSIONS_REQUEST_CODE = 10
        private val REQUIRED_PERMISSIONS = arrayOf(Manifest.permission.CAMERA)
    }

    private var permissionsCompleter: TaskCompletionSource<Unit>? = null


    fun requestPermissions(activity: Activity): Task<Unit> {
        permissionsCompleter = TaskCompletionSource<Unit>()

        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_DENIED
        ) {
            ActivityCompat.requestPermissions(
                activity,
                REQUIRED_PERMISSIONS,
                PERMISSIONS_REQUEST_CODE
            )
        } else {
            permissionsCompleter!!.setResult(null)
        }

        return permissionsCompleter!!.task
    }

    fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        if (requestCode == PERMISSIONS_REQUEST_CODE) {
            permissionsCompleter?.also { completer ->
                if (grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                    completer.setResult(null)
                } else {
                    completer.setException(ScannerException.Unauthorized())
                }
            }
        }

        return true
    }
}