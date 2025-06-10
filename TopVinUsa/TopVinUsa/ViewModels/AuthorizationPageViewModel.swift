import Foundation

final class AuthorizationPageViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func login(router: AppNavigationRouter) {
        // Валидация на клиенте
        guard !email.isEmpty else {
            alertMessage = "Введите email"
            showAlert = true
            return
        }

        guard !password.isEmpty else {
            alertMessage = "Введите пароль"
            showAlert = true
            return
        }

        isLoading = true
        AuthService.shared.login(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    router.navigate(to: .menu)
                case .failure(let error):
                    if let authError = error as? AuthError {
                        self?.alertMessage = authError.localizedDescription
                    } else {
                        self?.alertMessage = "Неизвестная ошибка. Попробуйте позже"
                    }
                    self?.showAlert = true
                }
            }
        }
    }
}
