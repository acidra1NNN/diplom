import Foundation

final class CarSearchService {
    static let shared = CarSearchService()
    private init() {}

    // Изменяем baseURL
    let baseURL = "http://127.0.0.1:8081" // было "http://localhost:8081"

    func searchVIN(vin: String, completion: @escaping (Result<CarInfo, Error>) -> Void) {
        // Проверка VIN перед отправкой запроса
        let vinRegex = "^[A-HJ-NPR-Z0-9]{17}$"
        let vinPredicate = NSPredicate(format: "SELF MATCHES %@", vinRegex)
        
        guard vinPredicate.evaluate(with: vin) else {
            completion(.failure(NSError(domain: "Invalid VIN format", code: 400)))
            return
        }

        guard let url = URL(string: "\(baseURL)/api/search") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["vin": vin]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No response", code: 0)))
                return
            }
            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }
            if httpResponse.statusCode == 200 {
                do {
                    let info = try JSONDecoder().decode(CarInfo.self, from: data)
                    completion(.success(info))
                } catch {
                    completion(.failure(error))
                }
            } else {
                completion(.failure(NSError(domain: "Not found", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
