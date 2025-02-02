import QuoteClient
import Profile
import Strategy
import Quotes
import DomainModels
import Theme
import UIKit
import QuoteListModel
import Login
import AppState
import FirebaseAuth

class TabBarCoordinator {
    var tabBarController: UITabBarController
    var childCoordinators = [QuoteCoordinator]()
    let profileVC = ProfileViewController(client: QuoteClient())
    let regVC = RegistrationViewController()
    let loginVC = LoginViewController()

    required init(_ tabBarController: UITabBarController) {
        self.tabBarController = tabBarController
    }

    func start() {
        let modelQuoteList = ListQuoteModel(client: QuoteClient())
        let strategyVC = StrategyViewController(modelQuoteList: modelQuoteList)
        let quotesVC = QuotesViewController(modelQuoteList: modelQuoteList)
        let strategyResultsVC = StrategyResultsViewController()

        let quotesNC = UINavigationController(rootViewController: quotesVC)
        let profileNC = UINavigationController(rootViewController: profileVC)
        let strategyNC = UINavigationController(rootViewController: strategyVC)
        let resultsNC = UINavigationController(rootViewController: strategyResultsVC)

        configureLogOutButton()
        turnOffLogOutButton()
        if let curUser = Auth.auth().currentUser {
            AppState.isAuth = true
            profileVC.refreshVC(with: curUser.email!)
            turnOnLogOutButton()
        }

        profileVC.toLogin = { [weak self] in
            self?.loginVC.modalPresentationStyle = .popover
            self?.loginVC.loginButtonHandler = { [weak self] email, password in
                Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let strongSelf = self else { return }
                    if authResult != nil {
                        self?.loginVC.dismiss(animated: true)
                        AppState.isAuth = true
                        self?.profileVC.refreshVC(with: email)
                        self?.turnOnLogOutButton()
                    } else {
                        self?.loginVC.wrongDataAnimate()
                    }
                }
            }
            self?.profileVC.present(self!.loginVC, animated: true, completion: nil)
        }

        profileVC.toReg = { [weak self] in
            self?.regVC.modalPresentationStyle = .popover
            self!.regVC.regButtonHandler = { [weak self] email, password in
                Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
                    guard let strongSelf = self else { return }
                    if authResult != nil {
                        self?.regVC.dismiss(animated: true)
                        AppState.isAuth = true
                        self?.turnOnLogOutButton()
                        self?.profileVC.refreshVC(with: email)
                    } else {
                        self?.regVC.wrongDataAnimate()
                    }
                }
            }
            self!.profileVC.present(self!.regVC, animated: true, completion: nil)
        }

        quotesVC.didTapButton = { [weak self] quote in
            self?.showQuoteController(with: quote, navigationController: quotesNC)
        }
        profileVC.didTapButton = { [weak self] quote in
            self?.showQuoteController(with: quote, navigationController: profileNC)
        }
        strategyResultsVC.toQuoteTapped = { [weak self] quote in
            self?.showStrategyResults(navigationController: resultsNC, quote: quote)
        }

        strategyVC.performToResultsSegue = { [weak self] quotes, amounts in
            strategyResultsVC.quotesSuggested = quotes
            strategyResultsVC.amountsToSpendSuggested = amounts
            strategyResultsVC.modalPresentationStyle = .popover
            strategyVC.present(resultsNC, animated: true, completion: nil)
        }

        regVC.loginButtonHandler = { [weak self] in
            self?.loginVC.modalPresentationStyle = .popover
            self?.regVC.dismiss(animated: true, completion: { () -> Void in self?.tabBarController.selectedViewController?.present(self!.loginVC, animated: true, completion: nil) })
        }
        loginVC.regButtonHandler = { [weak self] in
            self?.regVC.modalPresentationStyle = .popover
            self?.loginVC.dismiss(animated: true, completion: { () -> Void in self?.tabBarController.selectedViewController?.present(self!.regVC, animated: true, completion: nil) })
        }

        quotesNC.tabBarItem = UITabBarItem(title: "Quotes", image: Theme.Images.quotesTabBar, tag: 0)
        strategyNC.tabBarItem = UITabBarItem(title: "Strategy", image: Theme.Images.strategyTabBar, tag: 1)
        profileNC.tabBarItem = UITabBarItem(title: "Profile", image: Theme.Images.profileTabBarUnchecked, tag: 2)
        profileNC.tabBarItem.selectedImage = Theme.Images.profileTabBarChecked

        let controllers = [quotesNC, strategyNC, profileNC]

        controllers.forEach { $0.navigationBar.prefersLargeTitles = true }

        prepareTabBarController(withTabControllers: controllers)
    }

    private func prepareTabBarController(withTabControllers tabControllers: [UIViewController]) {
        tabBarController.tabBar.isTranslucent = false
        tabBarController.tabBar.backgroundColor = .white
        tabBarController.setViewControllers(tabControllers, animated: true)
    }

    private func showQuoteController(with quote: Quote, navigationController: UINavigationController) {
        let quoteCoordinator = QuoteCoordinator(navigationController: navigationController, quote: quote, registerVC: regVC)
        childCoordinators.append(quoteCoordinator)
        quoteCoordinator.removeFromMemory = { [weak self] in
            if (self?.childCoordinators.isEmpty) == false {
                self?.childCoordinators.removeLast()
            }
        }
        quoteCoordinator.start()
    }

    @objc private func didTapSignOut() throws {
        try! Auth.auth().signOut()
        AppState.isAuth = false
        profileVC.navigationItem.rightBarButtonItem?.isHidden = true
        profileVC.refreshVC(with: "")
    }

    private func showStrategyResults(navigationController: UINavigationController, quote: Quote) {
        let strategyResults = StrategyResultsCoordinator(navigationController: navigationController, quote: quote, regVC: regVC)
        strategyResults.start()
    }

    private func configureLogOutButton() {
        profileVC.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sign out", style: .done, target: self, action: #selector(self.didTapSignOut))
        profileVC.navigationItem.rightBarButtonItem?.tintColor = Theme.Colors.mainText
    }

    private func turnOffLogOutButton() {
        profileVC.navigationItem.rightBarButtonItem?.isHidden = true
    }

    private func turnOnLogOutButton() {
        profileVC.navigationItem.rightBarButtonItem?.isHidden = false
    }

    private func assignButtonCallbacks() {

    }
}
