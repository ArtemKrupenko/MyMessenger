//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Артем on 27.09.2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn
import SDWebImage

final class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    var data = [ProfileViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        data.append(ProfileViewModel(viewModelType: .info, title: "\(UserDefaults.standard.value(forKey: "name") as? String ?? "Нет результатов")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .info, title: "\(UserDefaults.standard.value(forKey: "email") as? String ?? "Нет результатов")", handler: nil))
        data.append(ProfileViewModel(viewModelType: .logout, title: "Выход", handler: { [weak self] in
            guard let strongSelf = self else {
                return
            }
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
                                                    // Выход из Google
                                                    GIDSignIn.sharedInstance.signOut()
                                                    do {
                                                        try FirebaseAuth.Auth.auth().signOut()
                                                        let viewController = LoginViewController()
                                                        let navigationController = UINavigationController(rootViewController: viewController)
                                                        navigationController.modalPresentationStyle = .fullScreen
                                                        strongSelf.present(navigationController, animated: true)
                                                    }
                                                    catch {
                                                        print("Не удалось выйти из системы")
                                                    }
            }))
            actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
            strongSelf.present(actionSheet, animated: true)
            
        }))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        let headerView = UIView(frame: CGRect(x: 0,
                                        y: 0,
                                        width: self.view.width,
                                        height: 200))
        headerView.backgroundColor = UIColor(named: "ColorLogo")
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150)/2,
                                                  y: 25,
                                                  width: 150,
                                                  height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.width/2
        headerView.addSubview(imageView)
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case let .success(url):
                imageView.sd_setImage(with: url, completed: nil)
            case let .failure(error):
                print("Не удается получить URL-адрес: \(error)")
            }
        })
        return headerView
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as! ProfileTableViewCell
        cell.setUp(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.row].handler?()
    }
}

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"

    public func setUp(with viewModel: ProfileViewModel) {
        textLabel?.text = viewModel.title
        switch viewModel.viewModelType {
        case .info:
            textLabel?.textAlignment = .left
            selectionStyle = .none
        case .logout:
            textLabel?.textColor = .red
            textLabel?.textAlignment = .center
        }
    }
}
