import Foundation

protocol StatisticService{
    func store(correct count: Int, total amount: Int)
    var totalAccuracy: Double { get }
    var gamesCount: Int { get }
    var bestGame: GameRecord { get }
}

final class StatisticServiceImplementation: StatisticService{
    
    private var correct: Int { //Правильные ответы
        get {
            userDefaults.integer(forKey: Keys.correct.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.correct.rawValue)
        }
    }
    
    private var total: Int { //Кол-во вопросов
        get {
            userDefaults.integer(forKey: Keys.total.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.total.rawValue)
        }
    }
    
    var totalAccuracy: Double { //Средний результат
        Double(correct) / Double(total) * 100
    }
    
    var gamesCount: Int { //Колличество игр
        get {
            userDefaults.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.gamesCount.rawValue)
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
        self.correct = count
        self.total = amount

        gamesCount += 1
        let total = Int(totalAccuracy)
        
        let currentGame = GameRecord(correct: count, total: total)
        currentGame.isGameRecord(correct: bestGame.correct) ? bestGame = currentGame : nil
    }
    
}
