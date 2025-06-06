import Foundation
import SwiftUI

class SearchPageViewModel: ObservableObject {
    @Published var vin: String = ""
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMessage: String = ""
    @Published var foundCar: CarInfo? = nil

    func searchVIN(completion: @escaping (CarInfo?) -> Void) {
        guard !vin.isEmpty else {
            alertMessage = "Поле VIN не может быть пустым"
            showAlert = true
            completion(nil)
            return
        }

        guard vin.count >= 17 else {
            alertMessage = "VIN должен содержать минимум 17 символов"
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
                        // ВАЖНО: вызови addHistory здесь!
                        self?.addHistory(userId: 1, car: car) // <-- подставь реальный userId
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
        guard let url = URL(string: "http://localhost:8082/add") else { return }
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
