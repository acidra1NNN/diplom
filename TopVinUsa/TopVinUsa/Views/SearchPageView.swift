import SwiftUI

struct SearchPageView: View {
    @StateObject private var viewModel = SearchPageViewModel()
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 20) {
            // Заголовок
            HStack {
                Image(systemName: "car.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("TopVinUSA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.top, 40)

            // Поле VIN
            TextField("Введите VIN номер", text: $viewModel.vin)
                .textInputAutocapitalization(.characters)
                .disableAutocorrection(true)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                .padding(.horizontal)

            // Кнопка поиска
            Button(action: {
                viewModel.searchVIN { car in
                    if car != nil {
                        showResult = true
                    }
                }
            }) {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .frame(width: 200, height: 50)
                } else {
                    Text("Найти")
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }

            Spacer()
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Ок")))
        }
        .navigationDestination(isPresented: $showResult) {
            if let car = viewModel.foundCar {
                ResultView(info: car)
            } else {
                EmptyView()
            }
        }
    }
}
