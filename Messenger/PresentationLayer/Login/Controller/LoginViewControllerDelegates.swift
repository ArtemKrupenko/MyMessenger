import UIKit
import FirebaseAuth
import FBSDKLoginKit
import FBSDKCoreKit
import GoogleSignIn
import JGProgressHUD

// MARK: - TextField
extension LoginViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == loginView.emailField {
            loginView.passwordField.becomeFirstResponder()
        } else if textField == loginView.passwordField {
            loginButtonTapped()
        }
        return true
    }
}

// MARK: - LoginButton
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
            UserDefaults.standard.set(email, forKey: UserDefaultsKeys.email.rawValue)
            UserDefaults.standard.set("\(firstName) \(lastName)", forKey: UserDefaultsKeys.name.rawValue)
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
                                        UserDefaults.standard.set(downloadUrl, forKey: UserDefaultsKeys.profile_picture_url.rawValue)
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
