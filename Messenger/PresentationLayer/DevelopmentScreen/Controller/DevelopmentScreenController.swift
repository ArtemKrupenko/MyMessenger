import UIKit

final class DevelopmentScreenController: UIViewController {
    
    // MARK: - Properties
    private let developmentScreen = DevelopmentScreenView()
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = developmentScreen
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    // MARK: - Functions
    private func setupView() {
        developmentScreen.setupUIElements()
        developmentScreen.backgroundColor = UIColor(named: "ColorBackgroundColor")
    }
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(closeButtonPressed))
    }
    
    // MARK: - Actions
    @objc private func closeButtonPressed() {
        dismiss(animated: true)
    }
}
