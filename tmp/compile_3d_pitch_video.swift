import Foundation
import AVFoundation
import SceneKit
import Metal
import CoreGraphics
import AppKit

struct SceneInfo: Decodable {
    let id: Int
    let badge: String
    let title: String
    let subtitle: String
    let pills: [String]
    let vo: String
    let start_time: Double
    let vo_duration: Double
    let duration: Double
}

struct SliceInfo: Decodable {
    let name: String
    let path: String
    let w: Double
    let h: Double
    let nx: Double
    let ny: Double
    let nw: Double
    let nh: Double
}

struct Manifest: Decodable {
    let total_duration: Double
    let master_audio: String
    let scenes: [SceneInfo]
    let slices: [String: SliceInfo]
}

let rootDir = URL(fileURLWithPath: "/Users/marketingdeveloper/DCStack_Development/MySect")
let workDir = rootDir.appendingPathComponent("tmp/pitch_video_3d")
let screensDir = workDir.appendingPathComponent("screens")
let manifestURL = workDir.appendingPathComponent("manifest.json")
let silentURL = workDir.appendingPathComponent("silent_3d.mp4")
let finalURL1 = rootDir.appendingPathComponent("output/video/MYSECT_3D_PITCH_VIDEO.mp4")
let finalURL2 = rootDir.appendingPathComponent("output/video/MYSECT_CLIENT_PITCH_VIDEO.mp4")
let logoURL = rootDir.appendingPathComponent("admin_website/public/mysect_logo.png")

try? FileManager.default.removeItem(at: silentURL)
try? FileManager.default.removeItem(at: finalURL1)

let manifestData = try Data(contentsOf: manifestURL)
let manifest = try JSONDecoder().decode(Manifest.self, from: manifestData)

let width = 1920
let height = 1080
let fps: Int32 = 24
let totalFrames = Int(ceil(manifest.total_duration * Double(fps)))

func clamp(_ x: Double, _ a: Double, _ b: Double) -> Double {
    return max(a, min(b, x))
}
func smoothstep(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
    let t = clamp((x - edge0) / max(0.0001, edge1 - edge0), 0.0, 1.0)
    return t * t * (3.0 - 2.0 * t)
}
func mix(_ a: Double, _ b: Double, _ t: Double) -> Double {
    return a + (b - a) * t
}
func spring(_ x: Double) -> Double {
    let t = clamp(x, 0.0, 1.0)
    if t <= 0.0 { return 0.0 }
    if t >= 1.0 { return 1.0 }
    return 1.0 - exp(-6.5 * t) * cos(11.0 * t)
}
func v3(_ x: Double, _ y: Double, _ z: Double) -> SCNVector3 {
    return SCNVector3(CGFloat(x), CGFloat(y), CGFloat(z))
}

guard let device = MTLCreateSystemDefaultDevice() else {
    fatalError("Metal device unavailable")
}
let renderer = SCNRenderer(device: device, options: nil)
let scene = SCNScene()
renderer.scene = scene

// Studio 3D Lighting
let ambientLight = SCNNode()
ambientLight.light = SCNLight()
ambientLight.light!.type = .ambient
ambientLight.light!.intensity = 650
ambientLight.light!.color = NSColor(calibratedRed: 0.88, green: 0.94, blue: 1.0, alpha: 1.0)
scene.rootNode.addChildNode(ambientLight)

let keyLight = SCNNode()
keyLight.light = SCNLight()
keyLight.light!.type = .directional
keyLight.light!.intensity = 1150
keyLight.light!.color = NSColor.white
keyLight.eulerAngles = v3(-0.4, 0.5, 0.0)
scene.rootNode.addChildNode(keyLight)

let rimLightLeft = SCNNode()
rimLightLeft.light = SCNLight()
rimLightLeft.light!.type = .omni
rimLightLeft.light!.intensity = 1400
rimLightLeft.light!.color = NSColor(calibratedRed: 0.0, green: 0.85, blue: 1.0, alpha: 1.0)
rimLightLeft.position = v3(-5.0, 3.0, 4.0)
scene.rootNode.addChildNode(rimLightLeft)

let rimLightRight = SCNNode()
rimLightRight.light = SCNLight()
rimLightRight.light!.type = .omni
rimLightRight.light!.intensity = 1300
rimLightRight.light!.color = NSColor(calibratedRed: 0.25, green: 0.45, blue: 1.0, alpha: 1.0)
rimLightRight.position = v3(6.0, -2.5, 4.5)
scene.rootNode.addChildNode(rimLightRight)

