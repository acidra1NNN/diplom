import SwiftUI

struct UserHistoryPageView: View {
    @StateObject private var viewModel = UserHistoryPageViewModel()
    // Получи userId из своего AuthService или UserDefaults
    let userId: Int = 1 // <-- временно, потом подставь реальный id

    var body: some View {
        VStack {
            Text("История поиска")
                .font(.largeTitle)
                .bold()
            List(viewModel.history) { item in
                VStack(alignment: .leading) {
                    Text("VIN: \(item.vin)")
                    Text("Марка: \(item.make), Модель: \(item.model), Год: \(item.year)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Дата: \(item.searchedAt)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            viewModel.loadHistory(userId: userId)
        }
    }
}
