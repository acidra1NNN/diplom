import Foundation

final class UserHistoryPageViewModel: ObservableObject {
    @Published var history: [HistoryItem] = []

    func loadHistory(userId: Int) {
        // Изменяем URL
        guard let url = URL(string: "http://127.0.0.1:8082/user?user_id=\(userId)") else { return } // было "http://localhost:8082/user..."
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data else { return }
            if let items = try? JSONDecoder().decode([HistoryItem].self, from: data) {
                DispatchQueue.main.async {
                    self.history = items
                }
            }
        }.resume()
    }
}
