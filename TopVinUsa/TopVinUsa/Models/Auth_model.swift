import Foundation

final class AuthService {
    static let shared = AuthService()
    private init() {}

    let baseURL = "http://localhost:8080" // или ваш реальный адрес

    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password]
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
            if httpResponse.statusCode == 200,
               let token = httpResponse.value(forHTTPHeaderField: "Authorization") {
                // "Bearer <token>"
                let jwt = token.replacingOccurrences(of: "Bearer ", with: "")
                completion(.success(jwt))
            } else {
                completion(.failure(NSError(domain: "Auth failed", code: httpResponse.statusCode)))
            }
        }.resume()
    }

    func register(email: String, password: String, username: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password, "username": username]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(NSError(domain: "No response", code: 0)))
                return
            }
            if httpResponse.statusCode == 201 {
                completion(.success(()))
            } else {
                completion(.failure(NSError(domain: "Registration failed", code: httpResponse.statusCode)))
            }
        }.resume()
    }
}