let cameraNode = SCNNode()
cameraNode.camera = SCNCamera()
cameraNode.camera!.fieldOfView = 40.0
cameraNode.camera!.zNear = 0.1
cameraNode.camera!.zFar = 100.0
cameraNode.position = v3(0, 0, 9.2)
scene.rootNode.addChildNode(cameraNode)
renderer.pointOfView = cameraNode

let phoneW: Double = 2.38
let phoneH: Double = 5.18
let phoneD: Double = 0.18
let baseSliceZ: Double = phoneD / 2.0 + 0.01

func setSlicePop(_ node: SCNNode, pop: Double, zAdd: Double, scaleAdd: Double) {
    let p = clamp(pop, 0.0, 1.0)
    node.opacity = CGFloat(p)
    var pos = node.position
    pos.z = CGFloat(baseSliceZ + zAdd * pop)
    node.position = pos
    let sc = 1.0 + scaleAdd * pop
    node.scale = v3(sc, sc, 1.0)
}

func buildPhoneNode(screenFile: String, sliceNames: [String]) -> (root: SCNNode, slices: [SCNNode]) {
    let holder = SCNNode()

    let bodyGeo = SCNBox(width: CGFloat(phoneW + 0.16), height: CGFloat(phoneH + 0.16), length: CGFloat(phoneD), chamferRadius: 0.26)
    let bodyMat = SCNMaterial()
    bodyMat.lightingModel = .physicallyBased
    bodyMat.diffuse.contents = NSColor(calibratedRed: 0.12, green: 0.16, blue: 0.24, alpha: 1.0)
    bodyMat.metalness.contents = 0.88
    bodyMat.roughness.contents = 0.20
    bodyGeo.materials = [bodyMat]
    let bodyNode = SCNNode(geometry: bodyGeo)
    holder.addChildNode(bodyNode)

    let rimGeo = SCNBox(width: CGFloat(phoneW + 0.19), height: CGFloat(phoneH + 0.19), length: CGFloat(phoneD * 0.45), chamferRadius: 0.27)
    let rimMat = SCNMaterial()
    rimMat.lightingModel = .constant
    rimMat.diffuse.contents = NSColor(calibratedRed: 0.10, green: 0.55, blue: 0.98, alpha: 1.0)
    rimGeo.materials = [rimMat]
    let rimNode = SCNNode(geometry: rimGeo)
    rimNode.position = v3(0, 0, -0.01)
    holder.addChildNode(rimNode)

    let screenGeo = SCNPlane(width: CGFloat(phoneW), height: CGFloat(phoneH))
    screenGeo.cornerRadius = 0.20
    let screenMat = SCNMaterial()
    screenMat.lightingModel = .constant
    let imgURL = screensDir.appendingPathComponent(screenFile)
    screenMat.diffuse.contents = NSImage(contentsOf: imgURL)
    screenMat.isDoubleSided = true
    screenGeo.materials = [screenMat]
    let screenNode = SCNNode(geometry: screenGeo)
    screenNode.position = v3(0, 0, phoneD / 2.0 + 0.005)
    holder.addChildNode(screenNode)

    let islandGeo = SCNBox(width: 0.58, height: 0.13, length: 0.01, chamferRadius: 0.06)
    let islandMat = SCNMaterial()
    islandMat.lightingModel = .constant
    islandMat.diffuse.contents = NSColor(calibratedRed: 0.04, green: 0.05, blue: 0.08, alpha: 1.0)
    islandGeo.materials = [islandMat]
    let islandNode = SCNNode(geometry: islandGeo)
    islandNode.position = v3(0, phoneH / 2.0 - 0.16, phoneD / 2.0 + 0.012)
    holder.addChildNode(islandNode)

    var sliceNodes: [SCNNode] = []
    for sName in sliceNames {
        if let info = manifest.slices[sName] {
            let sw = info.nw * phoneW
            let sh = info.nh * phoneH
            let sGeo = SCNPlane(width: CGFloat(sw), height: CGFloat(sh))
            sGeo.cornerRadius = 0.08
            let sMat = SCNMaterial()
            sMat.lightingModel = .constant
            sMat.diffuse.contents = NSImage(contentsOf: URL(fileURLWithPath: info.path))
            sMat.isDoubleSided = true
            sGeo.materials = [sMat]

            let shadowGeo = SCNPlane(width: CGFloat(sw * 1.03), height: CGFloat(sh * 1.05))
            shadowGeo.cornerRadius = 0.09
            let shadowMat = SCNMaterial()
            shadowMat.lightingModel = .constant
            shadowMat.diffuse.contents = NSColor(calibratedRed: 0.02, green: 0.06, blue: 0.16, alpha: 0.55)
            shadowGeo.materials = [shadowMat]
            let shadowNode = SCNNode(geometry: shadowGeo)
            shadowNode.position = v3(0.03, -0.04, -0.03)

            let sNode = SCNNode(geometry: sGeo)
            sNode.addChildNode(shadowNode)
            let sx = info.nx * phoneW
            let sy = info.ny * phoneH
            sNode.position = v3(sx, sy, baseSliceZ)
            sNode.opacity = 0.0
            holder.addChildNode(sNode)
            sliceNodes.append(sNode)
        }
    }

    return (holder, sliceNodes)
}

