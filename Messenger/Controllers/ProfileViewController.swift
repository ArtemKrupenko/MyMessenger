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
    
    @IBOutlet var tableView: UITableView! = UITableView(frame: .zero, style: .insetGrouped)
    
    private var headerView: UIView = {
        let headerView = UIView()
        return headerView
    }()
    
    private var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()
    
    private var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.text = "\(UserDefaults.standard.value(forKey: "name") as? String ?? "Нет результатов")"
        label.textAlignment = .center
        return label
    }()
    
    private var userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.text = "\(UserDefaults.standard.value(forKey: "email") as? String ?? "Нет результатов")"
        label.textAlignment = .center
        return label
    }()
    
    var data = [Section]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        // удаление NavigationBar
        navigationController?.setNavigationBarHidden(true, animated: false)
        // добавление subviews
        view.addSubview(tableView)
        tableView.addSubview(headerView)
        headerView.addSubview(imageView)
        headerView.addSubview(userNameLabel)
        headerView.addSubview(userEmailLabel)
        tableView.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.identifier)
        tableView.tableHeaderView = createTableHeader()
        settingsSections()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        headerView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: self.view.width,
                                  height: 200)
        imageView.frame = CGRect(x: (headerView.width-100) / 2,
                                 y: 20,
                                 width: 100,
                                 height: 100)
        userNameLabel.frame = CGRect(x: 0,
                                  y: imageView.bottom+10,
                                  width: tableView.width,
                                  height: 30)
        userEmailLabel.frame = CGRect(x: 0,
                                     y: userNameLabel.bottom+10,
                                     width: tableView.width,
                                     height: 20)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // удаление NavigationBar
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    public func settingsSections() {
        data.append(Section(title: "", options: [
            ProfileViewModel(viewModelType: .info, title: "Учетная запись", icon: UIImage(systemName: "key.fill"), iconBackgroundColor: .systemBlue, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "Избранное", icon: UIImage(systemName: "star.fill"), iconBackgroundColor: .systemPink, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "Чаты", icon: UIImage(systemName: "ellipsis.bubble.fill"), iconBackgroundColor: .systemTeal, handler: nil),
        ]))
        data.append(Section(title: "", options: [
            ProfileViewModel(viewModelType: .info, title: "Уведомления и звуки", icon: UIImage(systemName: "bell.badge.fill"), iconBackgroundColor: .systemRed, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "Данные и память", icon: UIImage(systemName: "folder.fill"), iconBackgroundColor: .systemGreen, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "Оформление", icon: UIImage(systemName: "paintpalette.fill"), iconBackgroundColor: .systemIndigo, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "Стикеры", icon: UIImage(systemName: "face.smiling.fill"), iconBackgroundColor: .systemYellow, handler: nil),
        ]))
        data.append(Section(title: "", options: [
            ProfileViewModel(viewModelType: .info, title: "Помощь", icon: UIImage(systemName: "questionmark.circle.fill"), iconBackgroundColor: .systemOrange, handler: nil),
            ProfileViewModel(viewModelType: .info, title: "О программе", icon: UIImage(systemName: "info"), iconBackgroundColor: .systemGray2, handler: nil)
        ]))
        data.append(Section(title: "", options: [
            ProfileViewModel(viewModelType: .logout, title: "Выход из учетной записи", icon: nil, iconBackgroundColor: .clear, handler: logout)
        ]))
    }
    
    public func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        StorageManager.shared.downloadURL(for: path, completion: { result in
            switch result {
            case let .success(url):
                self.imageView.sd_setImage(with: url, completed: nil)
            case let .failure(error):
                print("Не удается получить URL-адрес: \(error)")
            }
        })
        return headerView
    }
    
    public func logout() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Выход из учетной записи", style: .destructive, handler: { [weak self] _ in
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
        present(actionSheet, animated: true)
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = data[section]
        return section.title
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let viewModel = data[indexPath.section].options[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.identifier, for: indexPath) as? ProfileTableViewCell else {
            return UITableViewCell()
        }
        cell.configure(with: viewModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let viewModel = data[indexPath.section].options[indexPath.row]
        viewModel.handler?()
    }
}

class ProfileTableViewCell: UITableViewCell {

    static let identifier = "ProfileTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .natural
        return label
    }()
    
    private let iconContainer: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // уточнить зачем нужна функция ниже
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        iconContainer.backgroundColor = nil
        iconImageView.image = nil
    }
    
    public func configure(with model: ProfileViewModel) {
        switch model.viewModelType {
        case .info:
            label.text = model.title
            iconImageView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            let size: CGFloat = contentView.frame.size.height - 12
            iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
            let imageSize: CGFloat = size/1.5
            iconImageView.frame = CGRect(x: (size-imageSize)/2, y: (size-imageSize)/2, width: imageSize, height: imageSize)
            label.frame = CGRect(x: 25 + iconContainer.frame.size.width,
                                 y: 0,
                                 width: contentView.frame.size.width - 20 - iconContainer.frame.size.width - 10,
                                 height: contentView.frame.size.height)
        case .logout:
            label.text = model.title
            label.textColor = .red
            // label.textAlignment = .center
            // не знаю почему не работает сразу .center, а срабатывает после скролла
            label.frame = CGRect(x: 80, y: 0, width: contentView.width, height: contentView.height)
            accessoryType = .none
        }
    }
}
