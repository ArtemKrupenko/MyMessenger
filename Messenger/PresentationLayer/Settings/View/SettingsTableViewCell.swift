import UIKit
import SDWebImage

class SettingsTableViewCell: UITableViewCell {

    // MARK: - UI
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

    // MARK: - Dependencies
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIElements()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - Functions
    private func setupUIElements() {
        contentView.addSubview(label)
        contentView.addSubview(iconContainer)
        iconContainer.addSubview(iconImageView)
        contentView.clipsToBounds = true
        setupConstraints()
    }

    public func configure(with model: SettingViewModel) {
        switch model.viewModelType {
        case .info:
            label.text = model.title
            iconImageView.image = model.icon
            iconContainer.backgroundColor = model.iconBackgroundColor
            accessoryType = .disclosureIndicator
        case .logout:
            accessoryType = .none
        }
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconContainer.widthAnchor.constraint(equalToConstant: 30),
            iconContainer.heightAnchor.constraint(equalToConstant: 30),
            iconContainer.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 10),
            iconContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0)
        ])
        
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor)
        ])
        
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.widthAnchor.constraint(equalTo: contentView.widthAnchor),
            label.heightAnchor.constraint(equalToConstant: 30),
            label.bottomAnchor.constraint(equalTo: iconContainer.topAnchor, constant: 30),
            label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor, constant: 50)
        ])
    }
}