let p0 = buildPhoneNode(screenFile: "screen_1_home_dropdown.jpg", sliceNames: ["s1_dropdown", "s1_calendar"])
let p1 = buildPhoneNode(screenFile: "screen_2_ssm_filings.jpg", sliceNames: ["s2_submit_btn", "s2_counters", "s2_card_s68"])
let p2 = buildPhoneNode(screenFile: "screen_3_files.jpg", sliceNames: ["s3_tmcloud", "s3_attention", "s3_unsorted"])
let p3 = buildPhoneNode(screenFile: "screen_4_chats_list.jpg", sliceNames: ["s4_chat_card"])
let p4 = buildPhoneNode(screenFile: "screen_5_chat_detail.jpg", sliceNames: ["s5_bubble_1", "s5_bubble_2", "s5_bubble_3"])

let phones = [p0, p1, p2, p3, p4]
for p in phones {
    scene.rootNode.addChildNode(p.root)
}

var orbs3D: [(node: SCNNode, radius: Double, speed: Double, phase: Double, yBase: Double)] = []
for i in 0..<18 {
    let r = CGFloat(0.06 + Double(i % 4) * 0.035)
    let sph = SCNSphere(radius: r)
    let mat = SCNMaterial()
    mat.lightingModel = .constant
    mat.diffuse.contents = (i % 2 == 0)
        ? NSColor(calibratedRed: 0.15, green: 0.78, blue: 1.0, alpha: 0.65)
        : NSColor(calibratedRed: 0.25, green: 0.45, blue: 1.0, alpha: 0.55)
    sph.materials = [mat]
    let n = SCNNode(geometry: sph)
    scene.rootNode.addChildNode(n)
    orbs3D.append((n, 2.8 + Double(i % 5) * 0.55, 0.45 + Double(i % 3) * 0.2, Double(i) * 0.7, -2.2 + Double(i % 7) * 0.75))
}

let logoNSImage = NSImage(contentsOf: logoURL)

