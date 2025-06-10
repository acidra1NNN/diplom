import Foundation

struct CarInfo: Decodable {
    let vin: String
    let make: String
    let model: String
    let year: String
    let foundOnCopart: Bool
    let damage: String
    let runsDrives: String
    let servicePartner: String = "ПАРТНЕР СТО"  // Добавляем новые поля
    let partsPartner: String = "ПАРТНЕР АВТОЗАПЧАСТЕЙ"

    enum CodingKeys: String, CodingKey {
        case vin, make, model, year
        case foundOnCopart = "found_on_copart"
        case damage
        case runsDrives = "runs_drives"
    }
}
