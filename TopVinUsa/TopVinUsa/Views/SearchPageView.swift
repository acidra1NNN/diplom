import SwiftUI

struct SearchPageView: View {
    @StateObject private var viewModel = SearchPageViewModel()
    @State private var showResult = false

    var body: some View {
        ZStack {
            VStack(spacing: 20) {

                HStack {
                    Image("app-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
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
                    .disabled(viewModel.isLoading)

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
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    } else {
                        Text("Найти")
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(viewModel.isLoading)

                if viewModel.isLoading {
                    VStack(spacing: 10) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding()
                        Text("Поиск информации...")
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.white.opacity(0.9))
                }

                Spacer()
            }
            .blur(radius: viewModel.isLoading ? 3 : 0)

            if viewModel.isLoading {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .overlay(
                        VStack {
                            ProgressView()
                                .scaleEffect(2)
                                .tint(.white)
                            Text("Поиск информации...")
                                .foregroundColor(.white)
                                .padding(.top, 20)
                        }
                    )
            }
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Ок")))
        }
        .navigationDestination(isPresented: $showResult) {
            if let car = viewModel.foundCar {
                ResultView(info: car)
            }
        }
    }
}
