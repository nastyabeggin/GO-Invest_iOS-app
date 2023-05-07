import DomainModels
import QuoteClient
import QuoteDetail
import Login
import UIKit

class StrategyResultsCoordinator {
    private var navigationController: UINavigationController
    private var selectedQuote: Quote
    private var regVC: RegistrationViewController
    var removeFromMemory: (() -> Void)?
    var childCoordinators = [QuoteCoordinator]()

    init(navigationController: UINavigationController, quote: Quote, regVC: RegistrationViewController) {
        self.navigationController = navigationController
        selectedQuote = quote
        self.regVC = regVC
    }

    func start() {
        let quoteCoordinator = QuoteCoordinator(navigationController: navigationController, quote: selectedQuote, registerVC: regVC)
        childCoordinators.append(quoteCoordinator)
        quoteCoordinator.removeFromMemory = { [weak self] in
            self?.childCoordinators.removeLast()
        }
        quoteCoordinator.start()
    }

}
