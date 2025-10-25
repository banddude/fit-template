import SwiftUI

struct SplashView: View {
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ZStack {
            // Theme-aware background
            (themeManager.isDarkMode ? Color.black : Color.white).ignoresSafeArea()

            VStack(spacing: 20) {
                // App icon - automatically uses the icon from Assets.xcassets
                if let appIcon = AppConfig.getAppIcon() {
                    Image(uiImage: appIcon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 160, height: 160)
                        .clipShape(RoundedRectangle(cornerRadius: 35))
                }

                Text(AppConfig.appName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(themeManager.isDarkMode ? .white : .black)
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
} 