import SwiftUI
import Foundation

// MARK: - Root Structure
struct OnboardingData: Codable {
    let onboarding: OnboardingContent
}

struct OnboardingContent: Codable {
    let welcome: WelcomeSection
    let difficulty: InfoSection
    let equipment: InfoSection
    let tutorial: InfoSection
}

// MARK: - Section Types

struct WelcomeSection: Codable {
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let features: [OnboardingCard]
}

struct InfoSection: Codable {
    let icon: String
    let title: String
    let description: String
    let proTip: String
    let cards: [OnboardingCard]
}

// MARK: - Unified Card Model

struct OnboardingCard: Codable, Identifiable {
    let id: UUID
    let icon: String?
    let title: String
    let description: String
    let color: String

    // Computed property for color conversion
    var displayColor: Color {
        color.swiftUIColor
    }

    // Custom decoding to generate UUID automatically
    enum CodingKeys: String, CodingKey {
        case icon, title, description, color
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = UUID()
        self.icon = try container.decodeIfPresent(String.self, forKey: .icon)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.color = try container.decode(String.self, forKey: .color)
    }

    // For programmatic creation
    init(icon: String?, title: String, description: String, color: String) {
        self.id = UUID()
        self.icon = icon
        self.title = title
        self.description = description
        self.color = color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(color, forKey: .color)
    }
}

// MARK: - Data Loader

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
