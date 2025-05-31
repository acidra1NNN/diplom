import SwiftUI

@main
struct TopVinUsaApp: App {
    @StateObject private var router = AppNavigationRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                WelcomePageView()
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .authorization:
                            AuthorizationPageView()
                        case .registration:
                            RegistrationPageView()
                        case .welcome:
                            WelcomePageView()
                        }
                    }
            }
            .environmentObject(router)
        }
    }
}
