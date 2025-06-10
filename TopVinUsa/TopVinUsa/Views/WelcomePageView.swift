import SwiftUI

struct WelcomePageView: View {
    @EnvironmentObject var router: AppNavigationRouter
    @StateObject private var viewModel = WelcomePageViewModel()
    
    // Определяем константы для размеров кнопок
    private let buttonWidth: CGFloat = 200
    private let buttonHeight: CGFloat = 50
    
    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image("app-logo") // Заменили Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                
                Text("Добро пожаловать в TopVinUSA")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("Войти") {
                    router.navigate(to: .authorization)
                }
                .frame(width: buttonWidth, height: buttonHeight)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("Зарегистрироваться") {
                    router.navigate(to: .registration)
                }
                .frame(width: buttonWidth, height: buttonHeight)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
                
                Spacer()
            }
            .padding()
        }
    }
}

