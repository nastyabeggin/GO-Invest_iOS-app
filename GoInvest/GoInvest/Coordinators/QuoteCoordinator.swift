import DomainModels
import QuoteClient
import QuoteDetail
import UIKit

class QuoteCoordinator {
    private var navigationController: UINavigationController
    private var selectedQuote: Quote
    var removeFromMemory: (() -> Void)?

    init(navigationController: UINavigationController, quote: Quote) {
        self.navigationController = navigationController
        selectedQuote = quote
    }

    func start() {
        let viewController = QuoteDetailViewController(quote: selectedQuote)
        viewController.onViewDidDisappear = { [weak self] in
            self?.removeFromMemory?()
        }
        viewController.showWelcomeView = {[weak self] in
            print("UNAUTH")
        }
        viewController.navigationItem.title = selectedQuote.name
        navigationController.pushViewController(viewController, animated: true)
    }

}
