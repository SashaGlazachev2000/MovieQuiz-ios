import Foundation

struct GameRecord: Codable {
    
    func isGameRecord(correct count: Int) -> Bool {
        if self.correct < count {
            return false
        }
        else {
            return true
        }
    }
    
    var correct: Int
    
    var total: Int
    
    var date: Date = Date()
}

