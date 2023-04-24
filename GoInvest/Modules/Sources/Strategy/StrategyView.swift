import UIKit
import Theme

class StrategyView: UIView {var actionForCompute: ((_ amount: Double, _ risk: Int, _ strategy: Int) -> Void)?

    private let amountView: UIView = {
        let textField = UIView()
        textField.layer.borderColor = Constants.buttonBackgroundColor.cgColor
        textField.layer.borderWidth = Constants.defaultBorderWidth
        textField.layer.cornerRadius = Constants.cornerRadius
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let risksView: SegmentedControl = {
        let view = SegmentedControl(
            title: "Risks",
            segmentsTitle: ["😀 Light", "🥰 Medium", "😁 Normal", "😎 Hard"]
        )
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let computeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(computeStrategiesButtonTapped(button: )), for: .touchUpInside)
        button.backgroundColor = Constants.buttonBackgroundColor
        button.layer.cornerRadius = Constants.cornerRadius
        button.setTitle("Compute", for: .normal)
        button.setTitleColor(Constants.buttonTextColor, for: .normal)
        button.titleLabel?.font = Constants.buttonFont
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    init() {
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {

        addSubview(risksView)
        addSubview(computeButton)
    }

    private func setupLayout() {
        NSLayoutConstraint.activate([
            risksView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            risksView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.margin),
            risksView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.margin),
            risksView.heightAnchor.constraint(equalToConstant: 280),
            computeButton.heightAnchor.constraint(equalToConstant: 60),
            computeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.margin),
            computeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Constants.margin),
            computeButton.topAnchor.constraint(equalTo: risksView.bottomAnchor, constant: 50)
        ])
    }
}

extension StrategyView {
    @objc
    private func computeStrategiesButtonTapped(button: UIButton) {
        actionForCompute?(0.0, self.risksView.selectedSegmentIndex, 0)
    }
}

private extension StrategyView {
    struct Constants {
        static let defaultBorderWidth: CGFloat = Theme.StyleElements.buttonBorderWidth
        static let selectBorderWidth: CGFloat = defaultBorderWidth * 2
        static let buttonFont = Theme.Fonts.button
        static let buttonTextColor = Theme.Colors.buttonText
        static let buttonBackgroundColor = Theme.Colors.button
        static let margin: CGFloat = Theme.Layout.sideOffset
        static let cornerRadius: CGFloat = Theme.StyleElements.buttonCornerRadius
        static let selectSize: CGFloat = Theme.Animation.selectSizeButton
    }
}
