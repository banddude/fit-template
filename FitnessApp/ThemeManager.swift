import SwiftUI

class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
        }
    }
    
    init() {
        // Force dark mode and save it
        isDarkMode = true
        UserDefaults.standard.set(true, forKey: "isDarkMode")
    }
    
    var colorScheme: ColorScheme {
        return isDarkMode ? .dark : .light
    }
}