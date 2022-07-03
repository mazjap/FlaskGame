import SwiftUI

protocol ColorRepresentable {
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
}

extension ColorRepresentable {
    init?(hex hexStr: String) {
        guard !hexStr.isEmpty else { return nil }
        
        var normalizedString: String
        
        if hexStr.first == "#" {
            normalizedString = String(hexStr.dropFirst())
        } else if let c = UIColor.cssColors[hexStr] {
            normalizedString = c
        } else {
            normalizedString = hexStr
        }
        
        switch normalizedString.count {
        case 2:
            normalizedString = String(repeating: normalizedString, count: 3)
        case 3, 4:
            normalizedString = normalizedString.reduce("") { "\($0)\($1)\($1)" }
        case 6, 8:
            break
        default:
            return nil
        }
        
        if normalizedString.count == 6 {
            normalizedString = "ff" + normalizedString
        }
        
        guard let hex = UInt32(normalizedString, radix: 16) else {
            return nil
        }
        
        self.init(hex: hex)
    }
    
    init(hex: UInt32) {
        let alpha = (hex >> 24) & 0xff
        let red = (hex >> 16) & 0xff
        let green = (hex >> 8) & 0xff
        let blue = hex & 0xff
        
        self.init(red: UInt8(red), green: UInt8(green), blue: UInt8(blue), alpha: UInt8(alpha))
    }
    
    init(red: UInt8, green: UInt8, blue: UInt8, alpha: UInt8 = .max) {
        let max: Double = Double(UInt8.max)
        
        let red = Double(red) / max
        let green = Double(green) / max
        let blue = Double(blue) / max
        let alpha = Double(alpha) / max
        
        print("r\(red)g\(green)b\(blue)a\(alpha)")
        
        self.init(
            red: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
    }
    
    static var random: UIColor {
        UIColor(
            hue: .random(in: 0...1),
            saturation: .random(in: 0...1),
            brightness: .random(in: 0...1),
            alpha: 1
        )
    }
    
    static var randomWithAlpha: UIColor {
        UIColor(
            hue: .random(in: 0...1),
            saturation: .random(in: 0...1),
            brightness: .random(in: 0...1),
            alpha: .random(in: 0...1)
        )
    }
}

extension UIColor: ColorRepresentable {
    static let kindaClear = UIColor.white.withAlphaComponent(0.01)
    
    static let primaryBackground = UIColor(named: "std_primary_background")!
    static let secondaryBackground = UIColor(named: "std_secondary_background")!
    static let tertiaryBackground = UIColor(named: "std_tertiary_background")!
    
    static let primaryLabel = UIColor(named: "std_primary_label")!
    static let secondaryLabel = UIColor(named: "std_secondary_label")!
    static let tertiaryLabel = UIColor(named: "std_tertiary_label")!
    
