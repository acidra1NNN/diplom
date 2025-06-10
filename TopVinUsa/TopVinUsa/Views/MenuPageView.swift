import SwiftUI

struct MenuPageView: View {
    @EnvironmentObject var router: AppNavigationRouter
    @State private var username: String = ""
    
    private let buttonWidth: CGFloat = 200
    private let buttonHeight: CGFloat = 50
    
    var body: some View {
        VStack(spacing: 16) { 
            VStack(spacing: 8) {
                Text("Меню")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 20)
                Text("Здравствуйте, \(username)")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Контейнер для кнопок
            VStack(spacing: 20) {
                Button("Поиск по VIN") {
                    router.navigate(to: .search)
                }
                .frame(width: buttonWidth, height: buttonHeight)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                
                Button("История поиска") {
                    router.navigate(to: .history)
                }
                .frame(width: buttonWidth, height: buttonHeight)
                .background(Color.blue.opacity(0.1))
                .foregroundColor(.blue)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.blue, lineWidth: 1)
                )
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .onAppear {
            loadUsername()
        }
    }
    
    private func loadUsername() {
        if let token = UserDefaults.standard.string(forKey: "jwtToken"),
           let data = Data(base64Encoded: token.components(separatedBy: ".")[1].padding(toLength: ((token.components(separatedBy: ".")[1].count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
           let claims = try? JSONDecoder().decode(AuthService.JWTClaims.self, from: data) {
            username = claims.email.components(separatedBy: "@")[0]
        }
    }
}

#Preview {
    MenuPageView()
}
