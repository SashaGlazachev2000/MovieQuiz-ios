import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    private let cotroller: UIViewController
    private weak var delegate: AlertPresenterDelegate?
    
    init(delegate: AlertPresenterDelegate, controller: UIViewController) {
        self.delegate = delegate
        self.cotroller = controller
    }
    
    
    
    func show(quiz result: AlertModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title: result.buttonText,
            style: .default) { _ in
                result.completion()
            }
        
        alert.addAction(alertAction)
        cotroller.present(alert, animated: true)
    }
    
}
