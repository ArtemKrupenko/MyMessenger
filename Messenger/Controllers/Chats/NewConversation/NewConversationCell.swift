//
//  NewConversationCell.swift
//  Messenger
//
//  Created by Артем on 05.11.2021.
//

import Foundation
import SDWebImage

final class NewConversationCell: UITableViewCell {

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.lightGray.cgColor
        imageView.layer.borderWidth = 2
        return imageView
    }()

    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .medium)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImageView)
        contentView.addSubview(userNameLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        userImageView.frame = CGRect(x: 10,
                                     y: 10,
                                     width: 70,
                                     height: 70)
        userNameLabel.frame = CGRect(x: (userImageView.frame.size.width + userImageView.frame.origin.x) + 10,
                                     y: 20,
                                     width: contentView.frame.size.width - 20 - userImageView.frame.size.width,
                                     height: 50)
    }

    public func configure(with model: SearchResult) {
        userNameLabel.text = model.name
        let path = "images/\(model.email)_profile_picture.png"
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
