import Foundation
import SwiftUI

class SearchPageViewModel: ObservableObject {
    @Published var vin: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var foundCar: CarInfo? = nil

    func searchVIN(completion: @escaping (CarInfo?) -> Void) {
        // Валидация длины
        guard vin.count == 17 else {
            alertMessage = "VIN номер должен содержать ровно 17 символов"
            showAlert = true
            completion(nil)
            return
        }
        
        // Валидация символов VIN
        let vinRegex = "^[A-HJ-NPR-Z0-9]{17}$"
        let vinPredicate = NSPredicate(format: "SELF MATCHES %@", vinRegex)
        guard vinPredicate.evaluate(with: vin) else {
            alertMessage = "Недопустимые символы в VIN номере"
            showAlert = true
            completion(nil)
            return
        }

        isLoading = true

        CarSearchService.shared.searchVIN(vin: vin) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                case .success(let car):
                    if car.make.isEmpty && car.model.isEmpty && car.year.isEmpty {
                        self?.alertMessage = "Данные по VIN не найдены"
                        self?.showAlert = true
                        completion(nil)
                    } else {
                        self?.foundCar = car
                        // Используем актуальный user_id
                        if let userId = AuthService.shared.getCurrentUserID() {
                            self?.addHistory(userId: userId, car: car)
                        }
                        completion(car)
                    }
                case .failure:
                    self?.alertMessage = "Данные по VIN не найдены"
                    self?.showAlert = true 
                    completion(nil)
                }
            }
        }
    }

    func addHistory(userId: Int, car: CarInfo) {
        // Изменяем URL
        guard let url = URL(string: "http://127.0.0.1:8082/add") else { return } // было "http://localhost:8082/add"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: Any] = [
            "user_id": userId,
            "vin": car.vin,
            "make": car.make,
            "model": car.model,
            "year": car.year
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        URLSession.shared.dataTask(with: request).resume()
    }
}
