//
//  LoginViewController.swift
//  Messenger
//
//  Created by Артем on 27.09.2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import JGProgressHUD

final class LoginViewController: UIViewController {

    private let spinner: JGProgressHUD = {
        let spinner = JGProgressHUD(style: .dark)
        spinner.interactionType = .blockAllTouches
        return spinner
    }()

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emailField: UITextField = {
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

    private let passwordField: UITextField = {
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
    
    private let passwordSecureButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.tintColor = UIColor.lightGray
        return button
    }()

    private let loginButton: UIButton = {
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

    private let loginButtonFacebook: FBLoginButton = {
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

    private let googleLogInButton: GIDSignInButton = {
        let button = GIDSignInButton()
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .center
        return button
    }()
    
    private let registrationButton: UIButton = {
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

    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        emailField.delegate = self
        passwordField.delegate = self
        loginButtonFacebook.delegate = self
        // Добавление subviews
        view.addSubview(scrollView)
        scrollView.addSubview(registrationButton)
        registrationButton.addTarget(self, action: #selector(didTabRegister), for: .touchUpInside)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        passwordField.rightView = passwordSecureButton
        passwordSecureButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        scrollView.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        scrollView.addSubview(loginButtonFacebook)
        scrollView.addSubview(googleLogInButton)
        googleLogInButton.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        // скрывает экран клавиатуры при касании
//        let gesture = UITapGestureRecognizer(target: scrollView, action: #selector(UIScrollView.endEditing(_:)))
//        scrollView.addGestureRecognizer(gesture)
    }

    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        registrationButton.frame = CGRect(x: 250,
                                          y: 20,
                                          width: scrollView.frame.size.width / 3,
                                          height: 52)
        imageView.frame = CGRect(x: (scrollView.frame.size.width - (scrollView.frame.size.width / 3)) / 2,
                                 y: 95,
                                 width: scrollView.frame.size.width / 3,
                                 height: scrollView.frame.size.width / 3)
        emailField.frame = CGRect(x: 30,
                                  y: (imageView.frame.size.height + imageView.frame.origin.y) + 50,
                                  width: scrollView.frame.size.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: (emailField.frame.size.height + emailField.frame.origin.y) + 15,
                                     width: scrollView.frame.size.width - 60,
                                     height: 52)
        passwordSecureButton.frame = CGRect(x: passwordField.frame.size.width - 25,
                                            y: 5,
                                            width: 25,
                                            height: 25)
        loginButton.frame = CGRect(x: 30,
                                   y: (passwordField.frame.size.height + passwordField.frame.origin.y) + 15,
                                   width: scrollView.frame.size.width - 60,
                                   height: 52)
        loginButtonFacebook.frame = CGRect(x: 30,
                                   y: (loginButton.frame.size.height + loginButton.frame.origin.y) + 15,
                                   width: scrollView.frame.size.width - 60,
                                   height: 52)
        googleLogInButton.frame = CGRect(x: 30,
                                   y: (loginButtonFacebook.frame.size.height + loginButtonFacebook.frame.origin.y) + 15,
                                   width: scrollView.frame.size.width - 60,
                                   height: 52)
    }
    
    /// Переход на экран списков диалогов  (ConversationsViewController)
    private func goToChat() {
        let tabBarViewController = UITabBarController()
        let viewController1 = UINavigationController(rootViewController: ConversationsViewController())
        viewController1.title = "Чаты"
        let viewController2 = UINavigationController(rootViewController: SettingsViewController())
        viewController2.title = "Настройки"
        tabBarViewController.setViewControllers([viewController1, viewController2], animated: false)
        guard let items = tabBarViewController.tabBar.items else {
            return
        }
        let images = ["message", "gearshape.2"]
        for x in 0..<items.count {
            items[x].image = UIImage(systemName: images[x])
        }
        tabBarViewController.modalPresentationStyle = .fullScreen
        present(tabBarViewController, animated: false)
    }
    
    /// Отображение "глазика" в поле ввода пароля
    @objc private func togglePassword(sender: UIButton) {
        switch passwordField.isSecureTextEntry {
        case true:
            passwordField.isSecureTextEntry = false
            passwordSecureButton.setImage(UIImage(systemName: "eye.slash.fill"), for: .normal)
        case false:
            passwordField.isSecureTextEntry = true
            passwordSecureButton.setImage(UIImage(systemName: "eye.fill"), for: .normal)
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

    @objc private func loginButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 8 else {
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
        let alert = UIAlertController(title: "Ошибка", message: "Пожалуйста, введите корректные данные для входа в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ОК", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

    /// Переход на экран регистрации (RegisterViewController)
    @objc private func didTabRegister() {
        let viewController = RegisterViewController()
        viewController.title = "Создание учетной записи"
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    func loginButtonFB(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else {
            print("Пользователю не удалось войти в систему с помощью Facebook")
            return
        }
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "Me",
                                                         parameters: ["fields": "email, first_name, last_name, picture.type(large)"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Не удалось выполнить запрос профиля Facebook")
                return
            }
            guard let firstName = result["first_name"] as? String,
                let lastName = result["last_name"] as? String,
                let email = result["email"] as? String,
                let picture = result["picture"] as? [String: Any],
                let data = picture["data"] as? [String: Any],
                let pictureUrl = data["url"] as? String else {
                    print("Не удалось получить электронный адрес и имя из Facebook")
                    return
            }
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
            DatabaseManager.shared.userExists(with: email, completion: { exists in
                if !exists {
                    // Добавление в базу данных
                    let chatUser = ChatAppUser(firstName: firstName,
                                               lastName: lastName,
                                               emailAddress: email)
                    DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                        if success {
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
                                // Загрузка изображения
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
                            }).resume()
                        }
                    })
                }
            })
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                guard let strongSelf = self else {
                    return
                }
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Вход в систему учетных данных Facebook не удался, может потребоваться MFA - \(error)")
                    }
                    return
                }
                print("Успешный вход пользователя в систему")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
                self?.goToChat()
            })
        })
    }
}
