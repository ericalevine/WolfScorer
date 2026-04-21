import Foundation

struct Player: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var points: Int = 0

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}