func update3DScene(at t: Double) {
    for orb in orbs3D {
        let ang = t * orb.speed + orb.phase
        let ox = orb.radius * cos(ang) + 1.6
        let oz = orb.radius * sin(ang) - 0.8
        let oy = orb.yBase + 0.35 * sin(t * 1.4 + orb.phase)
        orb.node.position = v3(ox, oy, oz)
    }

    var activeScene = manifest.scenes.last!
    for sc in manifest.scenes {
        if t >= sc.start_time && t < sc.start_time + sc.duration {
            activeScene = sc
            break
        }
    }
    let lt = t - activeScene.start_time
    let enter = spring(lt / 1.1)

    for p in phones {
        p.root.position = v3(0, -15, -10)
        p.root.eulerAngles = SCNVector3Zero
        p.root.scale = v3(1, 1, 1)
        for s in p.slices {
            s.opacity = 0.0
            s.scale = v3(1, 1, 1)
        }
    }

    let rightStageX = 2.05

    switch activeScene.id {
    case 1:
        let ringRadiusX = 2.40
        let ringRadiusZ = 1.65
        for (idx, p) in phones.enumerated() {
            let baseAngle = Double(idx) * (2.0 * .pi / 5.0) + t * 0.68
            let px = 2.38 + ringRadiusX * sin(baseAngle)
            let pz = ringRadiusZ * cos(baseAngle) - 0.85
            let py = 0.16 * sin(t * 1.9 + Double(idx)) - (1.0 - enter) * 4.0
            p.root.position = v3(px, py, pz)
            p.root.eulerAngles = v3(
                -0.06 + 0.05 * cos(baseAngle),
                -0.38 * sin(baseAngle) - 0.14,
                -0.03 * sin(baseAngle)
            )
            let sc = 0.76 + 0.18 * ((cos(baseAngle) + 1.0) * 0.5)
            p.root.scale = v3(sc, sc, sc)
            if let firstSlice = p.slices.first {
                let frontness = clamp((cos(baseAngle) - 0.15) / 0.85, 0.0, 1.0)
                setSlicePop(firstSlice, pop: frontness * enter, zAdd: 0.46, scaleAdd: 0.10)
            }
        }

    case 2:
        let hero = phones[0]
        let spinIn = (1.0 - enter) * (-Double.pi * 1.2)
        let orbitY = -0.38 + 0.16 * sin(lt * 0.8) + spinIn
        let orbitX = -0.10 + 0.06 * cos(lt * 0.7)
        let zoomZ = mix(0.6, 1.55, smoothstep(0.5, 4.5, lt))

        hero.root.position = v3(rightStageX, 0.12 * sin(lt * 1.5), zoomZ)
        hero.root.eulerAngles = v3(orbitX, orbitY, -0.03)

        phones[1].root.position = v3(rightStageX + 2.6, 0.3, -2.2)
        phones[1].root.eulerAngles = v3(0, -0.55, 0.05)
        phones[1].root.scale = v3(0.72, 0.72, 0.72)

        if hero.slices.count >= 2 {
            setSlicePop(hero.slices[0], pop: spring((lt - 0.9) / 0.9), zAdd: 0.68, scaleAdd: 0.14)
            setSlicePop(hero.slices[1], pop: spring((lt - 2.6) / 0.9), zAdd: 0.45, scaleAdd: 0.10)
        }

    case 3:
        let hero = phones[1]
        let flipIn = (1.0 - enter) * Double.pi
        let rotY = -0.34 + 0.22 * sin(lt * 0.65) + flipIn
        let rotX = -0.12 + 0.07 * sin(lt * 0.9)
        let zoomZ = mix(0.5, 1.65, smoothstep(0.4, 4.0, lt))

        hero.root.position = v3(rightStageX, 0.10 * cos(lt * 1.4), zoomZ)
        hero.root.eulerAngles = v3(rotX, rotY, 0.03 * sin(lt))

        phones[0].root.position = v3(rightStageX - 2.3, -0.2, -2.4)
        phones[0].root.eulerAngles = v3(0, 0.48, -0.04)
        phones[0].root.scale = v3(0.70, 0.70, 0.70)

        if hero.slices.count >= 3 {
            setSlicePop(hero.slices[0], pop: spring((lt - 0.8) / 0.8), zAdd: 0.55, scaleAdd: 0.18)
            setSlicePop(hero.slices[1], pop: spring((lt - 1.6) / 0.9), zAdd: 0.52, scaleAdd: 0.10)
            setSlicePop(hero.slices[2], pop: spring((lt - 3.1) / 1.0), zAdd: 0.82, scaleAdd: 0.14)
        }

    case 4:
        let hero = phones[2]
        let rollIn = (1.0 - enter) * (-Double.pi * 0.9)
        let rotY = -0.36 + 0.18 * cos(lt * 0.75) + rollIn
        let rotX = -0.08 + 0.08 * sin(lt * 0.8)
        let zoomZ = mix(0.6, 1.6, smoothstep(0.4, 3.8, lt))

        hero.root.position = v3(rightStageX, 0.12 * sin(lt * 1.3), zoomZ)
        hero.root.eulerAngles = v3(rotX, rotY, -0.04)

        phones[3].root.position = v3(rightStageX + 2.5, -0.15, -2.2)
        phones[3].root.eulerAngles = v3(0, -0.52, 0.04)
        phones[3].root.scale = v3(0.72, 0.72, 0.72)

        if hero.slices.count >= 3 {
            setSlicePop(hero.slices[0], pop: spring((lt - 0.8) / 0.85), zAdd: 0.50, scaleAdd: 0.10)
            setSlicePop(hero.slices[1], pop: spring((lt - 2.1) / 0.85), zAdd: 0.82, scaleAdd: 0.16)
            setSlicePop(hero.slices[2], pop: spring((lt - 2.7) / 0.85), zAdd: 0.62, scaleAdd: 0.12)
        }

    case 5:
        let leftPhone = phones[3]
        let rightPhone = phones[4]

        let slide = enter
        leftPhone.root.position = v3(rightStageX - 1.35 * slide, 0.15 + 0.10 * sin(lt * 1.4), 0.15)
        leftPhone.root.eulerAngles = v3(-0.06, 0.28 - 0.06 * sin(lt * 0.7), 0.03)
        leftPhone.root.scale = v3(0.88, 0.88, 0.88)

        rightPhone.root.position = v3(rightStageX + 1.15 * slide, -0.08 + 0.10 * cos(lt * 1.4), 1.25)
        rightPhone.root.eulerAngles = v3(-0.08, -0.34 + 0.08 * cos(lt * 0.8), -0.03)
        rightPhone.root.scale = v3(0.96, 0.96, 0.96)

        if let sChat = leftPhone.slices.first {
            setSlicePop(sChat, pop: spring((lt - 0.8) / 0.8), zAdd: 0.48, scaleAdd: 0.08)
        }
        for (bIdx, bNode) in rightPhone.slices.enumerated() {
            let delay = 1.4 + Double(bIdx) * 1.15
            let zDepth = 0.42 + Double(bIdx) * 0.22
            setSlicePop(bNode, pop: spring((lt - delay) / 0.8), zAdd: zDepth, scaleAdd: 0.11)
        }

    default:
        let offsets = [-2.15, -1.08, 0.0, 1.08, 2.15]
        for (idx, p) in phones.enumerated() {
            let ox = offsets[idx] * enter
            let dist = abs(Double(idx - 2))
            let px = 2.52 + ox * 0.86
            let pz = (1.10 - dist * 0.65) * enter
            let py = (0.12 * sin(t * 1.8 + Double(idx))) - dist * 0.10
            p.root.position = v3(px, py, pz)
            let ry = -ox * 0.18 + 0.08 * sin(t * 0.9) - 0.10
            p.root.eulerAngles = v3(-0.06, ry, -ox * 0.02)
            let sc = 0.82 - dist * 0.05
            p.root.scale = v3(sc, sc, sc)

            if let firstSlice = p.slices.first {
                setSlicePop(firstSlice, pop: spring((lt - 1.0 - Double(idx) * 0.25) / 0.9), zAdd: 0.42, scaleAdd: 0.08)
            }
        }
    }
}

