import SwiftUI
import PDFKit
import UIKit

struct ResultView: View {
    let info: CarInfo
    @State private var showShareSheet = false
    @State private var pdfData: Data?
    @State private var username: String = ""
    
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
            
            Button(action: {
                generatePDF()
            }) {
                HStack {
                    Image(systemName: "doc.fill")
                    Text("Сохранить в PDF")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .onAppear {
            loadUsername()
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData {
                ShareSheet(items: [data])
            }
        }
        .padding()
        .navigationTitle("Информация")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func loadUsername() {
        if let token = UserDefaults.standard.string(forKey: "jwtToken"),
           let data = Data(base64Encoded: token.components(separatedBy: ".")[1].padding(toLength: ((token.components(separatedBy: ".")[1].count + 3) / 4) * 4, withPad: "=", startingAt: 0)),
           let claims = try? JSONDecoder().decode(AuthService.JWTClaims.self, from: data) {
            username = claims.email.components(separatedBy: "@")[0]
        }
    }
    
    private func generatePDF() {
        let pdfMetaData = [
            kCGPDFContextCreator: "TopVinUsa",
            kCGPDFContextAuthor: username
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 8.27 * 72.0
        let pageHeight = 11.69 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        pdfData = renderer.pdfData { context in
            context.beginPage()
            
            // Настройка шрифтов
            let titleFont = UIFont.systemFont(ofSize: 24, weight: .bold)
            let subtitleFont = UIFont.systemFont(ofSize: 18)
            let regularFont = UIFont.systemFont(ofSize: 14)
            
            let textAttributes: [NSAttributedString.Key: Any] = [
                .font: regularFont
            ]
            
            // Отрисовка логотипа (если есть)
            if let logoImage = UIImage(named: "app-logo") {
                let logoRect = CGRect(x: (pageWidth - 60) / 2, y: 36, width: 60, height: 60)
                logoImage.draw(in: logoRect)
            }
            
            // Заголовок
            let titleString = "TopVinUsa"
            let titleStringSize = titleString.size(withAttributes: [.font: titleFont])
            let titleRect = CGRect(x: (pageWidth - titleStringSize.width) / 2,
                                 y: 110,
                                 width: titleStringSize.width,
                                 height: titleStringSize.height)
            titleString.draw(in: titleRect, withAttributes: [.font: titleFont])
            
            // Подзаголовок
            let subtitleString = "Отчет об авто для \(username)"
            let subtitleStringSize = subtitleString.size(withAttributes: [.font: subtitleFont])
            let subtitleRect = CGRect(x: (pageWidth - subtitleStringSize.width) / 2,
                                    y: 150,
                                    width: subtitleStringSize.width,
                                    height: subtitleStringSize.height)
            subtitleString.draw(in: subtitleRect, withAttributes: [.font: subtitleFont])
            
            // Информация об авто
            var yPosition: CGFloat = 200
            let leftMargin: CGFloat = 50
            let lineSpacing: CGFloat = 25
            
            let infoItems = [
                ("VIN:", info.vin),
                ("Марка:", info.make),
                ("Модель:", info.model),
                ("Год выпуска:", info.year),
                ("Найден на Copart:", info.foundOnCopart ? "Да" : "Нет"),
                ("Повреждения:", info.damage),
                ("Состояние:", info.runsDrives)
            ]
            
            for (label, value) in infoItems {
                let infoString = "\(label) \(value)"
                infoString.draw(at: CGPoint(x: leftMargin, y: yPosition),
                              withAttributes: textAttributes)
                yPosition += lineSpacing
            }
            
            // Дата и время
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy HH:mm"
            let currentDateTime = dateFormatter.string(from: Date())
            let dateString = "Дата составления: \(currentDateTime)"
            let dateStringSize = dateString.size(withAttributes: textAttributes)
            let dateRect = CGRect(x: (pageWidth - dateStringSize.width) / 2,
                                y: pageHeight - 50,
                                width: dateStringSize.width,
                                height: dateStringSize.height)
            dateString.draw(in: dateRect, withAttributes: textAttributes)
        }
        
        showShareSheet = true
    }
}

// Вспомогательное view для шаринга PDF
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items,
                                                applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController,
                              context: Context) {}
}
