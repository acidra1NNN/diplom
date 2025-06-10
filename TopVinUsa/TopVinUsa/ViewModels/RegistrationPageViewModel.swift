import Foundation

final class RegistrationPageViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var username: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func register(router: AppNavigationRouter) {
        // Валидация на клиенте
        guard !email.isEmpty else {
            alertMessage = "Email не может быть пустым"
            showAlert = true
            return
        }

        guard !password.isEmpty else {
            alertMessage = "Пароль не может быть пустым"
            showAlert = true
            return
        }

        guard password.count >= 6 else {
            alertMessage = "Пароль должен содержать минимум 6 символов"
            showAlert = true
            return
        }

        isLoading = true
        AuthService.shared.register(email: email, password: password, username: username) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success:
                    router.navigate(to: .authorization)
                case .failure(let error):
                    switch error.localizedDescription {
                    case "Пользователь с таким email уже существует":
                        self?.alertMessage = "Этот email уже зарегистрирован"
                    default:
                        self?.alertMessage = error.localizedDescription
                    }
                    self?.showAlert = true
                }
            }
        }
    }
}
