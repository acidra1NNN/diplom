import SwiftUI

struct UserHistoryPageView: View {
    @StateObject private var viewModel = UserHistoryPageViewModel()

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
            viewModel.loadHistory()
        }
    }
}
