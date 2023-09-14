import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate{
    
    // MARK: - IB Outlets
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private let questionsAmout: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    private var alertPresenter: AlertPresenter?
    private var statisticImplementation: StatisticService?
    private var currentQuestionIndex: Int = .zero
    private var correctAnswers: Int = .zero
   
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        questionFactory = QuestionFactory(delegate: self)
        alertPresenter = AlertPresenter(delegate: self, controller: self)
        statisticImplementation = StatisticServiceImplementation()
        
        questionFactory?.requestNextQuestion()
    }
    
    
    // MARK: - IB Actions
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAwner)
    }
    
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAwner)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else{return}
        
        currentQuestion = question
        
        let viewModel = convert(model: question)
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    // MARK: - Public Methods
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        questionFactory?.requestNextQuestion()
    }

    
    // MARK: - Private Methods
    private func show(quiz step: QuizStepViewModel) {
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func showLadingIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true
        activityIndicator.startAnimating()
    }
    
    
    private func showNetworkError(message: String) {
        hideLoadingIndicator()
        
        let model = AlertModel(title: "Ошибка",
                                   message: message,
                                   buttonText: "Попробовать еще раз") { [weak self] in
            guard let self = self else { return }
            
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            
            self.questionFactory?.requestNextQuestion()
        }
            
            alertPresenter?.show(quiz: model)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        isCorrect ? correctAnswers += 1 : nil
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0
        
        guard let statisticImplementation = statisticImplementation else{return}
        
        if currentQuestionIndex == questionsAmout - 1 {
            statisticImplementation.store(correct: correctAnswers, total: questionsAmout)
            let text = resultMessage(statistic: statisticImplementation)
            let viewModel = AlertModel(
                title: "Этот раунд окончен!",
                message: text,
                buttonText: "Сыграть еще раз"
            ){ [weak self] in
                    guard let self = self else { return }
                    restartGame()
                }
            alertPresenter?.show(quiz: viewModel)
        } else {
//            showNetworkError(message: "asdasd")
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func resultMessage(statistic: StatisticService) -> String {
        var result = "Ваш результат: \(correctAnswers)/\(questionsAmout)\n"
        result += "Количество сыграных квизов: \(statistic.gamesCount)\n"
        result += "Рекорд: \(statistic.bestGame.correct)/\(questionsAmout) (\(statistic.bestGame.date.dateTimeString))\n"
        result += "Средняя точность: \(String(format: "%.2f", statistic.totalAccuracy))%"
        return result
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image: UIImage = UIImage(named: model.image) ?? UIImage()
        let res = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questionsAmout)")
        return res
    }
}
