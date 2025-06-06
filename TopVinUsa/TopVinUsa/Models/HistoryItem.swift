import Foundation

struct HistoryItem: Identifiable, Decodable {
    var id: UUID { UUID() } // Локальный id для SwiftUI List
    let vin: String
    let make: String
    let model: String
    let year: String
    let searchedAt: String

    enum CodingKeys: String, CodingKey {
        case vin, make, model, year, searchedAt = "searched_at"
    }
}
