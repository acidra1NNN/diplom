import Foundation

final class AuthorizationPageViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false

    func login() {
        isLoading = true

        // Пример: заменить на вызов API через URLSession
        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
            DispatchQueue.main.async {
                self.isLoading = false
                print("JWT-токен: [здесь будет токен]")
            }
        }
    }
}
