import Foundation
import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject, UIViewController {
    func show(quiz step: QuizStepViewModel)
    func showLadingIndicator()
    func hideLoadingIndicator()
    func showBorderResult(isCorrect: Bool)
    func isHideBorder()
    func isEnabledButtons(_ isEnabled: Bool)
}
