import SwiftUI

struct UserHistoryPageView: View {
    @StateObject private var viewModel = UserHistoryPageViewModel()
    @State private var selectedCar: CarInfo?
    @State private var showingDetail = false
    
    var body: some View {
        VStack {
            Text("История поиска")
                .font(.largeTitle)
                .bold()
            
            List(viewModel.history) { item in
                Button(action: {
                    // Создаем CarInfo из HistoryItem
                    selectedCar = CarInfo(
                        vin: item.vin,
                        make: item.make,
                        model: item.model,
                        year: item.year,
                        foundOnCopart: false,
                        damage: "Нет данных",
                        runsDrives: "Нет данных"
                    )
                    showingDetail = true
                }) {
                    VStack(alignment: .leading) {
                        Text("\(item.make) \(item.model) \(item.year)")
                            .font(.headline)
                    }
                }
            }
        }
        .onAppear {
            if let userId = AuthService.shared.getCurrentUserID() {
                viewModel.loadHistory(userId: userId)
            }
        }
        .navigationDestination(isPresented: $showingDetail) {
            if let car = selectedCar {
                ResultView(info: car)
            }
        }
    }
}
