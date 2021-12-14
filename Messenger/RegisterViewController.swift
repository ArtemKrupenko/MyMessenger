//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Артем on 27.09.2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class RegisterViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = ImagesSystem.profileRegister
        imageView.tintColor = UIColor(named: "ColorLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let firstNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Имя"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
    }()

    private let lastNameField: UITextField = {
        let field = UITextField()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Фамилия"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
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
        button.setImage(ImagesSystem.eye, for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: 0)
        button.tintColor = UIColor.lightGray
        return button
    }()

    private let registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Регистрация", for: .normal)
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Создание учетной записи"
        view.backgroundColor = .systemBackground
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        // добавление subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        passwordField.rightView = passwordSecureButton
        passwordSecureButton.addTarget(self, action: #selector(togglePassword), for: .touchUpInside)
        scrollView.addSubview(registerButton)
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTabChangeProfilePic)))
        // скрывает экран клавиатуры при касании
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gesture)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        imageView.frame = CGRect(x: (scrollView.frame.size.width - (scrollView.frame.size.width / 3)) / 2,
                                 y: 20,
                                 width: scrollView.frame.size.width / 3,
                                 height: scrollView.frame.size.width / 3)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        firstNameField.frame = CGRect(x: 30,
                                      y: (imageView.frame.size.height + imageView.frame.origin.y) + 15,
                                      width: scrollView.frame.size.width - 60,
                                      height: 52)
        lastNameField.frame = CGRect(x: 30,
                                     y: (firstNameField.frame.size.height + firstNameField.frame.origin.y) + 15,
                                     width: scrollView.frame.size.width - 60,
                                     height: 52)
        emailField.frame = CGRect(x: 30,
                                  y: (lastNameField.frame.size.height + lastNameField.frame.origin.y) + 15,
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
        registerButton.frame = CGRect(x: 30,
                                      y: (passwordField.frame.size.height + passwordField.frame.origin.y) + 15,
                                      width: scrollView.frame.size.width - 60,
                                      height: 52)
    }
    
    /// Отображение "глазика" в поле ввода пароля
    @objc private func togglePassword(sender: UIButton) {
        switch passwordField.isSecureTextEntry {
        case true:
            passwordField.isSecureTextEntry = false
            passwordSecureButton.setImage(ImagesSystem.eyeSlash, for: .normal)
        case false:
            passwordField.isSecureTextEntry = true
            passwordSecureButton.setImage(ImagesSystem.eye, for: .normal)
        }
    }

    @objc private func didTabChangeProfilePic() {
        presentPhotoActionSheet()
    }

    @objc private func registerButtonTapped() {
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        guard let firstName = firstNameField.text, let lastName = lastNameField.text, let email = emailField.text, let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty else {
            alertUserLoginError()
            return
        }
        guard let password = passwordField.text,
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
                        if self?.imageView.image != ImagesSystem.profileRegister {
                            guard let data = strongSelf.imageView.image?.pngData() else { return }
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
}

extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            registerButtonTapped()
        }
        return true
    }
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cделать фото", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать фото", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        present(actionSheet, animated: true)
    }

    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        } else {
            let alertController = UIAlertController(title: "Внимание!",
                                                    message: "Камера отсутствует",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }

    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = selectedImage
        self.imageView.layer.masksToBounds = true
        self.imageView.layer.borderWidth = 2
        self.imageView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}