import Foundation

struct HistoryItem: Identifiable, Decodable {
    let id: Int
    let vin: String
    let make: String
    let model: String
    let year: String
    let searchedAt: String
}

final class UserHistoryPageViewModel: ObservableObject {
    @Published var history: [HistoryItem] = []

    func loadHistory() {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else { return }
        var request = URLRequest(url: URL(string: "http://localhost:8080/history")!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { return }
            if let items = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                DispatchQueue.main.async {
                    self.history = items
                }
            }
        }.resume()
    }
}
