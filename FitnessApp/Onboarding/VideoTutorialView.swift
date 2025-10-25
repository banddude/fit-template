import SwiftUI

struct VideoTutorialView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            if let tutorialData = dataLoader.data?.onboarding.tutorial {
                OnboardingTemplateView(
                    icon: tutorialData.icon,
                    title: tutorialData.title,
                    description: tutorialData.description,
                    cardData: tutorialData.cards,
                    proTip: tutorialData.proTip
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
    VideoTutorialView()
}