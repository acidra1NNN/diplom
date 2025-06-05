import SwiftUI

struct MenuPageView: View {
    @EnvironmentObject var router: AppNavigationRouter

    var body: some View {
        VStack(spacing: 32) {
            Text("Меню")
                .font(.largeTitle)
                .bold()

            Button("Поиск по VIN") {
                router.navigate(to: .search)
            }
            .buttonStyle(.borderedProminent)

            Button("История поиска") {
                router.navigate(to: .history)
            }
            .buttonStyle(.bordered)

            Spacer()
        }
        .padding()
    }
}
