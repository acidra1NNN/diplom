import Foundation

final class CarSearchService {
    static let shared = CarSearchService()
    private init() {}

    let baseURL = "http://localhost:8081" // или адрес search_service

    func searchVIN(vin: String, completion: @escaping (Result<CarInfo, Error>) -> Void) {
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
