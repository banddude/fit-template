import SwiftUI

// Centralized section configuration
struct WorkoutSection {
    static let warmUp = "Warm-up"
    static let main = "Main"
    static let coolDown = "Cool-down"

    static let allSections = [warmUp, main, coolDown]
}

extension String {
    var sectionColor: Color {
        switch self {
        case WorkoutSection.warmUp: return .orange
        case WorkoutSection.main: return .purple
        case WorkoutSection.coolDown: return .teal
        default: return .gray
        }
    }

    var sectionIcon: String {
        switch self {
        case WorkoutSection.warmUp: return "thermometer.low"
        case WorkoutSection.main: return "figure.strengthtraining.traditional"
        case WorkoutSection.coolDown: return "leaf"
        default: return "circle"
        }
    }
}