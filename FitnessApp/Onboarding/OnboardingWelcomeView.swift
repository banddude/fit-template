import SwiftUI

struct OnboardingWelcomeView: View {
    @StateObject private var dataLoader = OnboardingDataLoader()
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        Group {
            if let welcomeData = dataLoader.data?.onboarding.welcome {
                VStack(spacing: 16) {
                    // Logo and Title
                    VStack(spacing: 12) {
                        // App icon - automatically uses the icon from Assets.xcassets
                        if let appIcon = AppConfig.getAppIcon() {
                            Image(uiImage: appIcon)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 22))
                        } else {
                            // Fallback if AppIcon can't be loaded
                            Image(systemName: "app.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.accentColor)
                        }

                        Text(welcomeData.title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description
                    VStack(spacing: 12) {
                        Text(welcomeData.subtitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.accentColor)
                        
                        Text(welcomeData.description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 20)
                    }
                    
                    // Features - styled like WorkoutsView cards
                    VStack(spacing: 12) {
                        ForEach(welcomeData.features, id: \.title) { feature in
                            FeatureCard(
                                icon: feature.icon,
                                title: feature.title,
                                description: feature.description,
                                color: feature.color.swiftUIColor
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                }
                .padding()
                .background(themeManager.isDarkMode ? Color.black : Color(.systemBackground))
            } else {
                // Loading state
                VStack {
                    ProgressView()
                    Text("Loading...")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(themeManager.isDarkMode ? Color.black : Color(.systemBackground))
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.5), lineWidth: 1.5)
        )
    }
}

#Preview {
    OnboardingWelcomeView()
}