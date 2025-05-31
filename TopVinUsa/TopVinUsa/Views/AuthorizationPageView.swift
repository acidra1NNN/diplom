import SwiftUI

struct AuthorizationPageView: View {
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
                viewModel.login()
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