func fillRoundedRect(_ ctx: CGContext, _ rect: CGRect, radius: CGFloat, color: CGColor, stroke: CGColor? = nil, lineWidth: CGFloat = 1.5) {
    let path = CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)
    ctx.saveGState()
    ctx.addPath(path)
    ctx.setFillColor(color)
    ctx.fillPath()
    if let sc = stroke {
        ctx.addPath(path)
        ctx.setStrokeColor(sc)
        ctx.setLineWidth(lineWidth)
        ctx.strokePath()
    }
    ctx.restoreGState()
}

func drawText(_ text: String, rect: CGRect, font: NSFont, color: NSColor, align: NSTextAlignment = .left) {
    let style = NSMutableParagraphStyle()
    style.alignment = align
    style.lineHeightMultiple = 1.08
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: style
    ]
    (text as NSString).draw(in: rect, withAttributes: attrs)
}

let writer = try AVAssetWriter(outputURL: silentURL, fileType: .mp4)
let videoSettings: [String: Any] = [
    AVVideoCodecKey: AVVideoCodecType.h264,
    AVVideoWidthKey: width,
    AVVideoHeightKey: height,
    AVVideoCompressionPropertiesKey: [
        AVVideoAverageBitRateKey: 10_500_000,
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

guard let pool = adaptor.pixelBufferPool else {
    fatalError("No pixel buffer pool")
}

let colorSpace = CGColorSpaceCreateDeviceRGB()

print("Rendering \(totalFrames) 3D frames at \(fps) FPS...")

for f in 0..<totalFrames {
    let t = Double(f) / Double(fps)
    update3DScene(at: t)

    let scnImage = renderer.snapshot(atTime: t, with: CGSize(width: CGFloat(width), height: CGFloat(height)), antialiasingMode: .multisampling4X)

    var pbOut: CVPixelBuffer?
    CVPixelBufferPoolCreatePixelBuffer(kCFAllocatorDefault, pool, &pbOut)
    guard let pb = pbOut else { fatalError("Failed pixel buffer") }

    CVPixelBufferLockBaseAddress(pb, [])
    guard let ctx = CGContext(
        data: CVPixelBufferGetBaseAddress(pb),
        width: width,
        height: height,
        bitsPerComponent: 8,
        bytesPerRow: CVPixelBufferGetBytesPerRow(pb),
        space: colorSpace,
        bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue
    ) else { fatalError("Failed CGContext") }

    let bgColors = [
        NSColor(calibratedRed: 0.03, green: 0.07, blue: 0.16, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.05, green: 0.14, blue: 0.32, alpha: 1.0).cgColor,
        NSColor(calibratedRed: 0.02, green: 0.05, blue: 0.12, alpha: 1.0).cgColor
    ] as CFArray
    if let grad = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 0.55, 1.0]) {
        ctx.drawLinearGradient(grad, start: CGPoint(x: 0.0, y: CGFloat(height)), end: CGPoint(x: CGFloat(width), y: 0.0), options: [])
    }

    let spotX = CGFloat(1320.0 + 90.0 * sin(t * 0.9))
    let spotY = CGFloat(540.0 + 70.0 * cos(t * 0.7))
    let spotColors = [
        NSColor(calibratedRed: 0.08, green: 0.52, blue: 0.98, alpha: 0.42).cgColor,
        NSColor(calibratedRed: 0.04, green: 0.75, blue: 0.85, alpha: 0.16).cgColor,
        NSColor(calibratedRed: 0.03, green: 0.07, blue: 0.16, alpha: 0.0).cgColor
    ] as CFArray
    if let radGrad = CGGradient(colorsSpace: colorSpace, colors: spotColors, locations: [0.0, 0.45, 1.0]) {
        ctx.drawRadialGradient(radGrad, startCenter: CGPoint(x: spotX, y: spotY), startRadius: 10, endCenter: CGPoint(x: spotX, y: spotY), endRadius: 620, options: [])
    }

    ctx.saveGState()
    ctx.setStrokeColor(NSColor(calibratedRed: 0.20, green: 0.55, blue: 0.95, alpha: 0.10).cgColor)
    ctx.setLineWidth(1.0)
    for gx in stride(from: -400, through: 2320, by: 120) {
        ctx.move(to: CGPoint(x: CGFloat(gx), y: 0.0))
        ctx.addLine(to: CGPoint(x: 960.0 + CGFloat(gx - 960) * 0.35, y: 310.0))
        ctx.strokePath()
    }
    for gy in [40, 95, 155, 220, 285] {
        ctx.move(to: CGPoint(x: 0.0, y: CGFloat(gy)))
        ctx.addLine(to: CGPoint(x: CGFloat(width), y: CGFloat(gy)))
        ctx.strokePath()
    }
    ctx.restoreGState()

    if let scnCG = scnImage.cgImage(forProposedRect: nil, context: nil, hints: nil) {
        ctx.draw(scnCG, in: CGRect(x: 0, y: 0, width: width, height: height))
    }

    var activeScene = manifest.scenes.last!
    for sc in manifest.scenes {
        if t >= sc.start_time && t < sc.start_time + sc.duration {
            activeScene = sc
            break
        }
    }
    let lt = t - activeScene.start_time
    let textEnter = spring(lt / 0.85)
    let slideX = CGFloat((1.0 - textEnter) * -90.0)

    let nsCtx = NSGraphicsContext(cgContext: ctx, flipped: false)
    NSGraphicsContext.current = nsCtx

    fillRoundedRect(
        ctx,
        CGRect(x: 76, y: 948, width: 220, height: 64),
        radius: 32,
        color: NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.96).cgColor,
        stroke: NSColor(calibratedRed: 0.22, green: 0.65, blue: 1.0, alpha: 0.7).cgColor,
        lineWidth: 2.0
    )
    if let logo = logoNSImage {
        logo.draw(in: CGRect(x: 112, y: 906, width: 148, height: 148))
    }

    fillRoundedRect(
        ctx,
        CGRect(x: 1620, y: 958, width: 224, height: 44),
        radius: 22,
        color: NSColor(calibratedRed: 0.06, green: 0.16, blue: 0.34, alpha: 0.85).cgColor,
        stroke: NSColor(calibratedRed: 0.15, green: 0.75, blue: 0.98, alpha: 0.6).cgColor,
        lineWidth: 1.5
    )
    drawText(
        "3D SHOWCASE  •  0\(activeScene.id) / 06",
        rect: CGRect(x: 1620, y: 966, width: 224, height: 26),
        font: NSFont.systemFont(ofSize: 14, weight: .bold),
        color: NSColor(calibratedRed: 0.35, green: 0.88, blue: 1.0, alpha: 1.0),
        align: .center
    )

    let badgeRect = CGRect(x: 76 + slideX, y: 815, width: 390, height: 38)
    fillRoundedRect(
        ctx,
        badgeRect,
        radius: 19,
        color: NSColor(calibratedRed: 0.04, green: 0.45, blue: 0.85, alpha: 0.32).cgColor,
        stroke: NSColor(calibratedRed: 0.22, green: 0.78, blue: 1.0, alpha: 0.85).cgColor,
        lineWidth: 1.5
    )
    drawText(
        "✦  " + activeScene.badge,
        rect: CGRect(x: 94 + slideX, y: 821, width: 360, height: 26),
        font: NSFont.systemFont(ofSize: 14, weight: .heavy),
        color: NSColor(calibratedRed: 0.40, green: 0.90, blue: 1.0, alpha: 1.0)
    )

    let titleFontSize: CGFloat = (activeScene.id == 6) ? 40 : 50
    drawText(
        activeScene.title,
        rect: CGRect(x: 76 + slideX, y: 610, width: 675, height: 190),
        font: NSFont.systemFont(ofSize: titleFontSize, weight: .black),
        color: NSColor.white
    )

    drawText(
        activeScene.subtitle,
        rect: CGRect(x: 76 + slideX, y: 520, width: 660, height: 85),
        font: NSFont.systemFont(ofSize: 21, weight: .medium),
        color: NSColor(calibratedRed: 0.76, green: 0.86, blue: 0.98, alpha: 1.0)
    )

    for (pIdx, pillText) in activeScene.pills.enumerated() {
        let pEnter = spring((lt - 0.35 - Double(pIdx) * 0.22) / 0.75)
        if pEnter > 0.01 {
            let py = CGFloat(440 - pIdx * 76)
            let px = CGFloat(76.0 + (1.0 - pEnter) * -70.0)
            let cardRect = CGRect(x: px, y: py, width: 520, height: 60)
            let isHighlighted = (Int(lt * 0.8) % 3 == pIdx)
            let bgCol = isHighlighted
                ? NSColor(calibratedRed: 0.08, green: 0.34, blue: 0.78, alpha: 0.78).cgColor
                : NSColor(calibratedRed: 0.07, green: 0.15, blue: 0.30, alpha: 0.72).cgColor
            let stCol = isHighlighted
                ? NSColor(calibratedRed: 0.25, green: 0.88, blue: 1.0, alpha: 0.95).cgColor
                : NSColor(calibratedRed: 0.25, green: 0.45, blue: 0.75, alpha: 0.45).cgColor
            fillRoundedRect(ctx, cardRect, radius: 16, color: bgCol, stroke: stCol, lineWidth: isHighlighted ? 2.2 : 1.2)

            let circRect = CGRect(x: px + 16, y: py + 13, width: 34, height: 34)
            fillRoundedRect(ctx, circRect, radius: 17, color: NSColor(calibratedRed: 0.15, green: 0.78, blue: 1.0, alpha: 1.0).cgColor)
            drawText(
                "\(pIdx + 1)",
                rect: CGRect(x: px + 16, y: py + 18, width: 34, height: 24),
                font: NSFont.systemFont(ofSize: 16, weight: .black),
                color: NSColor(calibratedRed: 0.03, green: 0.09, blue: 0.22, alpha: 1.0),
                align: .center
            )

            drawText(
                pillText,
                rect: CGRect(x: px + 64, y: py + 16, width: 435, height: 30),
                font: NSFont.systemFont(ofSize: 20, weight: .bold),
                color: NSColor.white
            )
        }
    }

    let bottomBarRect = CGRect(x: 76, y: 38, width: 1768, height: 96)
    fillRoundedRect(
        ctx,
        bottomBarRect,
        radius: 22,
        color: NSColor(calibratedRed: 0.03, green: 0.08, blue: 0.18, alpha: 0.86).cgColor,
        stroke: NSColor(calibratedRed: 0.20, green: 0.55, blue: 0.90, alpha: 0.45).cgColor,
        lineWidth: 1.4
    )

    for b in 0..<20 {
        let wave = abs(sin(t * 7.5 + Double(b) * 0.55) * cos(t * 4.2 - Double(b) * 0.3))
        let bh = CGFloat(10.0 + 36.0 * wave)
        let bx = CGFloat(104 + b * 8)
        let by = CGFloat(86) - bh / 2.0
        let barCol = (b % 2 == 0)
            ? NSColor(calibratedRed: 0.15, green: 0.85, blue: 1.0, alpha: 0.95).cgColor
            : NSColor(calibratedRed: 0.25, green: 0.55, blue: 1.0, alpha: 0.95).cgColor
        fillRoundedRect(ctx, CGRect(x: bx, y: by, width: 5, height: bh), radius: 2.5, color: barCol)
    }

    drawText(
        "“" + activeScene.vo + "”",
        rect: CGRect(x: 285, y: 58, width: 1525, height: 60),
        font: NSFont.systemFont(ofSize: 19, weight: .semibold),
        color: NSColor(calibratedRed: 0.94, green: 0.97, blue: 1.0, alpha: 1.0),
        align: .left
    )

    let progRatio = CGFloat(clamp(t / manifest.total_duration, 0.0, 1.0))
    fillRoundedRect(
        ctx,
        CGRect(x: 104, y: 46, width: 1712, height: 5),
        radius: 2.5,
        color: NSColor(calibratedRed: 1, green: 1, blue: 1, alpha: 0.14).cgColor
    )
    fillRoundedRect(
        ctx,
        CGRect(x: 104, y: 46, width: max(12, 1712 * progRatio), height: 5),
        radius: 2.5,
        color: NSColor(calibratedRed: 0.15, green: 0.88, blue: 1.0, alpha: 1.0).cgColor
    )

    if abs(lt - 4.2) < (0.5 / Double(fps)) {
        if let cgSnap = ctx.makeImage() {
            let rep = NSBitmapImageRep(cgImage: cgSnap)
            if let pngData = rep.representation(using: .png, properties: [:]) {
                let prevURL = workDir.appendingPathComponent("preview_scene_\(activeScene.id).png")
                try? pngData.write(to: prevURL)
            }
        }
    }

    CVPixelBufferUnlockBaseAddress(pb, [])

    while !writerInput.isReadyForMoreMediaData {
        Thread.sleep(forTimeInterval: 0.002)
    }
    let pts = CMTime(value: Int64(f), timescale: fps)
    adaptor.append(pb, withPresentationTime: pts)

    if f % 120 == 0 || f == totalFrames - 1 {
        print(String(format: "Rendered frame %d / %d (%.1f%%)", f + 1, totalFrames, Double(f + 1) * 100.0 / Double(totalFrames)))
    }
}

