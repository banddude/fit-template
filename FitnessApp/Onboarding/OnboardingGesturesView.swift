import SwiftUI

struct OnboardingGesturesView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()

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
                VStack {
                    ProgressView()
                    Text("Loading...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemGroupedBackground))
            }
        }
    }
}

#Preview {
    OnboardingGesturesView()
}