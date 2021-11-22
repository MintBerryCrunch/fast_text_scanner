import AVFoundation
import Vision

struct ScannerConfiguration {

    init(position: AVCaptureDevice.Position,
         framerate: Framerate,
         resolution: Resolution,
         mode: DetectionMode,
         barcodeTypes: [String],
         textRecognitionTypes: [String],
         scanMode: ScanMode) {
        self.position = position
        self.framerate = framerate
        self.resolution = resolution
        self.detectionMode = mode
        self.barcodeTypes = barcodeTypes
        self.textRecognitionTypes = textRecognitionTypes
        self.scanMode = scanMode
    }

    init?(_ args: Any?) {
        guard
            let dict = args as? [String: Any],
            let position = cameraPositions[dict["pos"] as? String ?? ""],
            let resolution = Resolution(rawValue: dict["res"] as? String ?? ""),
            let framerate = Framerate(rawValue: dict["fps"] as? String ?? ""),
            let detectionMode = DetectionMode(rawValue: dict["mode"] as? String ?? ""),
            let barcodeTypes = dict["barcodeTypes"] as? [String],
            let textRecognitionTypes = dict["textRecognitionTypes"] as? [String],
            let scanMode = ScanMode(rawValue: dict["scanMode"] as? String ?? "")
            else {
                return nil
        }

        self.init(position: position,
                  framerate: framerate,
                  resolution: resolution,
                  mode: detectionMode,
                  barcodeTypes: barcodeTypes,
                  textRecognitionTypes: textRecognitionTypes,
                  scanMode: scanMode
        )
    }

    let position: AVCaptureDevice.Position
    let framerate: Framerate
    let resolution: Resolution
    let detectionMode: DetectionMode
    let barcodeTypes: [String]
    let textRecognitionTypes: [String]
    let scanMode: ScanMode

    func copy(with args: Any?) -> ScannerConfiguration? {
        guard let dict = args as? [String: Any] else { return nil }

        return ScannerConfiguration.init(
            position: cameraPositions[dict["pos"] as? String ?? ""] ?? position,
            framerate: Framerate(rawValue: dict["fps"] as? String ?? "") ?? framerate,
            resolution: Resolution(rawValue: dict["res"] as? String ?? "") ?? resolution,
            mode: DetectionMode(rawValue: dict["mode"] as? String ?? "") ?? detectionMode,
            barcodeTypes: dict["types"] as? [String] ?? barcodeTypes,
            textRecognitionTypes: dict["textRecognitionTypes"] as? [String] ?? textRecognitionTypes,
            scanMode: ScanMode(rawValue: dict["scanMode"] as? String ?? "") ?? scanMode
        )
    }
}

// Flutter -> AVFoundation
let avMetadataObjectTypes: [String: AVMetadataObject.ObjectType] =
[
    "aztec": .aztec,
    "code128": .code128,
    "code39": .code39,
    "code39mod43": .code39Mod43,
    "code93": .code93,
    "dataMatrix": .dataMatrix,
    "ean13": .ean13,
    "ean8": .ean8,
    "itf": .itf14,
    "pdf417": .pdf417,
    "qr": .qr,
    "upcE": .upce,
    "interleaved": .interleaved2of5
]

// Flutter -> Vision
@available(iOS 11, *)
let vnBarcodeSymbols: [String: VNBarcodeSymbology] =
[
    "aztec": .aztec,
    "code128": .code128,
    "code39": .code39, // Which one?
    "code93": .code93, // Which one?
    "dataMatrix": .dataMatrix,
    "ean13": .ean13,
    "ean8": .ean8,
    "itf": .itf14,
    "pdf417": .pdf417,
    "qr": .qr,
    "upcE": .upce,
    "interleaved": .i2of5 // Which one?
]

// AVFoundation -> Flutter
let flutterMetadataObjectTypes = Dictionary(uniqueKeysWithValues: avMetadataObjectTypes.map { ($1, $0) })

// Vision -> Flutter
@available(iOS 11, *)
let flutterVNSymbols = Dictionary(uniqueKeysWithValues: vnBarcodeSymbols.map { ($1, $0) })

let cameraPositions: [String: AVCaptureDevice.Position] =
[
    "front": .front,
    "back": .back
]

enum Resolution: String {
    case sd480, hd720, hd1080, hd4k

    var width: Int32 {
        switch self {
        case .sd480: return 720
        case .hd720: return 1280
        case .hd1080: return 1920
        case .hd4k: return 3840
        }
    }

    var height: Int32 {
        switch self {
        case .sd480: return 480
        case .hd720: return 720
        case .hd1080: return 1080
        case .hd4k: return 2160
        }
    }
}

enum Framerate: String {
    case fps30, fps60, fps120, fps240

    var doubleValue: Double {
        switch self {
        case .fps30: return 30
        case .fps60: return 60
        case .fps120: return 120
        case .fps240: return 240
        }
    }
}

enum DetectionMode: String {
    case pauseDetection, pauseVideo, continuous
}

enum ScanMode: String {
    case barcode, textRecognition
}
