import UIKit
import SDWebImage
import FirebaseAuth
import FirebaseDatabase
import FBSDKLoginKit
import GoogleSignIn

class SettingsView: UIView {
    
    // MARK: - UI
    let tableView = UITableView(frame: .zero, style: .insetGrouped)

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGroupedBackground
        return view
    }()
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 60
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.text = "\(UserDefaults.standard.value(forKey: UserDefaultsKeys.name) as? String ?? "Нет имени пользователя")"
        label.textAlignment = .center
        return label
    }()

    private let userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.text = "\(UserDefaults.standard.value(forKey: UserDefaultsKeys.email) as? String ?? "Нет email-адреса")"
        label.textAlignment = .center
        return label
    }()

    public let buttonOut: UIButton = {
        let button = UIButton()
        button.setTitle("Выйти", for: .normal)
        button.backgroundColor = .systemGroupedBackground
        button.setTitleColor(.systemRed, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .regular)
        return button
    }()
    
    // MARK: - Dependencies
    init() {
        super.init(frame: .zero)
        setupUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Functions
    func setupUIElements() {
        addSubview(headerView)
        headerView.addSubview(imageView)
        headerView.addSubview(userNameLabel)
        headerView.addSubview(userEmailLabel)
        headerView.addSubview(buttonOut)
        addSubview(tableView)
        setupConstraints()
        setupTableHeader()
    }
    
    func setupTableHeader() {
        guard let email = UserDefaults.standard.value(forKey: UserDefaultsKeys.email) as? String,
              (UserDefaults.standard.value(forKey: UserDefaultsKeys.name) as? String) != nil else {
            return
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
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.heightAnchor.constraint(equalToConstant: 240),
            headerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: topAnchor)
        ])
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: topAnchor, constant: 240),
            tableView.bottomAnchor.constraint(equalTo: headerView.topAnchor)
        ])
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 30),
            userNameLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 150),
            userNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userEmailLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            userEmailLabel.heightAnchor.constraint(equalToConstant: 30),
            userEmailLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 180),
            userEmailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
        
        buttonOut.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonOut.heightAnchor.constraint(equalToConstant: 52),
            buttonOut.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 300),
            buttonOut.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10),
            buttonOut.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -70)
        ])
    }
}
