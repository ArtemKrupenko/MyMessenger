import UIKit
import SDWebImage

class ConversationTableViewCell: UITableViewCell {
    
    // MARK: - UI
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 40
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.numberOfLines = 0
        return label
    }()

    private let userMessageLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    // MARK: - Dependencies
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func setupUIElements() {
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
        setupConstraints()
    }

    public func configure(with model: Conversation) {
        userMessageLabel.text = model.latestMessage.text
        userNameLabel.text = model.name
        let path = "images/\(model.otherUserEmail)_profile_picture.png"
        StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
            switch result {
            case let .success(url):
                DispatchQueue.main.async {
                    self?.userImageView.sd_setImage(with: url, completed: nil)
                }
            case let .failure(error):
                print("Не удалось получить URL-адрес изображения: \(error)")
            }
        })
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        userImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userImageView.widthAnchor.constraint(equalToConstant: 80),
            userImageView.heightAnchor.constraint(equalToConstant: 80),
            userImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            userImageView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor)
        ])
        
        userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNameLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            userNameLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1 / 3, constant: 20),
            userNameLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10)
        ])
        
        userMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userMessageLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -110),
            userMessageLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 1 / 2, constant: 0),
            userMessageLabel.leftAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 10),
            userMessageLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -10),
            userMessageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 10)
        ])
    }
}
