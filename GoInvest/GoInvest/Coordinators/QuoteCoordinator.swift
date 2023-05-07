import DomainModels
import QuoteClient
import QuoteDetail
import Login
import UIKit

class QuoteCoordinator {
    private var navigationController: UINavigationController
    private var selectedQuote: Quote
    private var registerVC: RegistrationViewController
    var removeFromMemory: (() -> Void)?

    init(navigationController: UINavigationController, quote: Quote, registerVC: RegistrationViewController) {
        self.navigationController = navigationController
        selectedQuote = quote
        self.registerVC = registerVC
    }

    func start() {
        let viewController = QuoteDetailViewController(quote: selectedQuote)
        viewController.onViewDidDisappear = { [weak self] in
            self?.removeFromMemory?()
        }
        registerVC.modalPresentationStyle = .popover
        viewController.showWelcomeView = {
            viewController.present(self.registerVC, animated: true, completion: nil)
        }
        viewController.navigationItem.title = selectedQuote.name
        navigationController.pushViewController(viewController, animated: true)
    }

}
