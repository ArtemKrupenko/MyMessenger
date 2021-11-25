//
//  SettingsTableViewCell.swift
//  Messenger
//
//  Created by Артем on 25.11.2021.
//

import Foundation
import SDWebImage

final class SettingsTableViewCell: UITableViewCell {

    static let identifier = "SettingsTableViewCell"

    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
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

    public func configure(with model: SettingViewModel) {
        switch model.viewModelType {
        case .info:
            label.text = model.title
            iconImageView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            let size: CGFloat = contentView.frame.size.height - 12
            iconContainer.frame = CGRect(x: 15, y: 6, width: size, height: size)
            let imageSize: CGFloat = size / 1.5
            iconImageView.frame = CGRect(x: (size - imageSize) / 2, y: (size - imageSize) / 2, width: imageSize, height: imageSize)
            label.frame = CGRect(x: 25 + iconContainer.frame.size.width,
                                 y: 0,
                                 width: contentView.frame.size.width - 20 - iconContainer.frame.size.width - 10,
                                 height: contentView.frame.size.height)
            accessoryType = .disclosureIndicator
        case .logout:
            accessoryType = .none
        }
    }
}
