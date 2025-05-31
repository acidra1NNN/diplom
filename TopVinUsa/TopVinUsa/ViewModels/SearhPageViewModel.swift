import Foundation
import SwiftUI

class SearchPageViewModel: ObservableObject {
    @Published var vin: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""

    func searchVIN() {
        guard !vin.isEmpty else {
            alertMessage = "Поле VIN не может быть пустым"
            showAlert = true
            return
        }

        guard vin.count >= 17 else {
            alertMessage = "VIN должен содержать минимум 17 символов"
            showAlert = true
            return
        }

        isLoading = true

        // Эмуляция запроса на сервер
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.isLoading = false
            print("Поиск VIN: \(self.vin)")
            // Здесь ты будешь вызывать свой бекенд
        }
    }
}
