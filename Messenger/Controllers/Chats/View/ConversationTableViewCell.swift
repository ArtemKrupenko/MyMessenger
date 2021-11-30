//
//  ConversationTableViewCell.swift
//  Messenger
//
//  Created by Артем on 26.10.2021.
//

import UIKit
import SDWebImage

final class ConversationTableViewCell: UITableViewCell {

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

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
        contentView.addSubview(userMessageLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не был выполнен")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 80,
                                     height: 80)
        userNameLabel.frame = CGRect(x: (userImageView.frame.size.width + userImageView.frame.origin.x) + 10,
                                     y: 10,
                                     width: contentView.frame.size.width - 40 - userImageView.frame.size.width,
                                     height: (contentView.frame.size.height - 20) / 3)
        userMessageLabel.frame = CGRect(x: (userImageView.frame.size.width + userImageView.frame.origin.x) + 10,
                                        y: (userNameLabel.frame.size.height + userNameLabel.frame.origin.y) + 10,
                                        width: contentView.frame.size.width - 40 - userImageView.frame.size.width,
                                        height: (contentView.frame.size.height - 20) / 2)
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
}
