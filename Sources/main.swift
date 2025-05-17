// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

// MARK: - Helper: Convert hex to RGB
func rgbComponents(from hex: String) -> (red: Double, green: Double, blue: Double)? {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    guard hexSanitized.count == 6,
          let intVal = Int(hexSanitized, radix: 16) else { return nil }
    let red = Double((intVal >> 16) & 0xFF) / 255.0
    let green = Double((intVal >> 8) & 0xFF) / 255.0
    let blue = Double(intVal & 0xFF) / 255.0
    return (red, green, blue)
}

// MARK: - Parse Arguments
let arguments = CommandLine.arguments

guard arguments.count >= 2 else {
    print("""
    Usage: ColorAssetGen <input.txt> [output.xcassets]
    - <input.txt>: Text file with lines: ColorName #RRGGBB
    - [output.xcassets]: Optional output folder (default: GeneratedColors.xcassets)
    """)
    exit(1)
}

let inputPath = arguments[1]
let outputPath = arguments.count > 2 ? arguments[2] : "GeneratedColors.xcassets"

// MARK: - Read Input File
guard let input = try? String(contentsOfFile: inputPath) else {
    print("Could not read input file at \(inputPath)")
    exit(1)
}

let lines = input
    .split(separator: "\n")
    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
    .filter { !$0.isEmpty && !$0.hasPrefix("#") }

var colors: [(name: String, hex: String)] = []

for line in lines {
    let parts = line.split(separator: " ")
    guard parts.count == 2 else {
        print("Skipping invalid line: \(line)")
        continue
    }
    colors.append((name: String(parts[0]), hex: String(parts[1])))
}

// Discard colors with duplicate hex codes (keep first occurrence)
var seenHexes = Set<String>()
colors = colors.filter { color in
    if seenHexes.contains(color.hex.lowercased()) {
        return false
    } else {
        seenHexes.insert(color.hex.lowercased())
        return true
    }
}

// MARK: - Generate .xcassets
let fileManager = FileManager.default
do {
    // Remove old output if exists
    try? fileManager.removeItem(atPath: outputPath)
    try fileManager.createDirectory(atPath: outputPath, withIntermediateDirectories: true, attributes: nil)
    
    for color in colors {
        guard let rgb = rgbComponents(from: color.hex) else {
            print("Invalid hex for \(color.name): \(color.hex)")
            continue
        }
        let colorSetPath = "\(outputPath)/\(color.name).colorset"
        try fileManager.createDirectory(atPath: colorSetPath, withIntermediateDirectories: true, attributes: nil)
        
        let contents: [String: Any] = [
            "info": [
                "version": 1,
                "author": "xcode"
            ],
            "colors": [
                [
                    "idiom": "universal",
                    "color": [
                        "color-space": "srgb",
                        "components": [
                            "red": String(format: "%.3f", rgb.red),
                            "green": String(format: "%.3f", rgb.green),
                            "blue": String(format: "%.3f", rgb.blue),
                            "alpha": "1.000"
                        ]
                    ]
                ]
            ]
        ]
        
        let jsonData = try JSONSerialization.data(withJSONObject: contents, options: [.prettyPrinted, .sortedKeys])
        let jsonPath = "\(colorSetPath)/Contents.json"
        try jsonData.write(to: URL(fileURLWithPath: jsonPath))
        print("Generated color asset: \(color.name)")
    }
    print("All color assets generated in \(outputPath)")
} catch {
    print("Error: \(error)")
    exit(1)
}
