import DomainModels
import UIKit

final class SuggestedQuoteCustomCell: UITableViewCell {
    private let shortNameLabel = UILabel()
    private let fullNameLabel = UILabel()
    private let priceLabel = UILabel()
    private let diffPriceLabel = UILabel()
    private let diffPercentLabel = UILabel()
    private let namesStackView = UIStackView()
    private let leadingStackView = UIStackView()
    private let amountToSpend = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureStacks()
        configureShortNameLabel()
        configureFullNameLabel()
        configurePriceLabel()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureStacks() {
        configureNamesStackView()
        configureNamePriceStackView()
    }

    private func configureStackView(stackView: UIStackView,
                                    axis: NSLayoutConstraint.Axis,
                                    aligment: UIStackView.Alignment,
                                    distribution: UIStackView.Distribution,
                                    spacing: CGFloat,
                                    viewsArray: [UIView],
                                    isInContentView: Bool) {
        stackView.axis = axis
        stackView.alignment = aligment
        stackView.distribution = distribution
        stackView.spacing = spacing
        viewsArray.forEach { stackView.addArrangedSubview($0) }
        if isInContentView {
            contentView.addSubview(stackView) }
        }

    private func configureNamesStackView() {
        configureStackView(stackView: namesStackView,
                           axis: .vertical,
                           aligment: .fill,
                           distribution: .fill,
                           spacing: 10,
                           viewsArray: [shortNameLabel, fullNameLabel],
                           isInContentView: false)
    }

    private func configureNamePriceStackView() {
        configureStackView(stackView: leadingStackView,
                           axis: .horizontal,
                           aligment: .fill,
                           distribution: .fill,
                           spacing: 0,
                           viewsArray: [namesStackView, priceLabel],
                           isInContentView: true)

        leadingStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingStackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            leadingStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            leadingStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
        setPrioriries()
    }

    private func setPrioriries() {
        shortNameLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh,
                                                               for: .horizontal)
        fullNameLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow,
                                                              for: .horizontal)
    }

    private func configureShortNameLabel() {
        shortNameLabel.numberOfLines = 1
        shortNameLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
    }

    private func configureFullNameLabel() {
        fullNameLabel.numberOfLines = 1
        fullNameLabel.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        fullNameLabel.textColor = .gray
    }

    private func configurePriceLabel() {
        priceLabel.numberOfLines = 1
        priceLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
        priceLabel.textAlignment = .right
    }

    func setData(model: Quote, amount: Double) {
        shortNameLabel.text = model.id
        fullNameLabel.text = model.name
        priceLabel.text = String(NSString(format: "%.2f", amount * 100)) + "%"
    }
}

extension Decimal {
    func rounded(_ scale: Int, _ roundingMode: NSDecimalNumber.RoundingMode) -> Decimal {
        var result = Decimal()
        var localCopy = self
        NSDecimalRound(&result, &localCopy, scale, roundingMode)
        return result
    }
}
