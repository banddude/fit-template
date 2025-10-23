import SwiftUI
import Foundation

struct OnboardingData: Codable {
    let onboarding: OnboardingContent
}

struct OnboardingContent: Codable {
    let welcome: WelcomeData
    let difficulty: DifficultyData
    let equipment: EquipmentData
    let tutorial: TutorialData
}

struct WelcomeData: Codable {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let features: [FeatureData]
}

struct FeatureData: Codable {
    let icon: String
    let title: String
    let description: String
    let color: String
}

struct DifficultyData: Codable {
    let icon: String
    let title: String
    let description: String
    let proTip: String
    let cards: [CardData]
}

struct EquipmentData: Codable {
    let icon: String
    let title: String
    let description: String
    let proTip: String
    let cards: [CardData]
}

struct TutorialData: Codable {
    let icon: String
    let title: String
    let description: String
    let proTip: String
    let cards: [CardData]
}

struct CardData: Codable {
    let icon: String?
    let title: String
    let description: String
    let color: String
}

// Extensions to convert string colors to SwiftUI Colors
extension String {
    var swiftUIColor: Color {
        switch self.lowercased() {
        case "mint": return .mint
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "teal": return .teal
        case "indigo": return .indigo
        case "red": return .red
        case "green": return .green
        case "yellow": return .yellow
        case "pink": return .pink
        default: return .blue
        }
    }
}

// Data loader
class OnboardingDataLoader: ObservableObject {
    @Published var data: OnboardingData?
    private let githubBaseURL = AppConfig.contentBaseURL
    
    init() {
        loadOnboardingData()
    }
    
    private func loadOnboardingData() {
        // Try loading from local bundle first as fallback
        if let bundleData = loadFromBundle() {
            self.data = bundleData
        }
        
        // Then load from GitHub for latest content
        loadFromGitHub()
    }
    
    private func loadFromBundle() -> OnboardingData? {
        guard let url = Bundle.main.url(forResource: "onboarding", withExtension: "json") else {
            print("Could not find local onboarding.json")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(OnboardingData.self, from: data)
        } catch {
            print("Error loading local onboarding data: \(error)")
            return nil
        }
    }
    
    private func loadFromGitHub() {
        let timestamp = Int(Date().timeIntervalSince1970)
        let urlString = "\(githubBaseURL)/onboarding.json?cache=\(timestamp)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid GitHub onboarding URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Error fetching onboarding data from GitHub: \(error)")
                return
            }
            
            guard let data = data else {
                print("No onboarding data received from GitHub")
                return
            }
            
            do {
                let onboardingData = try JSONDecoder().decode(OnboardingData.self, from: data)
                DispatchQueue.main.async {
                    self?.data = onboardingData
                    print("Successfully loaded onboarding data from GitHub")
                }
            } catch {
                print("Error decoding GitHub onboarding data: \(error)")
            }
        }.resume()
    }
}