import SwiftUI

struct Obstruction: Identifiable {
    let id: UUID
    let coordinates: (CellCoordinate, CellCoordinate)

    init(id: UUID = UUID(), coordinates: (CellCoordinate, CellCoordinate)) {
        self.id = id
        self.coordinates = coordinates
    }
}

extension Obstruction: Equatable {
    static func == (lhs: Obstruction, rhs: Obstruction) -> Bool {
        lhs.id == rhs.id
    }
}

extension Obstruction: Codable {
    enum CodingKeys: String, CodingKey {
        case id
        case leftCoordinate
        case rightCoordinate
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(coordinates.0, forKey: .leftCoordinate)
        try container.encode(coordinates.1, forKey: .rightCoordinate)
    }

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let id = try values.decode(UUID.self, forKey: .id)
        let leftCoordinate = try values.decode(CellCoordinate.self, forKey: .leftCoordinate)
        let rightCoordinate = try values.decode(CellCoordinate.self, forKey: .rightCoordinate)
        self.init(id: id, coordinates: (leftCoordinate, rightCoordinate))
    }
}