    static let cssColors = [
        "black" : "#000000", "silver" : "#C0C0C0", "gray" : "#808080",
        "white" : "#FFFFFF", "maroon" : "#800000", "red" : "#FF0000",
        "purple" : "#800080", "fuchsia" : "#FF00FF", "green" : "#008000",
        "lime" : "#00FF00", "olive" : "#808000", "yellow" : "#FFFF00",
        "navy" : "#000080", "blue" : "#0000FF", "teal" : "#008080",
        "aqua" : "#00FFFF", "aliceblue" : "#f0f8ff", "antiquewhite" : "#faebd7",
        "aqua" : "#00ffff", "aquamarine" : "#7fffd4", "azure" : "#f0ffff",
        "beige" : "#f5f5dc", "bisque" : "#ffe4c4", "black" : "#000000",
        "blanchedalmond" : "#ffebcd", "blue" : "#0000ff", "blueviolet" : "#8a2be2",
        "brown" : "#a52a2a", "burlywood" : "#deb887", "cadetblue" : "#5f9ea0",
        "chartreuse" : "#7fff00", "chocolate" : "#d2691e", "coral" : "#ff7f50",
        "cornflowerblue" : "#6495ed", "cornsilk" : "#fff8dc", "crimson" : "#dc143c",
        "cyan" : "#00ffff", "darkblue" : "#00008b", "darkcyan" : "#008b8b",
        "darkgoldenrod" : "#b8860b", "darkgray" : "#a9a9a9", "darkgreen" : "#006400",
        "darkgrey" : "#a9a9a9", "darkkhaki" : "#bdb76b", "darkmagenta" : "#8b008b",
        "darkolivegreen" : "#556b2f", "darkorange" : "#ff8c00", "darkorchid" : "#9932cc",
        "darkred" : "#8b0000", "darksalmon" : "#e9967a", "darkseagreen" : "#8fbc8f",
        "darkslateblue" : "#483d8b", "darkslategray" : "#2f4f4f", "darkslategrey" : "#2f4f4f",
        "darkturquoise" : "#00ced1", "darkviolet" : "#9400d3", "deeppink" : "#ff1493",
        "deepskyblue" : "#00bfff", "dimgray" : "#696969", "dimgrey" : "#696969",
        "dodgerblue" : "#1e90ff", "firebrick" : "#b22222", "floralwhite" : "#fffaf0",
        "forestgreen" : "#228b22", "fuchsia" : "#ff00ff", "gainsboro" : "#dcdcdc",
        "ghostwhite" : "#f8f8ff", "gold" : "#ffd700", "goldenrod" : "#daa520",
        "gray" : "#808080", "green" : "#008000", "greenyellow" : "#adff2f",
        "grey" : "#808080", "honeydew" : "#f0fff0", "hotpink" : "#ff69b4",
        "indianred" : "#cd5c5c", "indigo" : "#4b0082", "ivory" : "#fffff0",
        "khaki" : "#f0e68c", "lavender" : "#e6e6fa", "lavenderblush" : "#fff0f5",
        "lawngreen" : "#7cfc00", "lemonchiffon" : "#fffacd", "lightblue" : "#add8e6",
        "lightcoral" : "#f08080", "lightcyan" : "#e0ffff", "lightgoldenrodyellow" : "#fafad2",
        "lightgray" : "#d3d3d3", "lightgreen" : "#90ee90", "lightgrey" : "#d3d3d3",
        "lightpink" : "#ffb6c1", "lightsalmon" : "#ffa07a", "lightseagreen" : "#20b2aa",
        "lightskyblue" : "#87cefa", "lightslategray" : "#778899", "lightslategrey" : "#778899",
        "lightsteelblue" : "#b0c4de", "lightyellow" : "#ffffe0", "lime" : "#00ff00",
        "limegreen" : "#32cd32", "linen" : "#faf0e6", "magenta" : "#ff00ff",
        "maroon" : "#800000", "mediumaquamarine" : "#66cdaa", "mediumblue" : "#0000cd",
        "mediumorchid" : "#ba55d3", "mediumpurple" : "#9370db", "mediumseagreen" : "#3cb371",
        "mediumslateblue" : "#7b68ee", "mediumspringgreen" : "#00fa9a", "mediumturquoise" : "#48d1cc",
        "mediumvioletred" : "#c71585", "midnightblue" : "#191970", "mintcream" : "#f5fffa",
        "mistyrose" : "#ffe4e1", "moccasin" : "#ffe4b5", "navajowhite" : "#ffdead",
        "navy" : "#000080", "oldlace" : "#fdf5e6", "olive" : "#808000",
        "olivedrab" : "#6b8e23", "orange" : "#ffa500", "orangered" : "#ff4500",
        "orchid" : "#da70d6", "palegoldenrod" : "#eee8aa", "palegreen" : "#98fb98",
        "paleturquoise" : "#afeeee", "palevioletred" : "#db7093", "papayawhip" : "#ffefd5",
        "peachpuff" : "#ffdab9", "peru" : "#cd853f", "pink" : "#ffc0cb",
        "plum" : "#dda0dd", "powderblue" : "#b0e0e6", "purple" : "#800080",
        "red" : "#ff0000", "rosybrown" : "#bc8f8f", "royalblue" : "#4169e1",
        "saddlebrown" : "#8b4513", "salmon" : "#fa8072", "sandybrown" : "#f4a460",
        "seagreen" : "#2e8b57", "seashell" : "#fff5ee", "sienna" : "#a0522d",
        "silver" : "#c0c0c0", "skyblue" : "#87ceeb", "slateblue" : "#6a5acd",
        "slategray" : "#708090", "slategrey" : "#708090", "snow" : "#fffafa",
        "springgreen" : "#00ff7f", "steelblue" : "#4682b4", "tan" : "#d2b48c",
        "teal" : "#008080", "thistle" : "#d8bfd8", "tomato" : "#ff6347",
        "turquoise" : "#40e0d0", "violet" : "#ee82ee", "wheat" : "#f5deb3",
        "white" : "#ffffff", "whitesmoke" : "#f5f5f5", "yellow" : "#ffff00",
        "yellowgreen" : "#9acd32"
    ]
}

extension Color: ColorRepresentable {
    init(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        self.init(uiColor: UIColor(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    static let kindaClear = Color(uiColor: .kindaClear)
    
    static let primaryBackground = Color(uiColor: .primaryBackground)
    static let secondaryBackground = Color(uiColor: .secondaryBackground)
    static let tertiaryBackground = Color(uiColor: .tertiaryBackground)
    
    static let primaryLabel = Color(uiColor: .primaryLabel)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let tertiaryLabel = Color(uiColor: .tertiaryLabel)
}
