import UIKit
import SDWebImage

final class ProfileSettingsView: UIView {
    
    // MARK: - UI
    lazy var headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    lazy var imageView: UIImageView = {
        let view = UIImageView()
//        view.backgroundColor = .blue
//        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 60
        view.layer.masksToBounds = true
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 2
        return view
    }()

    lazy var userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .regular)
        label.text = "\(UserDefaults.standard.value(forKey: "name") as? String ?? "Нет имени пользователя")"
        label.textAlignment = .center
        return label
    }()

    lazy var userEmailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.text = "\(UserDefaults.standard.value(forKey: "email") as? String ?? "Нет email-адреса")"
        label.textAlignment = .center
        return label
    }()

    lazy var buttonOut: UIButton = {
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
        super.init(frame: UIScreen.main.bounds)
        setupUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUIElements() {
        addSubview(headerView)
        headerView.addSubview(imageView)
        headerView.addSubview(userNameLabel)
        headerView.addSubview(userEmailLabel)
        headerView.addSubview(buttonOut)
        setupHeaderViewConstraints()
        setupImageViewConstraints()
        setupUserNameLabelConstraints()
        setupUserEmailLabelConstraints()
        setupButtonOutConstraints()
        buttonOut.addTarget(self, action: #selector(SettingsViewController.logout), for: .touchUpInside)
        createTableHeader()
    }
    
    public func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        guard (UserDefaults.standard.value(forKey: "name") as? String) != nil else {
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
    
    // MARK: - Constraints
    private func setupHeaderViewConstraints() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            headerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerView.topAnchor.constraint(equalTo: topAnchor),
            headerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func setupImageViewConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 120),
            imageView.heightAnchor.constraint(equalToConstant: 120),
            imageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -30),
            imageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        ])
    }
    
    private func setupUserNameLabelConstraints() {
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            userNameLabel.heightAnchor.constraint(equalToConstant: 30),
            userNameLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            userNameLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 150)
        ])
    }
    
    private func setupUserEmailLabelConstraints() {
        userEmailLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userEmailLabel.widthAnchor.constraint(equalTo: headerView.widthAnchor),
            userEmailLabel.heightAnchor.constraint(equalToConstant: 30),
            userEmailLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            userEmailLabel.bottomAnchor.constraint(equalTo: imageView.topAnchor, constant: 180)
        ])
    }
    
    private func setupButtonOutConstraints() {
        buttonOut.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonOut.rightAnchor.constraint(equalTo: headerView.rightAnchor, constant: -10),
            buttonOut.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 320),
            buttonOut.heightAnchor.constraint(equalToConstant: 52),
            buttonOut.centerYAnchor.constraint(equalTo: headerView.centerYAnchor, constant: -70)
        ])
    }
}
