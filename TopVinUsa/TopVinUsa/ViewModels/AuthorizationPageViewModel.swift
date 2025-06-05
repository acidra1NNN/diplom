import Foundation

final class AuthorizationPageViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func login(router: AppNavigationRouter) {
        isLoading = true
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    router.navigate(to: .menu) // Переход на меню!
                case .failure(let error):
                    self?.alertMessage = error.localizedDescription
                    self?.showAlert = true
                }
            }
        }
    }
}
