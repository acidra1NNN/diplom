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
}
