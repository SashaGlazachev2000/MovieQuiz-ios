import UIKit

final class MovieQuizViewController: UIViewController {
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            corretAner: false),
    ]
    
    private var currentQuestionIndex = 0
    private var сorrectAnswers = 0
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        let correctAner: Bool = questions[currentQuestionIndex].corretAner
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == correctAner)
        
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        let correctAner: Bool = questions[currentQuestionIndex].corretAner
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == correctAner)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        show(quiz: convert(model: questions[currentQuestionIndex]))
        
    }
    
    private func show(quiz step: QuizStepViewModel){
        counterLabel.text = step.questionNumber
        imageView.image = step.image
        textLabel.text = step.question
    }
    
    private func show(quiz result: QuizResultsViewModel){
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: result.buttonText,
            style: .default){_ in
                self.restartGame()
            }
        
        alert.addAction(alertAction)
        
        self.present(alert, animated: true)
    }
    
    private func showAnswerResult(isCorrect: Bool){
        yesButton.isEnabled = false
        noButton.isEnabled = false
        
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        
        isCorrect ? сorrectAnswers += 1 : nil
        
        // запускаем задачу через 1 секунду c помощью диспетчера задач
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // код, который мы хотим вызвать через 1 секунду
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
        
    }
    
    private func showNextQuestionOrResults(){
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questions.count - 1{
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: "Ваш результат: \(сorrectAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        }else {
            currentQuestionIndex += 1
            show(quiz: convert(model: questions[currentQuestionIndex]))
        }
    }
    
    private func restartGame(){
        currentQuestionIndex = 0
        сorrectAnswers = 0
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: firstQuestion)
        show(quiz:viewModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        let image: UIImage = UIImage(named: model.image) ?? UIImage()
        let res = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questions.count)")
        return res
    }
}

struct QuizQuestion{
    let image: String
    let text: String
    let corretAner: Bool
}

struct QuizResultsViewModel{
    let title: String
    let text: String
    let buttonText: String
}

struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}
