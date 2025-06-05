import SwiftUI

struct RegistrationPageView: View {
    @EnvironmentObject var router: AppNavigationRouter
    @StateObject private var viewModel = RegistrationPageViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .bold()

            TextField("Имя пользователя", text: $viewModel.username)
                .textFieldStyle(.roundedBorder)

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Зарегистрироваться") {
                viewModel.register(router: router)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Ок")))
        }
    }
}
