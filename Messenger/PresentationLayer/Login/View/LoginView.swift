import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import JGProgressHUD

class LoginView: UIView {
    
    // MARK: - UI
    public let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.logo
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public let emailField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()

    public let passwordField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Пароль"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        field.isSecureTextEntry = true
        field.rightViewMode = .always
        return field
    }()
    
    public let passwordSecureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(ImagesSystem.eye, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.tintColor = UIColor.lightGray
        return button
    }()

    public let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Войти", for: .normal)
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    public let loginButtonFacebook: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email", "public_profile"]
        button.setTitle("Войти с помощью Facebook", for: .normal)
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    public let googleLogInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    public let registrationButton: UIButton = {
        let button = UIButton()
        button.setTitle("Регистрация", for: .normal)
        button.backgroundColor = .systemBackground
        button.setTitleColor(UIColor(named: "ColorLogo"), for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .regular)
        return button
    }()
    
    // MARK: - Dependencies
    init() {
        super.init(frame: UIScreen.main.bounds)
        setupUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUIElements() {
        addSubview(scrollView)
        scrollView.addSubview(registrationButton)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginButtonFacebook)
        scrollView.addSubview(googleLogInButton)
        passwordField.rightView = passwordSecureButton
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        registrationButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            registrationButton.heightAnchor.constraint(equalToConstant: 52),
            registrationButton.leftAnchor.constraint(equalTo: scrollView.leftAnchor, constant: 270),
            registrationButton.rightAnchor.constraint(equalTo: scrollView.rightAnchor, constant: -10),
            registrationButton.centerYAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -320)
        ])

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.4),
            imageView.heightAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 0.4),
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 70),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        emailField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emailField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            emailField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            emailField.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 50),
            emailField.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        passwordField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            passwordField.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            passwordField.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 20),
            passwordField.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            loginButton.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 20),
            loginButton.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        loginButtonFacebook.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loginButtonFacebook.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            loginButtonFacebook.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            loginButtonFacebook.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            loginButtonFacebook.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        googleLogInButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            googleLogInButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 30),
            googleLogInButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -30),
            googleLogInButton.topAnchor.constraint(equalTo: loginButtonFacebook.bottomAnchor, constant: 20),
            googleLogInButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
