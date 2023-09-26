import UIKit

final class MovieQuizPresenter {
    
    let questionsAmout: Int = 10
    private var currentQuestionIndex: Int = .zero
    var currentQuestion: QuizQuestion?
    weak var viewController: MovieQuizViewController?
    
    func yesButtonClicked() {
        guard let currentQuestion = currentQuestion else{return}
        
        let givenAnswer = true
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAwner)
    }
    
    func noButtonClicked() {
        guard let currentQuestion = currentQuestion else{return}
        
        let givenAnswer = false
        
        viewController?.showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAwner)
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmout - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func resultMessage(statistic: StatisticService) -> String {
//        var result = "Ваш результат: \(correctAnswers)/\(questionsAmout)\n"
        var result = "Ваш результат: \(5)/\(questionsAmout)\n"
        result += "Количество сыграных квизов: \(statistic.gamesCount)\n"
        result += "Рекорд: \(statistic.bestGame.correct)/\(questionsAmout) (\(statistic.bestGame.date.dateTimeString))\n"
        result += "Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%"
        return result
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image: UIImage = UIImage(data: model.image) ?? UIImage()
        let res = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questionsAmout)")
        return res
    }
} 
