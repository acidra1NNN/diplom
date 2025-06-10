import SwiftUI
struct ResultView: View {
    let info: CarInfo

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Результаты поиска")
                    .font(.title2)
                    .bold()
                Text(info.vin)
                    .font(.title3)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)

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

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(info.servicePartner)
                            .font(.headline)
                        Text("Чинить машину тут")
                            .foregroundColor(.gray)
                        Button("Перейти") {
                            if let url = URL(string: "https://google.com") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .buttonStyle(.bordered)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Text(info.partsPartner)
                            .font(.headline)
                        Text("Купить запчасти тут")
                            .foregroundColor(.gray)
                        Button("Перейти") {
                            if let url = URL(string: "https://google.com") {
                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Информация")
        .navigationBarTitleDisplayMode(.inline)
    }
}
