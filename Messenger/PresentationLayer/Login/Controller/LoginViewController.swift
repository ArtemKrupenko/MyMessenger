import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    // MARK: - Properties
    public let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        spinner.interactionType = .blockAllTouches
        return spinner
    }()
    
    private var loginObserver: NSObjectProtocol?
    
    public let loginView = LoginView()
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Functions
    private func setupView() {
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
                
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        loginView.setupUIElements()
        loginView.scrollView.frame = view.bounds
        loginView.backgroundColor = .systemBackground
        loginView.emailField.delegate = self
        loginView.passwordField.delegate = self
        loginView.loginButtonFacebook.delegate = self
        loginView.registrationButton.addTarget(self, action: #selector(didTabRegister), for: .touchUpInside)
        loginView.passwordSecureButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        loginView.loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginView.googleLogInButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
    }

    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    /// Переход на экран списков диалогов  (ConversationsViewController)
    public func goToChat() {
        let tabBarViewController = UITabBarController()
        let viewController1 = UINavigationController(rootViewController: ConversationsViewController())
        viewController1.title = "Чаты"
        let viewController2 = UINavigationController(rootViewController: BrowserViewController())
        viewController2.title = "Браузер"
        let viewController3 = UINavigationController(rootViewController: SettingsViewController())
        viewController3.title = "Настройки"
        tabBarViewController.setViewControllers([viewController1, viewController2, viewController3], animated: false)
        guard let items = tabBarViewController.tabBar.items else {
            return
        }
        let images = ["message", "globe", "gearshape.2"]
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: false)
    }
    
    /// Отображение "глазика" в поле ввода пароля
    @objc private func togglePassword(sender: UIButton) {
        switch loginView.passwordField.isSecureTextEntry {
        case true:
            loginView.passwordField.isSecureTextEntry = false
            loginView.passwordSecureButton.setImage(ImagesSystem.eyeSlash, for: .normal)
        case false:
            loginView.passwordField.isSecureTextEntry = true
            loginView.passwordSecureButton.setImage(ImagesSystem.eye, for: .normal)
        }
    }

    @objc private func googleSignInButtonTapped() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate,
              let signInConfig = appDelegate.signInConfig else {
            return
        }
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
            guard let user = user, error == nil else { return }
            appDelegate.handleSessionRestore(user: user)
            self.goToChat()
        }
    }

    @objc public func loginButtonTapped() {
        loginView.emailField.resignFirstResponder()
        loginView.passwordField.resignFirstResponder()
        guard let email = loginView.emailField.text, let password = loginView.passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
            alertUserLoginError()
            return
        }
        spinner.show(in: view)
        // Вход в Firebase
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard let result = authResult, error == nil else {
                print("Не удалось войти в систему пользователю с электронной почтой: \(email)")
                return
            }
            let user = result.user
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { result in
                switch result {
                case let .success(data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                case let .failure(error):
                    print("Ошибка при чтении данных: \(error)")
                }
            })
            UserDefaults.standard.set(email, forKey: "email")
            print("Зарегистрированный пользователь: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            strongSelf.goToChat()
        })
    }

    private func alertUserLoginError() {
        let alertController = UIAlertController(title: "Ошибка",
                                                message: "Пожалуйста, введите корректные данные для входа в систему",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    /// Переход на экран регистрации (RegisterViewController)
    @objc private func didTabRegister() {
        let viewController = RegisterViewController()
        viewController.title = "Создание учетной записи"
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}
