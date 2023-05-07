import AudioToolbox
import Theme
import UIKit

public class RegistrationViewController: UIViewController {
    public var regButtonHandler: ((String, String) -> Void)?
    public var loginButtonHandler: (() -> Void)?
    var isKeyBoardUp = false

    let signUpLabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Theme.Colors.blueAccent
        label.layer.opacity = 0.6
        label.text = "Create\nAccount"
        label.font = Theme.Fonts.extraLargeTitle
        label.numberOfLines = 2
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let imageViewUser = {
        let view = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let image = UIImage(systemName: "person.circle.fill")
        view.contentMode = .scaleAspectFill
        view.image = image
        return view
    }()

    let loginTextField = {
        let textField = UITextField()
        textField.autocapitalizationType = .none
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.backgroundColor = .lightText
        return textField
    }()

    let passwordTextField = {
        let textField = UITextField()
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.backgroundColor = .lightText
        textField.isSecureTextEntry = true
        return textField
    }()

    let glassView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 300, height: 280)
        view.layer.cornerRadius = 30
        view.backgroundColor = UIColor.white.withAlphaComponent(0.0001)
        view.clipsToBounds = true
        view.layer.borderWidth = 2
        view.layer.borderColor = CGColor(red: 238 / 255, green: 238 / 255, blue: 238 / 255, alpha: 0.65)
        return view
    }()

    let animateButton = {
        let button = UIButton()
        button.backgroundColor = Theme.Colors.button
        button.titleLabel?.font = Theme.Fonts.button
        button.setTitleColor(Theme.Colors.buttonHighlightedText, for: .highlighted)
        button.setTitle("Register", for: .normal)
        button.layer.cornerRadius = Theme.StyleElements.buttonCornerRadius
        return button
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

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Theme.Colors.gray
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        loginTextField.delegate = self
        passwordTextField.delegate = self
        setGlassViewSettings()
        setAnimateButtonSettings()
        setImageViewUser()
        setLoginTextField()
        setPasswordTextField()
        setSingUpLabel()
        setGoToLoginButtonSettings()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard !isKeyBoardUp else {return}
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
            NSValue {
            let keyboardHeight = keyboardFrame.cgRectValue.height
            let bottomSpace = self.view.frame.height - (animateButton.frame.origin.y + animateButton.frame.height)
            view.frame.origin.y -= keyboardHeight - bottomSpace + 10
        }
        isKeyBoardUp = true
    }

    @objc func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0 // Move view to original position
        isKeyBoardUp = false
    }

    func setSingUpLabel() {
        view.addSubview(signUpLabel)
        view.sendSubviewToBack(signUpLabel)
        signUpLabel.translatesAutoresizingMaskIntoConstraints = false
        signUpLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        NSLayoutConstraint.activate([
            signUpLabel.topAnchor.constraint(equalTo: glassView.topAnchor, constant: -160),
            signUpLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Theme.Layout.sideOffset),
            signUpLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Theme.Layout.sideOffset),
        ])
    }

    func setImageViewUser() {
        glassView.addSubview(imageViewUser)
        imageViewUser.translatesAutoresizingMaskIntoConstraints = false
        imageViewUser.widthAnchor.constraint(equalToConstant: 100).isActive = true
        imageViewUser.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageViewUser.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageViewUser.topAnchor.constraint(equalTo: glassView.topAnchor, constant: 20).isActive = true
    }

    func setLoginTextField() {
        glassView.addSubview(loginTextField)
        loginTextField.translatesAutoresizingMaskIntoConstraints = false
        loginTextField.centerXAnchor.constraint(equalTo: glassView.centerXAnchor).isActive = true
        loginTextField.widthAnchor.constraint(equalToConstant: 240).isActive = true
        loginTextField.topAnchor.constraint(equalTo: imageViewUser.bottomAnchor, constant: 20).isActive = true
    }

    func setPasswordTextField() {
        glassView.addSubview(passwordTextField)
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.centerXAnchor.constraint(equalTo: glassView.centerXAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalToConstant: 240).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: loginTextField.bottomAnchor, constant: 20).isActive = true
    }

    func setAnimateButtonSettings() {
        view.addSubview(animateButton)
        animateButton.translatesAutoresizingMaskIntoConstraints = false
        animateButton.topAnchor.constraint(equalTo: glassView.bottomAnchor, constant: 20).isActive = true
        animateButton.trailingAnchor.constraint(equalTo: glassView.trailingAnchor).isActive = true
        animateButton.leadingAnchor.constraint(equalTo: glassView.leadingAnchor).isActive = true
        animateButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight).isActive = true
        animateButton.addTarget(self, action: #selector(action), for: .touchUpInside)
    }

    func setGoToLoginButtonSettings() {
        view.addSubview(loginButton)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.topAnchor.constraint(equalTo: animateButton.bottomAnchor, constant: Theme.Layout.smallSpacing).isActive = true
        loginButton.heightAnchor.constraint(equalToConstant: Theme.Layout.buttonHeight).isActive = true
        loginButton.trailingAnchor.constraint(equalTo: glassView.trailingAnchor).isActive = true
        loginButton.leadingAnchor.constraint(equalTo: glassView.leadingAnchor).isActive = true
    }

    @objc func action() {
        if let loginText = loginTextField.text, let passwordText = passwordTextField.text {
            regButtonHandler?(loginText, passwordText)
        }
    }

   public func wrongDataAnimate() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: glassView.center.x - 10, y: glassView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: glassView.center.x + 10, y: glassView.center.y))
        glassView.layer.add(animation, forKey: "position")
    }

    func setGlassViewSettings() {
        glassView.applyBlurEffect()
        view.addSubview(glassView)
        glassView.clipsToBounds = true

        glassView.translatesAutoresizingMaskIntoConstraints = false
        glassView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        glassView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        glassView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        glassView.heightAnchor.constraint(equalToConstant: 280).isActive = true
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        isKeyBoardUp = false
        return true
    } // called when 'return' key pressed. return NO to ignore.
}

extension RegistrationViewController {
    @objc
    private func presentLogin(_ sender: UIButton) {
        loginButtonHandler?()
    }
}
