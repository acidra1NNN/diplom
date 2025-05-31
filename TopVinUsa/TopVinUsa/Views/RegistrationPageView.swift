import SwiftUI

struct RegistrationPageView: View {
    @StateObject private var viewModel = RegistrationPageViewModel()

    var body: some View {
        VStack(spacing: 20) {
            Text("Регистрация")
                .font(.largeTitle)
                .bold()

            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)

            SecureField("Пароль", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)

            if viewModel.isLoading {
                ProgressView()
            }

            Button("Зарегистрироваться") {
                viewModel.login()
            }
            .disabled(viewModel.isLoading)
        }
        .padding()
    }
}
