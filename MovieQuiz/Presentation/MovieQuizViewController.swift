import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    private let questionsAmout: Int = 10
    private var questionFactory: QuestionFactoryProtocol?
    private var currentQuestion: QuizQuestion?
    
    private var currentQuestionIndex = 0
    private var сorrectAnswers = 0
    
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var imageView: UIImageView!
    
    @IBAction private func yesButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = true
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAner)
         
    }
    @IBAction private func noButtonClicked(_ sender: Any) {
        guard let currentQuestion = currentQuestion else{return}
        let givenAnswer = false
        showAnswerResult(isCorrect: givenAnswer == currentQuestion.corretAner)
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFactory = QuestionFactory(delegate: self)
        
        questionFactory?.requestNextQuestion()
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
            style: .default){ [weak self] _ in
                guard let self = self else { return }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            // код, который мы хотим вызвать через 1 секунду
            self.yesButton.isEnabled = true
            self.noButton.isEnabled = true
            self.showNextQuestionOrResults()
        }
    }
    
    private func showNextQuestionOrResults(){
        imageView.layer.borderWidth = 0
        
        if currentQuestionIndex == questionsAmout - 1{
            
            let text = сorrectAnswers  == questionsAmout ?
                        "Поздравляем, Вы ответили на 10 из 10!" :
                        "Вы ответили на \(сorrectAnswers) из 10, попробуйте ещё раз!"
            
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        }else {
            currentQuestionIndex += 1
            self.questionFactory?.requestNextQuestion()
        }
    }
    
    private func restartGame(){
        currentQuestionIndex = 0
        сorrectAnswers = 0
        questionFactory?.requestNextQuestion()
    
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel{
        let image: UIImage = UIImage(named: model.image) ?? UIImage()
        let res = QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: "\(self.currentQuestionIndex + 1)/\(questionsAmout)")
        return res
    }
}





