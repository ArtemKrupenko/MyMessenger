import UIKit
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage
import SwiftUI

/// Контроллер, отображающий список настроек
final class SettingsViewController: UIViewController {
    
    // MARK: - Properties
    private let settingsView = SettingsView()
    
    var data = [Section]()
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = settingsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Functions
    private func setupView() {
        settingsView.setupUIElements()
        // удаление NavigationBar в SettingsViewController
        navigationController?.setNavigationBarHidden(true, animated: false)
        settingsView.tableView.delegate = self
        settingsView.tableView.dataSource = self
        settingsView.tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: Identifiers.settingsTableViewCell)
        settingsSections()
        settingsView.buttonOut.addTarget(self, action: #selector(logout), for: .touchUpInside)
    }

    public func settingsSections() {
        data.append(Section(title: "", options: [
            SettingViewModel(viewModelType: .info, title: "Учетная запись", icon: ImagesSystem.key, iconBackgroundColor: .systemBlue, handler: nil),
            SettingViewModel(viewModelType: .info, title: "Избранное", icon: ImagesSystem.star, iconBackgroundColor: .systemPink, handler: nil),
            SettingViewModel(viewModelType: .info, title: "Чаты", icon: ImagesSystem.ellipsis, iconBackgroundColor: .systemTeal, handler: nil)
        ]))
        data.append(Section(title: "", options: [
            SettingViewModel(viewModelType: .info, title: "Уведомления и звуки", icon: ImagesSystem.bell, iconBackgroundColor: .systemRed, handler: nil),
            SettingViewModel(viewModelType: .info, title: "Данные и память", icon: ImagesSystem.folder, iconBackgroundColor: .systemGreen, handler: nil),
            SettingViewModel(viewModelType: .info, title: "Оформление", icon: ImagesSystem.paintpalette, iconBackgroundColor: .systemIndigo, handler: nil),
            SettingViewModel(viewModelType: .info, title: "Стикеры", icon: ImagesSystem.smile, iconBackgroundColor: .systemYellow, handler: nil)
        ]))
        data.append(Section(title: "", options: [
            SettingViewModel(viewModelType: .info, title: "Помощь", icon: ImagesSystem.help, iconBackgroundColor: .systemOrange, handler: nil),
            SettingViewModel(viewModelType: .info, title: "О программе", icon: ImagesSystem.info, iconBackgroundColor: .systemGray2, handler: nil)
        ]))
    }

    @objc func logout() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Выход из учетной записи",
                                            style: .destructive,
                                            handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            UserDefaults.standard.setValue(nil, forKey: "email")
            UserDefaults.standard.setValue(nil, forKey: "name")
            // Выход из Facebook
            FBSDKLoginKit.LoginManager().logOut()
            self?.loginButtonDidLogOut(FBLoginButton.init())
            // Выход из Google
            GIDSignIn.sharedInstance.signOut()
            
            // TODO: - Код в разработке (при выходе из учетной записи не удаляет данные предыдущего пользователя)
            guard let user = FirebaseAuth.Auth.auth().currentUser else { return }
            let onlineRef = Database.database().reference(withPath: "\(user.uid)")
            onlineRef.removeValue { error, _ in
                do {
                    try FirebaseAuth.Auth.auth().signOut()
                    onlineRef.onDisconnectRemoveValue()
                    let defaults = UserDefaults.standard
                    defaults.removeObject(forKey: "email")
                    defaults.removeObject(forKey: "name")
                    let viewController = LoginViewController()
                    let navigationController = UINavigationController(rootViewController: viewController)
                    // удаление NavigationBar в LoginViewController
                    navigationController.setNavigationBarHidden(true, animated: false)
                    navigationController.modalPresentationStyle = .fullScreen
                    strongSelf.present(navigationController, animated: true)
                } catch let error {
                    print("Не удалось выйти из системы авторизации: \(error)")
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
    }
    
    struct ViewControllerProvider: PreviewProvider {
        static var previews: some View {
            ContainerView().edgesIgnoringSafeArea(.all)
        }
        
        struct ContainerView: UIViewControllerRepresentable {
            let viewController = SettingsViewController()
            // заменить ViewController() на свой ViewController
            func makeUIViewController(context: Context) -> some UIViewController {
                return viewController
            }
            
            func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
            }
        }
    }
}
