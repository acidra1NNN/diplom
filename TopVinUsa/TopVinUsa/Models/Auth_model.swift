import Foundation

enum AuthError: LocalizedError {
    case emailExists
    case wrongPassword
    case userNotFound
    case networkError
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .emailExists:
            return "Пользователь с таким email уже существует"
        case .wrongPassword:
            return "Неверный пароль"
        case .userNotFound:
            return "Пользователь не найден"
        case .networkError:
            return "Ошибка сети. Попробуйте позже"
        case .invalidInput:
            return "Неверный формат данных"
        }
    }
}

final class AuthService {
    static let shared = AuthService()
    private init() {}

    // Изменяем baseURL
    let baseURL = "http://127.0.0.1:8080" // было "http://localhost:8080"

    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(AuthError.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(AuthError.networkError))
                return
            }
            
            switch httpResponse.statusCode {
            case 200:
                if let token = httpResponse.value(forHTTPHeaderField: "Authorization") {
                    let jwt = token.replacingOccurrences(of: "Bearer ", with: "")
                    completion(.success(jwt))
                } else {
                    completion(.failure(AuthError.networkError))
                }
            case 401:
                if let data = data, let message = String(data: data, encoding: .utf8) {
                    if message.contains("Пользователь не найден") {
                        completion(.failure(AuthError.userNotFound))
                    } else {
                        completion(.failure(AuthError.wrongPassword))
                    }
                } else {
                    completion(.failure(AuthError.wrongPassword))
                }
            default:
                completion(.failure(AuthError.networkError))
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
                completion(.failure(AuthError.networkError))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(AuthError.networkError))
                return
            }
            
            switch httpResponse.statusCode {
            case 201:
                completion(.success(()))
            case 409:
                completion(.failure(AuthError.emailExists))
            case 400:
                completion(.failure(AuthError.invalidInput))
            default:
                completion(.failure(AuthError.networkError))
            }
        }.resume()
    }

    struct JWTClaims: Codable {
        let email: String
        let user_id: Int
        let exp: TimeInterval
        let iat: TimeInterval
    }

    func getCurrentUserID() -> Int? {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken"),
              let data = Data(base64Encoded: token.components(separatedBy: ".")[1].padding(toLength: ((token.components(separatedBy: ".")[1].count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
              let claims = try? JSONDecoder().decode(JWTClaims.self, from: data) else {
            return nil
        }
        return claims.user_id
    }
}
