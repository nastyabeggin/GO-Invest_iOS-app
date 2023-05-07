import Foundation
import UIKit
import Theme

public class WelcomeToLoginView: UIView {
    public var loginButtonHandler: (() -> Void)?
    public var regButtonHandler: (() -> Void)?

    private var buttonsStackView = UIStackView()
    public init() {
        super.init(frame: .zero)
        self.backgroundColor = .green
        self.translatesAutoresizingMaskIntoConstraints = false
        configureStackView()
        setupLayout()
    }

    private lazy var welcomeImage: UIImageView = {
        let image = UIImage(named: "LoginImage")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var welcomeLabel: UILabel = {
       var label = UILabel()
        label.text = "Go-Invest \nStocks & strategy"
        label.font = Theme.Fonts.largeTitle
        label.textAlignment = .left
        label.numberOfLines = 2
        return label
    }()

    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("I already have an account", for: .normal)
        button.backgroundColor = .clear
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.mainText, for: .normal)
        button.setTitleColor(Theme.Colors.buttonHighlightedText, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentLogin(_ :)), for: .touchUpInside)
        return button
    }()

    private lazy var regButton: UIButton = {
        let button = UIButton()
        button.setTitle("Get started", for: .normal)
        button.backgroundColor = Theme.Colors.button
        button.layer.cornerRadius = Theme.StyleElements.buttonCornerRadius
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.buttonText, for: .normal)
        button.setTitleColor(Theme.Colors.buttonHighlightedText, for: .highlighted)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentReg(_ :)), for: .touchUpInside)
        return button
    }()

    func setupLayout() {
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        regButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        welcomeImage.translatesAutoresizingMaskIntoConstraints = false
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(welcomeImage)

        NSLayoutConstraint.activate([
            welcomeImage.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            welcomeImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor, constant: -150),
            buttonsStackView.topAnchor.constraint(equalTo: welcomeImage.bottomAnchor),
            buttonsStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            buttonsStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -Theme.Layout.sideOffset),
            buttonsStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: Theme.Layout.sideOffset),
            loginButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            regButton.widthAnchor.constraint(equalTo: buttonsStackView.widthAnchor),
            regButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight),
            ])
    }

    private func configureStackView() {
        buttonsStackView.axis = .vertical
        buttonsStackView.alignment = .center
        buttonsStackView.distribution = .fillProportionally
        buttonsStackView.spacing = Theme.Layout.smallSpacing
        buttonsStackView.addArrangedSubview(welcomeLabel)
        buttonsStackView.addArrangedSubview(regButton)
        buttonsStackView.addArrangedSubview(loginButton)
        addSubview(buttonsStackView)
    }

    public func layoutWelcomView(superView: UIView) {
        superView.addSubview(self)
        self.backgroundColor = .systemBackground
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.topAnchor),
            self.leadingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: superView.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func presentLogin(_ sender: UIButton) {
        loginButtonHandler?()
    }

    @objc
    private func presentReg(_ sender: UIButton) {
        regButtonHandler?()
    }
}