writerInput.markAsFinished()
let writeSema = DispatchSemaphore(value: 0)
writer.finishWriting {
    writeSema.signal()
}
writeSema.wait()
print("3D video stream written to: \(silentURL.path)")

let composition = AVMutableComposition()
let vAsset = AVURLAsset(url: silentURL)
let aAsset = AVURLAsset(url: URL(fileURLWithPath: manifest.master_audio))

guard let compV = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
      let srcV = vAsset.tracks(withMediaType: .video).first,
      let compA = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid),
      let srcA = aAsset.tracks(withMediaType: .audio).first else {
    fatalError("Failed to setup composition tracks")
}

let dur = vAsset.duration
try compV.insertTimeRange(CMTimeRange(start: .zero, duration: dur), of: srcV, at: .zero)
try compA.insertTimeRange(CMTimeRange(start: .zero, duration: min(dur, aAsset.duration)), of: srcA, at: .zero)

guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality) else {
    fatalError("Failed export session")
}
exporter.outputURL = finalURL1
exporter.outputFileType = .mp4
exporter.shouldOptimizeForNetworkUse = true

let expSema = DispatchSemaphore(value: 0)
exporter.exportAsynchronously {
    expSema.signal()
}
expSema.wait()

if exporter.status == .completed {
    try? FileManager.default.removeItem(at: finalURL2)
    try FileManager.default.copyItem(at: finalURL1, to: finalURL2)
    print("SUCCESS! Exported 3D pitch video to:\n  - \(finalURL1.path)\n  - \(finalURL2.path)")
} else {
    fatalError("Export failed: \(String(describing: exporter.error))")
}
