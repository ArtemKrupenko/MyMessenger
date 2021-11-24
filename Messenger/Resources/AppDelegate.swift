//
//  AppDelegate.swift
//  Messenger
//
//  Created by Артем on 27.09.2021.
//

import UIKit
import Firebase
import FBSDKCoreKit
import GoogleSignIn

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var signInConfig: GIDConfiguration?
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        FirebaseApp.configure()
        // проверяет, есть ли пользователь в системе и переходит на соответствующий экран (если есть то при запуске приложения вход сразу в экран списка диалогов ConversationsViewController, в остальном случае переходит на экран входа LoginViewController)
        if FirebaseAuth.Auth.auth().currentUser != nil {
            let tabBarViewController = UITabBarController()
            let viewController1 = UINavigationController(rootViewController: ConversationsViewController())
            viewController1.title = "Чаты"
            let viewController2 = UINavigationController(rootViewController: ProfileViewController())
            viewController2.title = "Настройки"
            tabBarViewController.setViewControllers([viewController1, viewController2], animated: false)
            let items = tabBarViewController.tabBar.items
            let images = ["message", "gearshape.2"]
            for x in 0..<items!.count {
                items![x].image = UIImage(systemName: images[x])
            }
            tabBarViewController.modalPresentationStyle = .fullScreen
            window?.rootViewController = tabBarViewController
            window?.makeKeyAndVisible()
        } else if FirebaseAuth.Auth.auth().currentUser == nil {
            window?.rootViewController = LoginViewController()
            window?.makeKeyAndVisible()
        }
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if let user = user, error == nil {
                self?.handleSessionRestore(user: user)
            }
        }
        if let clientId = FirebaseApp.app()?.options.clientID {
            signInConfig = GIDConfiguration.init(clientID: clientId)
        }
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled: Bool
        handled = GIDSignIn.sharedInstance.handle(url)
        if handled {
            return true
        }
        return false
    }

    func handleSessionRestore(user: GIDGoogleUser) {
        guard let email = user.profile?.email,
            let firstName = user.profile?.givenName,
            let lastName = user.profile?.familyName else {
                return
        }
        UserDefaults.standard.set(email, forKey: "email")
        UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
        DatabaseManager.shared.userExists(with: email, completion: { exists in
            if !exists {
                // добавление в базу данных
                let chatUser = ChatAppUser(
                    firstName: firstName,
                    lastName: lastName,
                    emailAddress: email
                )
                DatabaseManager.shared.insertUser(with: chatUser, completion: { success in
                    if success {
                        // загрузка изображения
                        if user.profile?.hasImage == true {
                            guard let url = user.profile?.imageURL(withDimension: 200) else {
                                return
                            }
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, _ in
                                guard let data = data else {
                                    return
                                }
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
                    }
                })
            }
        })
        let authentication = user.authentication
        guard let idToken = authentication.idToken else {
            return
        }
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: authentication.accessToken
        )
        FirebaseAuth.Auth.auth().signIn(with: credential, completion: { authResult, error in
            guard authResult != nil, error == nil else {
                print("не удалось войти в систему с учетными данными Google")
                return
            }
            print("Успешная авторизация с помощью учетной записи Google")
            NotificationCenter.default.post(name: .didLogInNotification, object: nil)
        })
    }
}
