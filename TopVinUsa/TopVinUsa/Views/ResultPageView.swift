import SwiftUI
struct ResultView: View {
    let info: CarInfo

    var body: some View {
        VStack(spacing: 16) {
            Text("Результаты VIN")
                .font(.title2)

            Form {
                HStack {
                    Text("Марка")
                    Spacer()
                    Text(info.make)
                }
                HStack {
                    Text("Модель")
                    Spacer()
                    Text(info.model)
                }
                HStack {
                    Text("Год выпуска")
                    Spacer()
                    Text(info.year)
                }
                HStack {
                    Text("Copart найден")
                    Spacer()
                    Text(info.foundOnCopart ? "Да" : "Нет")
                }
                HStack {
                    Text("Повреждения")
                    Spacer()
                    Text(info.damage)
                }
                HStack {
                    Text("Состояние")
                    Spacer()
                    Text(info.runsDrives)
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Информация")
        .navigationBarTitleDisplayMode(.inline)
    }
}
