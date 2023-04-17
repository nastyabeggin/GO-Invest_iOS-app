import UIKit
import Theme

public class QuoteDetailViewController: UIViewController {

    private lazy var quoteDetailView: QuoteDetailView = {
        let view = QuoteDetailView()
        return view
    }()

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.background
        view.addSubview(quoteDetailView)
        setupLayout()
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            quoteDetailView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: Theme.Layout.topOffset),
            quoteDetailView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: Theme.Layout.sideOffset),
            quoteDetailView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -Theme.Layout.sideOffset),
            quoteDetailView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
