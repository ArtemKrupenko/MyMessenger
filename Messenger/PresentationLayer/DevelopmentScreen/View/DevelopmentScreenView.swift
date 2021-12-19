import UIKit

class DevelopmentScreenView: UIView {
    
    // MARK: - UI
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.development
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let oneLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 40, weight: .semibold)
        label.text = "Упс..."
        label.textAlignment = .center
        return label
    }()
    
    public let twoLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 30, weight: .medium)
        label.text = "Здесь пока ничего нет"
        label.textAlignment = .center
        return label
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
        addSubview(imageView)
        addSubview(oneLabel)
        addSubview(twoLabel)
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            imageView.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.widthAnchor, multiplier: 0.7),
            imageView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 100),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
        
        oneLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            oneLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            oneLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            oneLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            oneLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        twoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            twoLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            twoLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            twoLabel.topAnchor.constraint(equalTo: oneLabel.bottomAnchor, constant: 5),
            twoLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}
