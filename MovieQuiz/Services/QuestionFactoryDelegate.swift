import Foundation

protocol QuestionFactoryDelegate: AnyObject{
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer()
    func showNetworkErrorImage(message: String)
    func didFailToLoadData(with error: Error)
}
