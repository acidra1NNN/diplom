import SwiftUI

struct WelcomePageView: View {
    @EnvironmentObject var router: AppNavigationRouter
    @StateObject private var viewModel = WelcomePageViewModel()

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .foregroundColor(.blue)

                Text("Добро пожаловать в TopVinUSA")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Spacer()

                Button("Войти") {
                      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        router.navigate(to: .authorization)
                    }
                }
                .buttonStyle(.borderedProminent)

                Button("Зарегистрироваться") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        router.navigate(to: .registration)
                    }
                }
                .buttonStyle(.bordered)

                Spacer()
            }
            .padding()
            }
        }
    }

