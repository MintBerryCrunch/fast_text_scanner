package com.jhoogstraat.fast_barcode_scanner

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.util.Log
import android.view.Surface
import androidx.camera.core.*
import androidx.camera.core.Camera
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import androidx.lifecycle.LifecycleOwner
import com.google.android.gms.tasks.Task
import com.google.android.gms.tasks.TaskCompletionSource
import com.google.common.util.concurrent.ListenableFuture
import com.google.mlkit.vision.barcode.Barcode
import com.google.mlkit.vision.barcode.BarcodeScannerOptions
import com.jhoogstraat.fast_barcode_scanner.mapper.CallArgumentsMapper
import com.jhoogstraat.fast_barcode_scanner.scanner.MLKitBarcodeScanner
import com.jhoogstraat.fast_barcode_scanner.scanner.MLKitTextScanner
import com.jhoogstraat.fast_barcode_scanner.types.*
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener
import io.flutter.view.TextureRegistry
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class Camera(
    val activity: Activity,
    textureRegistry: TextureRegistry,
    initialConfig: ScannerConfiguration,
    private val barcodesListener: (List<Barcode>) -> Unit,
    private val textListener: (List<RecognizedText>) -> Unit
) : RequestPermissionsResultListener {

    /* Scanner configuration */
    private var scannerConfiguration: ScannerConfiguration

    /* Camera */
    private val cameraExecutor: ExecutorService
    private lateinit var camera: Camera
    private lateinit var cameraProvider: ProcessCameraProvider
    private lateinit var cameraSelector: CameraSelector
    private lateinit var cameraSurfaceProvider: Preview.SurfaceProvider
    private lateinit var preview: Preview
    private lateinit var imageAnalysis: ImageAnalysis

    /* ML Kit */
    private val scanner: ImageAnalysis.Analyzer

    /* State */
    private var isInitialized = false
    private val isRunning: Boolean
        get() = cameraProvider.isBound(preview)
    val torchState: Boolean
        get() = camera.cameraInfo.torchState.value == TorchState.ON

    private val callArgumentsMapper = CallArgumentsMapper()
    private val permissionManager = PermissionManager()

    private val texture = textureRegistry.createSurfaceTexture()

    /* Companion */
    companion object {
        private const val TAG = "fast_barcode_scanner"
    }

    init {
        scannerConfiguration = initialConfig

        scanner = when (initialConfig.scanMode) {
            ScanMode.barcode -> buildBarcodeScanner(scannerConfiguration)
            ScanMode.textRecognition -> buildTextScanner(scannerConfiguration)
        }

        // Create Camera Thread
        cameraExecutor = Executors.newSingleThreadExecutor()
    }

    private fun buildBarcodeScanner(scannerConfiguration: ScannerConfiguration): MLKitBarcodeScanner {
        val options = BarcodeScannerOptions.Builder()
            .setBarcodeFormats(0, *scannerConfiguration.barcodeTypesEncoded)
            .build()

        return MLKitBarcodeScanner(options, scannerConfiguration.inversion, {
            if (it.isNotEmpty()) {
                onScanSuccessful()
                barcodesListener(it)
            }
        }, { Log.e(TAG, "Error in Scanner", it) })
    }

    private fun buildTextScanner(scannerConfiguration: ScannerConfiguration): MLKitTextScanner {
        return MLKitTextScanner(scannerConfiguration.textRecognitionTypes, scannerConfiguration.inversion, {
            if (it.isNotEmpty()) {
                onScanSuccessful()
                textListener(it)
            }
        }, { Log.e(TAG, "Error in Scanner", it) })
    }

    private fun onScanSuccessful() {
        if (scannerConfiguration.detectionMode == DetectionMode.pauseDetection) {
            stopDetector()
        } else if (scannerConfiguration.detectionMode == DetectionMode.pauseVideo) {
            stopCamera()
        }
    }

    fun requestPermissions() = permissionManager.requestPermissions(activity)

    /**
     * Fetching the camera is an async task.
     * Separating it into a dedicated method
     * allows to load the camera at any time.
     */
    fun loadCamera(): Task<PreviewConfiguration> {
        if (ContextCompat.checkSelfPermission(
                activity,
                Manifest.permission.CAMERA
            ) == PackageManager.PERMISSION_DENIED
        ) {
            throw ScannerException.Unauthorized()
        }

        // ProcessCameraProvider.configureInstance(Camera2Config.defaultConfig())
        val cameraProviderFuture = ProcessCameraProvider.getInstance(activity)

        val loadingCompleter = TaskCompletionSource<PreviewConfiguration>()
        cameraProviderFuture.addListener({
            cameraProvider = cameraProviderFuture.get()
            isInitialized = true
            bindCameraUseCases()
            loadingCompleter.setResult(getPreviewConfiguration())
        }, ContextCompat.getMainExecutor(activity))

        return loadingCompleter.task
    }

    private fun buildSelectorAndUseCases() {
        cameraSelector = CameraSelector.Builder()
            .requireLensFacing(
                if (scannerConfiguration.position == CameraPosition.back)
                    CameraSelector.LENS_FACING_BACK
                else
                    CameraSelector.LENS_FACING_FRONT
            )
            .build()

        // TODO: Handle rotation properly
        preview = Preview.Builder()
            .setTargetRotation(Surface.ROTATION_0)
            .setTargetResolution(scannerConfiguration.resolution.portrait())
            .build()

        imageAnalysis = ImageAnalysis.Builder()
            .setTargetRotation(Surface.ROTATION_0)
            .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
            .build()
            .also { it.setAnalyzer(cameraExecutor, scanner) }
    }

    private fun bindCameraUseCases() {
        Log.d(TAG, "Requested Resolution: ${scannerConfiguration.resolution.portrait()}")

        // Selector and UseCases need to be rebuild when rebinding them
        buildSelectorAndUseCases()

        // As required by CameraX, unbinds all use cases before trying to re-bind any of them.
        cameraProvider.unbindAll()

        // Bind camera to Lifecycle
        camera = cameraProvider.bindToLifecycle(
            activity as LifecycleOwner,
            cameraSelector,
            preview,
            imageAnalysis
        )

        // Setup Surface
        cameraSurfaceProvider = Preview.SurfaceProvider {
            val surfaceTexture = texture.surfaceTexture()
            surfaceTexture.setDefaultBufferSize(it.resolution.width, it.resolution.height)
            it.provideSurface(Surface(surfaceTexture), cameraExecutor, {})
        }

        // Attach the viewfinder's surface provider to preview use case
        preview.setSurfaceProvider(cameraExecutor, cameraSurfaceProvider)
    }

    fun startCamera() {
        if (!isInitialized)
            throw ScannerException.NotInitialized()
        else if (isRunning)
            return

        bindCameraUseCases()
    }

    fun stopCamera() {
        if (!isInitialized) {
            throw ScannerException.NotInitialized()
        } else if (!isRunning) {
            return
        }

        cameraProvider.unbindAll()
    }

    fun startDetector() {
        if (!isInitialized)
            throw ScannerException.NotInitialized()
        else if (!isRunning)
            throw ScannerException.NotRunning()
        else if (!cameraProvider.isBound(imageAnalysis))
            throw ScannerException.NotInitialized()

        imageAnalysis.setAnalyzer(cameraExecutor, scanner)
    }

    fun stopDetector() {
        if (!isInitialized)
            throw ScannerException.NotInitialized()
        else if (!isRunning)
            throw ScannerException.NotRunning()
        else if (!cameraProvider.isBound(imageAnalysis))
            throw ScannerException.NotInitialized()

        imageAnalysis.clearAnalyzer()
    }

    fun setTorch(enabled: Boolean): ListenableFuture<Void> {
        if (!isInitialized)
            throw ScannerException.NotInitialized()
        if (!isRunning)
            throw ScannerException.NotRunning()

        return camera.cameraControl.enableTorch(enabled)
    }

    fun toggleTorch(): ListenableFuture<Void> {
        if (!isInitialized)
            throw ScannerException.NotInitialized()
        if (!isRunning)
            throw ScannerException.NotRunning()

        return camera.cameraControl.enableTorch(!torchState)
    }

    fun changeConfiguration(args: HashMap<String, Any>): PreviewConfiguration {
        if (!isInitialized)
            throw ScannerException.NotInitialized()

        scannerConfiguration = callArgumentsMapper.parseChangeConfigArgs(args, scannerConfiguration)

        bindCameraUseCases()
        return getPreviewConfiguration()
    }

    fun dispose() {
        texture.release()
        cameraExecutor.shutdown()
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) = permissionManager.onRequestPermissionsResult(requestCode, permissions, grantResults)

    private fun getPreviewConfiguration(): PreviewConfiguration {
        val previewRes =
            preview.resolutionInfo?.resolution ?: throw ScannerException.NotInitialized()
        val analysisRes =
            imageAnalysis.resolutionInfo?.resolution ?: throw ScannerException.NotInitialized()
        Log.d(TAG, "Preview resolution: ${previewRes.width}x${previewRes.height}")
        Log.d(TAG, "Analysis resolution: $analysisRes")

        return PreviewConfiguration(
            texture.id(),
            0,
            previewRes.height,
            previewRes.width,
            analysis = analysisRes.toString()
        )
    }
}