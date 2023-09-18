import Foundation

protocol StatisticService{
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService{
    
    var totalAccuracy: Double { //Средний результат
        get{
            guard let data = userDefaults.data(forKey: Keys.total.rawValue),
                  let total = try? JSONDecoder().decode(Double.self, from: data) else {return 0}
            return total
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.total.rawValue)
        }
    }
    
    var gamesCount: Int{ //Колличество игр
        get{
        guard let data = userDefaults.data(forKey: Keys.gamesCount.rawValue),
              let count = try? JSONDecoder().decode(Int.self, from: data) else {return 0}
        return count
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameRecord { //Игровой рекорд
        get {
            guard let data = userDefaults.data(forKey: Keys.bestGame.rawValue),
            let record = try? JSONDecoder().decode(GameRecord.self, from: data) else {
                return .init(correct: 0, total: 0, date: Date())
            }
            
            return record
        }
        set {
            guard let data = try? JSONEncoder().encode(newValue) else {
                print("Невозможно сохранить результат")
                return
            }
            userDefaults.set(data, forKey: Keys.bestGame.rawValue)
        }
    }
    
    
    private let userDefaults = UserDefaults.standard

    
    private enum Keys: String {
        case correct, total, bestGame, gamesCount
    }
    
    
    func store(correct count: Int, total amount: Int) {
        totalAccuracy = Double((count * 100) / amount)
        gamesCount += 1
        let total = Int(totalAccuracy)
        
        let currentGame = GameRecord(correct: count, total: total)
        currentGame.isGameRecord(correct: bestGame.correct) ? bestGame = currentGame : nil
    }
    
}


struct GameRecord: Codable{
    
    func isGameRecord(correct count: Int) -> Bool{
        if self.correct < count{
            return false
        }
        else{
            return true
        }
    }
    
    var correct: Int
    
    var total: Int
    
    var date: Date = Date()
    
    
  
}
