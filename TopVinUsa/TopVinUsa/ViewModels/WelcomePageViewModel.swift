import Foundation
import SwiftUI

final class WelcomePageViewModel: ObservableObject {

    func goToAuthorization() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Переход на экран авторизации")
        }
    }

    func goToRegistration() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            print("Переход на экран регистрации")
        }
    }
}
