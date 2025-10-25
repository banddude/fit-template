import SwiftUI

// MARK: - Color Extensions

// Convert string colors from JSON to SwiftUI Colors
extension String {
    var swiftUIColor: Color {
        switch self.lowercased() {
        // Standard colors
        case "clear": return .clear
        case "black": return .black
        case "white": return .white
        case "gray", "grey": return .gray
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "orange": return .orange
        case "yellow": return .yellow
        case "pink": return .pink
        case "purple": return .purple
        case "primary": return .primary
        case "secondary": return .secondary

        // iOS 15+ colors
        case "mint": return .mint
        case "teal": return .teal
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "brown": return .brown

        // Semantic colors
        case "accentcolor", "accent": return .accentColor

        // Custom hex color support (e.g., "#FF5733" or "FF5733")
        default:
            if self.hasPrefix("#") {
                return Color(hex: String(self.dropFirst()))
            } else if self.count == 6 && self.allSatisfy({ $0.isHexDigit }) {
                return Color(hex: self)
            }
            // Try system colors
            if let color = Color.fromString(self) {
                return color
            }
            return .blue // Fallback
        }
    }
}

// Support for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // Get SwiftUI system colors by string name
    static func fromString(_ name: String) -> Color? {
        let colorName = name.lowercased()

        // System colors
        let systemColors: [String: Color] = [
            "systemred": Color(.systemRed),
            "systemgreen": Color(.systemGreen),
            "systemblue": Color(.systemBlue),
            "systemorange": Color(.systemOrange),
            "systemyellow": Color(.systemYellow),
            "systempink": Color(.systemPink),
            "systempurple": Color(.systemPurple),
            "systemteal": Color(.systemTeal),
            "systemindigo": Color(.systemIndigo),
            "systemgray": Color(.systemGray),
            "systemgray2": Color(.systemGray2),
            "systemgray3": Color(.systemGray3),
            "systemgray4": Color(.systemGray4),
            "systemgray5": Color(.systemGray5),
            "systemgray6": Color(.systemGray6),
            "label": Color(.label),
            "secondarylabel": Color(.secondaryLabel),
            "tertiarylabel": Color(.tertiaryLabel),
            "quaternarylabel": Color(.quaternaryLabel),
            "systembackground": Color(.systemBackground),
            "secondarysystembackground": Color(.secondarySystemBackground),
            "tertiarysystembackground": Color(.tertiarySystemBackground),
            "systemgroupedbackground": Color(.systemGroupedBackground),
            "secondarysystemgroupedbackground": Color(.secondarySystemGroupedBackground),
            "tertiarysystemgroupedbackground": Color(.tertiarySystemGroupedBackground),
            "systemfill": Color(.systemFill),
            "secondarysystemfill": Color(.secondarySystemFill),
            "tertiarysystemfill": Color(.tertiarySystemFill),
            "quaternarysystemfill": Color(.quaternarySystemFill),
            "placeholdertext": Color(.placeholderText),
            "separator": Color(.separator),
            "opaqueseparator": Color(.opaqueSeparator),
            "link": Color(.link)
        ]

        return systemColors[colorName]
    }
}

// MARK: - View Extensions

extension View {
    /// Applies conditional modifier based on a boolean condition
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}