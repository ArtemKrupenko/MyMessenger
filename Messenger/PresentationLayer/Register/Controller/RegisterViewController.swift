import UIKit
import FirebaseAuth
import JGProgressHUD

final class RegisterViewController: UIViewController {
    
    // MARK: - Properties
    private let spinner = JGProgressHUD(style: .dark)
    public let registerView = RegisterView()
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = registerView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    // MARK: - Functions
    private func setupView() {
        registerView.setupUIElements()
        registerView.backgroundColor = .systemBackground
        registerView.registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        registerView.emailField.delegate = self
        registerView.passwordField.delegate = self
        registerView.scrollView.frame = view.bounds
        registerView.passwordField.rightView = registerView.passwordSecureButton
        registerView.passwordSecureButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        registerView.imageView.isUserInteractionEnabled = true
        registerView.scrollView.isUserInteractionEnabled = true
        registerView.imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTabChangeProfilePic)))
        // скрывает экран клавиатуры при касании
        let gesture = UITapGestureRecognizer(target: registerView, action: #selector(UIView.endEditing(_:)))
        registerView.addGestureRecognizer(gesture)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Создание учетной записи"
    }
    
    // MARK: - Actions
    /// Отображение "глазика" в поле ввода пароля
    @objc private func togglePassword(sender: UIButton) {
        switch registerView.passwordField.isSecureTextEntry {
        case true:
            registerView.passwordField.isSecureTextEntry = false
            registerView.passwordSecureButton.setImage(ImagesSystem.eyeSlash, for: .normal)
        case false:
            registerView.passwordField.isSecureTextEntry = true
            registerView.passwordSecureButton.setImage(ImagesSystem.eye, for: .normal)
        }
    }

    @objc private func didTabChangeProfilePic() {
        presentPhotoActionSheet()
    }

    @objc public func registerButtonTapped() {
        registerView.emailField.resignFirstResponder()
        registerView.passwordField.resignFirstResponder()
        registerView.firstNameField.resignFirstResponder()
        registerView.lastNameField.resignFirstResponder()
        guard let firstName = registerView.firstNameField.text, let lastName = registerView.lastNameField.text, let email = registerView.emailField.text, let password = registerView.passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            alertUserLoginError()
            return
        }
        guard let password = registerView.passwordField.text,
              !password.isEmpty, password.count >= 8 else {
            alertPasswordLoginError()
            return
        }
        spinner.show(in: view)
        // Вход в Firebase
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exists in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            guard !exists else {
                // Пользователь уже существует
                strongSelf.alertUserLoginError(message: "Похоже, что учетная запись пользователя для этого адреса электронной почты уже существует")
                return
            }
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Ошибка при создании пользователя")
                    return
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstName) \(lastName)", forKey: "name")
                let chatUser = ChatAppUser(firstName: firstName,
                                           lastName: lastName,
                                           emailAddress: email)
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        if self?.registerView.imageView.image != ImagesSystem.profileRegister {
                            guard let data = strongSelf.registerView.imageView.image?.pngData() else { return }
                            let filename = chatUser.profilePictureFileName
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                switch result {
                                case let .success(downloadUrl):
                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                    print(downloadUrl)
                                case let .failure(error):
                                    print("Ошибка StorageManager: \(error)")
                                }
                            })
                        } else {
                            guard let data = Images.profilePicture.pngData() else { return }
                            let filename = chatUser.profilePictureFileName
                            StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                switch result {
                                case let .success(downloadUrl):
                                    UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                    print(downloadUrl)
                                case let .failure(error):
                                    print("Ошибка StorageManager: \(error)")
                                }
                            })
                        }
                    }
                })
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                self?.goToChat()
            })
        })
    }

    func alertUserLoginError(message: String  = "Пожалуйста, заполните все поля") {
        let alertController = UIAlertController(title: "Упс!",
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }

    func alertPasswordLoginError() {
        let alertController = UIAlertController(title: "Упс!",
                                                message: "Ваш пароль должен состоять как минимум из 8 символов",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "ОК", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    private func goToChat() {
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
}
