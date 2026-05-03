import AppKit

let outputDirectory = URL(fileURLWithPath: "Dicho/Assets.xcassets/AppIcon.appiconset", isDirectory: true)
let baseSize = 1024
let requiredSizes = [20, 29, 40, 58, 60, 76, 80, 87, 120, 152, 167, 180, 1024]

try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let baseImage = NSImage(size: NSSize(width: baseSize, height: baseSize))
baseImage.lockFocus()

let background = NSColor(red: 0.0, green: 0.45, blue: 0.50, alpha: 1.0)
let warmAccent = NSColor(red: 0.89, green: 0.36, blue: 0.22, alpha: 1.0)

background.setFill()
NSRect(x: 0, y: 0, width: baseSize, height: baseSize).fill()

warmAccent.setFill()
NSBezierPath(ovalIn: NSRect(x: 682, y: 690, width: 168, height: 168)).fill()

NSColor.white.setFill()
NSBezierPath(roundedRect: NSRect(x: 182, y: 184, width: 660, height: 660), xRadius: 154, yRadius: 154).fill()

background.setFill()
NSBezierPath(roundedRect: NSRect(x: 330, y: 310, width: 354, height: 368), xRadius: 124, yRadius: 124).fill()
NSBezierPath(rect: NSRect(x: 554, y: 468, width: 140, height: 314)).fill()
NSBezierPath(roundedRect: NSRect(x: 554, y: 676, width: 140, height: 150), xRadius: 70, yRadius: 70).fill()

baseImage.unlockFocus()

guard let tiffData = baseImage.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiffData),
      let pngData = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not create base app icon.")
}

let baseURL = outputDirectory.appendingPathComponent("AppIcon-\(baseSize).png")
try pngData.write(to: baseURL)

for size in requiredSizes where size != baseSize {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    NSGraphicsContext.current?.imageInterpolation = .high
    baseImage.draw(in: NSRect(x: 0, y: 0, width: size, height: size))
    image.unlockFocus()

    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not create \(size)px app icon.")
    }

    let url = outputDirectory.appendingPathComponent("AppIcon-\(size).png")
    try pngData.write(to: url)
}
