import UIKit

class ChatView: UIView {
    
    // MARK: - UI
    
    // MARK: - Dependencies
    init() {
        super.init(frame: UIScreen.main.bounds)
        setupUIElements()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUIElements() {
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        
    }
}
