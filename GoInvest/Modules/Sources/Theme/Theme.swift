import UIKit

public enum Theme {

    public enum Fonts {
        public static let button = UIFont.systemFont(ofSize: 19, weight: .semibold)
        public static let title = UIFont.systemFont(ofSize: 19, weight: .bold)
        public static let largeTitle = UIFont.systemFont(ofSize: 39, weight: UIFont.Weight(850))
        public static let extraLargeTitle = UIFont.systemFont(ofSize: 80, weight: UIFont.Weight(850))
        public static let subtitle = UIFont.systemFont(ofSize: 17, weight: .light)
        public static let error = UIFont.systemFont(ofSize: 20, weight: .medium)
    }

    public enum Colors {
        public static let background = UIColor(named: "BackgroundColor")!
        public static let yellow = UIColor(named: "YellowColor")!
        public static let blueAccent = UIColor(named: "BlueColor")
        public static let gray = UIColor(named: "GrayColor")
        public static let button = UIColor(named: "BlackColor")!
        public static let mainText = UIColor(named: "BlackColor")!
        public static let buttonText = UIColor(named: "WhiteColor")!
        public static let buttonHighlightedText = UIColor(white: 1, alpha: 0.5)
        public static let redBackground = UIColor(named: "RedColor")!
        public static let greenBackground = UIColor(named: "GreenColor")!
        public static let labelText = UIColor(named: "WhiteColor")!
        public static let subLabelText = UIColor.gray
        public static let borderColor = UIColor.lightGray
    }

    public enum Images {
        public static let quotesTabBar = UIImage(systemName: "arrow.up.arrow.down")!
        public static let profileTabBarUnchecked = UIImage(systemName: "person")!
        public static let profileTabBarChecked = UIImage(systemName: "person.fill")!
        public static let strategyTabBar = UIImage(systemName: "function")!
        public static let backNavBar = UIImage(systemName: "chevron.left.circle")!
    }

    public enum StyleElements {
        public static let imageCornerRadius: CGFloat = 20
        public static let buttonCornerRadius: CGFloat = 10
        public static let timeIntervalButtonCornerRadius: CGFloat = 18
        public static let skeletonCornerRadius: Float = 10
        public static let skeletonTextCornerRadius: Int = 5
        public static let buttonBorderWidth: CGFloat = 1
        public static let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemMaterial)
    }

    public enum Layout {
        public static let smallSpacing: CGFloat = 10
        public static let bigSpacing: CGFloat = 20
        public static let sideOffset: CGFloat = 20
        public static let topOffset: CGFloat = 10
        public static let buttonHeight: CGFloat = 55
    }

    public enum Animation {
        public static let selectSizeButton: CGFloat = 1.05
    }
}
