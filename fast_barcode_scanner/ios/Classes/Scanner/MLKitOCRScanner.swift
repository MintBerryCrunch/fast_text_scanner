import AVFoundation
import MLKitTextRecognition
import MLKitVision

class MLKitOCRScanner: NSObject, ScannerProtocol, AVCaptureVideoDataOutputSampleBufferDelegate {
    var resultHandler: ResultHandler
    var onDetection: (() -> Void)?

    private let output = AVCaptureVideoDataOutput()
    private let outputQueue = DispatchQueue(label: "fast_barcode_scanner.data.serial", qos: .userInitiated,
                                            attributes: [], autoreleaseFrequency: .workItem)

    private var highlights = [UIView]()

    private var _session: AVCaptureSession?
    private var _symbologies = [String]()

    var symbologies: [String] {
        get { _symbologies }
        set {
            _symbologies = newValue
        }
    }

    var session: AVCaptureSession? {
        get { _session }
        set {
            _session = newValue
            if let session = newValue, session.canAddOutput(output), !session.outputs.contains(output) {
                session.addOutput(output)
            }
        }
    }

    init(resultHandler: @escaping ResultHandler) {
        self.resultHandler = resultHandler
        super.init()

        self.output.alwaysDiscardsLateVideoFrames = true
    }

    func start() {
        output.setSampleBufferDelegate(self, queue: outputQueue)
    }

    func stop() {
        output.setSampleBufferDelegate(nil, queue: nil)
    }

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {

        }
        let options = TextRecognizerOptions()
        let textRecognizer = TextRecognizer.textRecognizer(options: options)

        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = .right

        textRecognizer.process(image) {[weak self] result, error in
            guard error == nil, let result = result else {
                // Error handling
                return
            }
            print(result.text)
            let results = result.text.components(separatedBy: "\n")
            for item in results {
                if let peru = OCRValidationService(ocr: item)?.peruMask() {
                    self?.resultHandler(["textPeru", peru])
                }

                if let regular = OCRValidationService(ocr: item)?.validate() {
                    self?.resultHandler(["textRegular", regular])
                }
            }
        }
    }
}
