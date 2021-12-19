import UIKit

class WelcomeScreenView: UIView {
    
    // MARK: - UI
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = Images.welcome
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    public let welcomeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 46, weight: .semibold)
        label.text = "PepeChat"
        label.textAlignment = .center
        return label
    }()
    
    public let welcomeButton: UIButton = {
        let button = UIButton()
        button.setTitle("🎉 Добро пожаловать! →", for: .normal)
        button.backgroundColor = UIColor(named: "ColorLogo")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.contentMode = .scaleAspectFit
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
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
        addSubview(imageView)
        addSubview(welcomeLabel)
        addSubview(welcomeButton)
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
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            welcomeLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            welcomeLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            welcomeLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30),
            welcomeLabel.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        welcomeButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            welcomeButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 60),
            welcomeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -60),
            welcomeButton.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 120),
            welcomeButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
}
