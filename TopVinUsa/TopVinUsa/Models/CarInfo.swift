import Foundation

struct CarInfo: Decodable {
    let make: String
    let model: String
    let year: String
    let foundOnCopart: Bool
    let damage: String
    let runsDrives: String

    enum CodingKeys: String, CodingKey {
        case make, model, year, foundOnCopart = "found_on_copart", damage, runsDrives = "runs_drives"
    }
}
