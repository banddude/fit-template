import SwiftUI

struct OnboardingGesturesView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()

    var body: some View {
        Group {
            if let tutorialData = dataLoader.data?.onboarding.tutorial {
                let cardData = tutorialData.cards.map { card in
                    OnboardingCardData(
                        icon: card.icon,
                        title: card.title,
                        description: card.description,
                        color: card.color.swiftUIColor,
                        gesture: nil
                    )
                }
                
                OnboardingTemplateView(
                    icon: tutorialData.icon,
                    title: tutorialData.title,
                    description: tutorialData.description,
                    cardData: cardData,
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