import UIKit

final class WelcomeScreenController: UIViewController {
    
    // MARK: - Properties
    private let welcomeScreen = WelcomeScreenView()
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = welcomeScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    // MARK: - Functions
    private func setupView() {
        welcomeScreen.setupUIElements()
        welcomeScreen.backgroundColor = UIColor(named: "ColorBackgroundColor")
        welcomeScreen.welcomeButton.addTarget(self, action: #selector(welcomeButtonTapped), for: .touchUpInside)
    }
    
    @objc private func welcomeButtonTapped() {
        let viewController = LoginViewController()
        present(viewController, animated: true)
    }
}
