# SwiftColorAssetGen

**SwiftColorAssetGen** This tool takes a list of named hex color codes and generates a `.xcassets` catalog of Swift color assets for use in iOS, macOS, or any other Apple platform project

---
                                                                                                                                        
Each color asset is:

- Compatible with Xcode
- Uses sRGB color space
- Available as a named `Color` in SwiftUI or `UIColor`/`NSColor` in UIKit/AppKit
                                                                                                                                        
## 🛠 Output

                                                                                                                                        
                                                                                                                                        
## 🚀 Usage
                                                                                                                                        
### Format

```
deepCharcoal #232526
slateGray #414345
midnightBlue #141E30
electricBlue #00C6FF
```

1. Clone or download this repository.

2. Prepare your color list in a text file (e.g., `colors.txt`) following the format described above.

3. cd to directory and run the generator script:
`swift build`
`swift Sources/main.swift theme_colors_examples.txt output xcasssets`

