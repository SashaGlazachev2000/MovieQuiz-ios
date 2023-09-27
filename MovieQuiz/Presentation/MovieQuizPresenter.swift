import UIKit

final class MovieQuizPresenter: QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: Private Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
    
    
    // MARK: Public Properties
    var alertPresenter: AlertPresenter?
    var currentQuestion: QuizQuestion?
    let questionsAmout: Int = 10
    var statisticImplementation: StatisticService?
    
    
    // MARK: Init
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        statisticImplementation = StatisticServiceImplementation()
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        alertPresenter = AlertPresenter(delegate: self, controller: viewController)
        questionFactory?.loadData()
    }
    
    
    // MARK: Private Methods
    private func showNetworkError(message: String) {
        viewController?.hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}
            self.restartGame()
        }
        
        alertPresenter?.show(quiz: model)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else{return}
        
        let givenAnswer = isYes
        
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAwner)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.isEnabledButtons(false)
        viewController?.showBorderResult(isCorrect: isCorrect)
        
        isCorrect ?  correctAnswers += 1 : nil
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.showLadingIndicator()
            self.viewController?.isEnabledButtons(true)
            self.viewController?.isHideBorder()
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        guard let statisticImplementation = statisticImplementation else{return}
        
        if self.isLastQuestion() {
            statisticImplementation.store(correct: correctAnswers, total: questionsAmout)
            
            let text = resultMessage(statistic: statisticImplementation)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз"
            ){ [weak self] in
                guard let self = self else { return }
                self.restartGame()
            }
            alertPresenter?.show(quiz: viewModel)
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmout - 1
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func resultMessage(statistic: StatisticService) -> String {
        var result = "Ваш результат: \(correctAnswers)/\(questionsAmout)\n"
        result += "Количество сыграных квизов: \(statistic.gamesCount)\n"
        result += "Рекорд: \(statistic.bestGame.correct)/\(questionsAmout) (\(statistic.bestGame.date.dateTimeString))\n"
        result += "Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%"
        return result
    }
        
    
    // MARK: Public Methods
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image: UIImage = UIImage(data: model.image) ?? UIImage()
        let res = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questionsAmout)")
        return res
    }
    
    func showNetworkErrorImage(message: String) {
        viewController?.hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else {return}
            self.questionFactory?.requestNextQuestion()
        }
        
        alertPresenter?.show(quiz: model)
    }
    
    func didLoadDataFromServer() {
        viewController?.showLadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else{return}
        
        viewController?.hideLoadingIndicator()
        currentQuestion = question
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
        questionFactory?.loadData()
    }
    
} 
