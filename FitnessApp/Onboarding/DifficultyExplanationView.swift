import SwiftUI

struct DifficultyExplanationView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            if let difficultyData = dataLoader.data?.onboarding.difficulty {
                OnboardingTemplateView(
                    icon: difficultyData.icon,
                    title: difficultyData.title,
                    description: difficultyData.description,
                    cardData: difficultyData.cards,
                    proTip: difficultyData.proTip
                )
            } else {
                // Loading state
                VStack(spacing: 20) {
                    ProgressView()
                    Text("Loading...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.isDarkMode ? Color.black : Color(.systemBackground))
            }
        }
    }
}

#Preview {
    DifficultyExplanationView()
}
