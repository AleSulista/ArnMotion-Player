import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count == 5, let image = NSImage(contentsOfFile: args[1]) else {
    fatalError("Imagem ou argumentos inválidos")
}
let labels = try JSONSerialization.jsonObject(with: Data(contentsOf: URL(fileURLWithPath: args[2]))) as! [String]
let output = URL(fileURLWithPath: args[3])
let appMode = args[4] == "app"
try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)
for label in labels {
    for size in [16, 32, 64, 128, 256, 512, 1024] {
        guard let bitmap = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: size, pixelsHigh: size,
            bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
            colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
            let context = NSGraphicsContext(bitmapImageRep: bitmap) else { fatalError("Contexto inválido") }
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = context
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: NSRect(x: 0, y: 0, width: size, height: size), from: .zero, operation: .copy, fraction: 1)
        if !appMode {
            let scale = CGFloat(size) / 1280.0
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs: [NSAttributedString.Key: Any] = [
                .font: NSFont.boldSystemFont(ofSize: 64 * scale),
                .foregroundColor: NSColor(calibratedRed: 0.88, green: 0.69, blue: 0.24, alpha: 1),
                .paragraphStyle: paragraph
            ]
            (label as NSString).draw(in: NSRect(x: 375 * scale, y: 160 * scale, width: 525 * scale, height: 88 * scale), withAttributes: attrs)
        }
        NSGraphicsContext.restoreGraphicsState()
        guard let png = bitmap.representation(using: .png, properties: [:]) else { fatalError("PNG inválido") }
        try png.write(to: output.appendingPathComponent("\(label)-\(size).png"))
    }
}
