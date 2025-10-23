import SwiftUI

extension String {
    var sectionColor: Color {
        switch self {
        case "Warm-up": return .orange
        case "Main": return .purple
        case "Cool-down": return .teal
        default: return .gray
        }
    }

    var sectionIcon: String {
        switch self {
        case "Warm-up": return "thermometer.low"
        case "Main": return "figure.strengthtraining.traditional"
        case "Cool-down": return "leaf"
        default: return "circle"
        }
    }
}