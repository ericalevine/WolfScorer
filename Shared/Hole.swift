import Foundation

struct HoleRecord: Identifiable, Codable {
    let id: UUID
    let number: Int
    let wolfPlayerID: UUID
    var partnerPlayerID: UUID?
    var isBlindWolf: Bool = false
    var isLoneWolf: Bool = false
    var scores: [UUID: Int] = [:]
    var result: String = ""
    var pointsAwarded: [UUID: Int] = [:]

    init(number: Int, wolfPlayerID: UUID) {
        self.id = UUID()
        self.number = number
        self.wolfPlayerID = wolfPlayerID
    }
}
