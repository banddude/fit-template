import SwiftUI

struct EquipmentOverviewView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            if let equipmentData = dataLoader.data?.onboarding.equipment {
                OnboardingTemplateView(
                    icon: equipmentData.icon,
                    title: equipmentData.title,
                    description: equipmentData.description,
                    cardData: equipmentData.cards,
                    proTip: equipmentData.proTip
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
    EquipmentOverviewView()
}
