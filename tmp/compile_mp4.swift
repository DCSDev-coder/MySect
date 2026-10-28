import Foundation
import AVFoundation
import CoreGraphics
import CoreImage
import AppKit

struct SceneMeta: Decodable {
    let id: Int
    let audio_path: String
    let audio_duration: Double
    let scene_duration: Double
}

let rootDir = URL(fileURLWithPath: "/Users/marketingdeveloper/DCStack_Development/MySect")
let workDir = rootDir.appendingPathComponent("tmp/pitch_video_build")
let framesDir = workDir.appendingPathComponent("frames")
let metaURL = workDir.appendingPathComponent("scenes_meta.json")
let silentVideoURL = workDir.appendingPathComponent("silent_video.mp4")
let finalVideoURL = rootDir.appendingPathComponent("output/video/MYSECT_CLIENT_PITCH_VIDEO.mp4")

try? FileManager.default.removeItem(at: silentVideoURL)
try? FileManager.default.removeItem(at: finalVideoURL)

let metaData = try Data(contentsOf: metaURL)
let scenes = try JSONDecoder().decode([SceneMeta].self, from: metaData)

let width = 1920
let height = 1080
let fps: Int32 = 15

func loadCGImage(_ url: URL) -> CGImage {
    guard let nsImage = NSImage(contentsOf: url),
          let cgImg = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        fatalError("Failed to load image: \(url.path)")
    }
    return cgImg
}

func makePixelBuffer(from cgImage: CGImage, nextImage: CGImage?, alpha: CGFloat, pool: CVPixelBufferPool) -> CVPixelBuffer {
    var pbOut: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pbOut)
    guard let pb = pbOut else { fatalError("Failed to create pixel buffer") }
    CVPixelBufferLockBaseAddress(pb, [])
    let ctx = CGContext(
        data: CVPixelBufferGetBaseAddress(pb),
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(pb),
        space: CGColorSpaceCreateDeviceRGB(),
        bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    )!
    ctx.interpolationQuality = .high
    let rect = CGRect(x: 0, y: 0, width: width, height: height)
    ctx.draw(cgImage, in: rect)
    if let next = nextImage, alpha > 0.0 {
        ctx.saveGState()
        ctx.setAlpha(alpha)
        ctx.draw(next, in: rect)
        ctx.restoreGState()
    }
    CVPixelBufferUnlockBaseAddress(pb, [])
    return pb
}

// 1. Write H.264 video track from the 18 high-res UI frames with smooth crossfades
let writer = try AVAssetWriter(outputURL: silentVideoURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 6_000_000,
        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
    ]
]
let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
writerInput.expectsMediaDataInRealTime = false

let adaptorAttrs: [String: Any] = [
    kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
    kCVPixelBufferWidthKey as String: width,
    kCVPixelBufferHeightKey as String: height
]
let adaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: adaptorAttrs)
writer.add(writerInput)
writer.startWriting()
writer.startSession(atSourceTime: .zero)

var frameIndex: Int64 = 0
let fadeFrames = 6 // 0.4s smooth crossfade

var allSteps: [(img: CGImage, framesCount: Int)] = []
for sc in scenes {
    let totalSceneFrames = Int(round(sc.scene_duration * Double(fps)))
    let stepFrames = totalSceneFrames / 3
    let rem = totalSceneFrames - (stepFrames * 3)
    for step in 0..<3 {
        let imgURL = framesDir.appendingPathComponent("scene_\(sc.id)_step_\(step).png")
        let cg = loadCGImage(imgURL)
        let count = stepFrames + (step == 2 ? rem : 0)
        allSteps.append((cg, count))
    }
}

guard let pool = adaptor.pixelBufferPool else {
    fatalError("Pixel buffer pool unavailable")
}

for idx in 0..<allSteps.count {
    let current = allSteps[idx]
    let nextImg: CGImage? = (idx + 1 < allSteps.count) ? allSteps[idx + 1].img : nil
    for f in 0..<current.framesCount {
        while !writerInput.isReadyForMoreMediaData {
            Thread.sleep(forTimeInterval: 0.005)
        }
        var alpha: CGFloat = 0.0
        if nextImg != nil && f >= (current.framesCount - fadeFrames) {
            let fadeIdx = f - (current.framesCount - fadeFrames) + 1
            alpha = CGFloat(fadeIdx) / CGFloat(fadeFrames)
        }
        let pb = makePixelBuffer(from: current.img, nextImage: nextImg, alpha: alpha, pool: pool)
        let pts = CMTime(value: frameIndex, timescale: fps)
        adaptor.append(pb, withPresentationTime: pts)
        frameIndex += 1
    }
    print("Encoded step \(idx + 1)/\(allSteps.count)")
}

writerInput.markAsFinished()
let writeSema = DispatchSemaphore(value: 0)
writer.finishWriting {
    writeSema.signal()
}
writeSema.wait()
print("Silent H.264 video written: \(silentVideoURL.path)")

// 2. Mux with the 6 Voiceover Audio tracks using AVMutableComposition
let composition = AVMutableComposition()
let videoAsset = AVURLAsset(url: silentVideoURL)
guard let compVideoTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let srcVideoTrack = videoAsset.tracks(withMediaType: .video).first else {
    fatalError("Failed to load video track")
}
try compVideoTrack.insertTimeRange(CMTimeRange(start: .zero, duration: videoAsset.duration), of: srcVideoTrack, at: .zero)

guard let compAudioTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) else {
    fatalError("Failed to create audio track")
}

var currentStart: Double = 0.0
for sc in scenes {
    let audioURL = URL(fileURLWithPath: sc.audio_path)
    let audioAsset = AVURLAsset(url: audioURL)
    if let srcAudio = audioAsset.tracks(withMediaType: .audio).first {
        let insertTime = CMTime(seconds: currentStart + 0.25, preferredTimescale: 600)
        let dur = min(audioAsset.duration.seconds, sc.scene_duration - 0.3)
        let range = CMTimeRange(start: .zero, duration: CMTime(seconds: dur, preferredTimescale: 600))
        try compAudioTrack.insertTimeRange(range, of: srcAudio, at: insertTime)
    }
    currentStart += sc.scene_duration
}

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
    fatalError("Failed to create export session")
}
exporter.outputURL = finalVideoURL
exporter.outputFileType = .mp4
exporter.shouldOptimizeForNetworkUse = true

let exportSema = DispatchSemaphore(value: 0)
exporter.exportAsynchronously {
    exportSema.signal()
}
exportSema.wait()

if exporter.status == .completed {
    print("SUCCESS! Exported final pitch video to: \(finalVideoURL.path)")
} else {
    fatalError("Export failed: \(String(describing: exporter.error))")
}
