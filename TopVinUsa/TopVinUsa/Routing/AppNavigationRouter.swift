import Foundation

enum AppRoute: Hashable {
    case welcome
    case authorization
    case registration
    case search
    case menu
    case history
    
}

final class AppNavigationRouter: ObservableObject {
    @Published var path: [AppRoute] = []

    func navigate(to route: AppRoute) {
        path.append(route)
    }

    func goBack() {
        _ = path.popLast()
    }

    func reset() {
        path.removeAll()
    }
}
