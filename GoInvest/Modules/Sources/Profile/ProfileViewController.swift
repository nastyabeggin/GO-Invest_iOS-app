import UIKit
import AppState
import DomainModels
import Theme

enum FavoritesViewState {
    case load
    case error
    case success
}
public class ProfileViewController: UIViewController {
    public var didTapButton: ((Quote) -> Void)?
    public var handleAuth: (() -> Void)?
    private var quotesArrayToShow: [Quote] = []
    private var allQuotesArray: [Quote] = []
    private lazy var tableView = UITableView()
    private lazy var spinner = UIActivityIndicatorView(style: .large)
    private lazy var blurEffect = Theme.StyleElements.blurEffect
    private lazy var blurEffectView = UIVisualEffectView(effect: blurEffect)
    public var client: QuoteListProvider?
    public var toLogin: (() -> Void)?
    public var toReg: (() -> Void)?
    private var welcomeView = WelcomeToLoginView()

    private var viewState: FavoritesViewState? {
        didSet {
            switch viewState {
            case .load:
                configureLoadView()
            case .success:
                removeLoadView()
            case .error:
                print("error occured")
            case .none:
                break
            }
        }
    }

    public init(client: QuoteListProvider) {
        self.client = client

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        welcomeView.loginButtonHandler = toLogin
        welcomeView.regButtonHandler = toReg
        Storage.fetchDataFromStorage()
        configureTitle()
        configureTableView()
        configureWelcomeView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        handleAuth?()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        fetchDataFromNetwork()
        fetchDataFromStorage()
        tableView.reloadData()
    }

    private func configureTitle() {
        navigationController?.navigationBar.isHidden = true
    }

    private func configureWelcomeView() {
        view.addSubview(welcomeView)
        welcomeView.layoutWelcomView(superView: view)
    }

    private func configureTableView() {
        view.addSubview(tableView)
        setTableViewDelegates()
        tableView.rowHeight = 90
        tableView.register(FavoritesCustomCell.self, forCellReuseIdentifier: "FavoritesCustomCell")

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setTableViewDelegates() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        quotesArrayToShow.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoritesCustomCell") as! FavoritesCustomCell
        cell.setData(model: quotesArrayToShow[indexPath.row])
        return cell
    }

    public func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        didTapButton?(quotesArrayToShow[indexPath.row])
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    public func tableView(_ tableView: UITableView,
                          commit editingStyle: UITableViewCell.EditingStyle,
                          forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeQuoteFromStorage(at: indexPath.row)
            fetchDataFromStorage()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    public func refreshVC(with email: String) {
        Storage.currentUserEmail = email
        Storage.getFavQuotesFromStorage()
        Storage.fetchDataFromStorage()
        fetchDataFromNetwork()
        tableView.reloadData()
        if AppState.isAuth {
            welcomeView.isHidden = true
            navigationController?.navigationBar.isHidden = false
            title = "Favorites"
        } else {
            welcomeView.isHidden = false
            navigationController?.navigationBar.isHidden = true
            Storage.freeIds()
            tableView.reloadData()
        }
    }
}

private extension ProfileViewController {
    func fetchDataFromStorage() {
        let favIds = Storage.sharedQuotesIds
        quotesArrayToShow = allQuotesArray.filter({ quote in
            favIds.contains(quote.id)
        })
    }

    func removeQuoteFromStorage(at index: Int) {
        Storage.removeFromStorageByIndex(index)
    }
}

extension ProfileViewController {
    private func fetchDataFromNetwork() {
        viewState = .load
        client?.quoteList(search: .defaultList) { [weak self] result in
            switch result {
            case let .success(array):
                self?.viewState = .success
                self?.allQuotesArray = array

            case .failure:
                return
            }
            self?.fetchDataFromStorage()
            self?.tableView.reloadData()
        }
    }
}

private extension ProfileViewController {
    func configureLoadView() {
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

    func removeLoadView() {
        blurEffectView.removeFromSuperview()
        spinner.removeFromSuperview()
    }
}
