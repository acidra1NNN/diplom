import SwiftUI

struct AuthorizationPageView: View {
    @EnvironmentObject var router: AppNavigationRouter
    @StateObject private var viewModel = AuthorizationPageViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Авторизация")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Войти") {
                viewModel.login(router: router)
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
        .alert(isPresented: $viewModel.showAlert) {
            Alert(title: Text("Ошибка"), message: Text(viewModel.alertMessage), dismissButton: .default(Text("Ок")))
        }
    }
}
