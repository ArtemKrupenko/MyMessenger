import UIKit
import WebKit

class BrowserView: UIView {
    
    // MARK: - UI
    public let webView = WKWebView()
    
    public let urlTextField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
//        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Введите имя сайта"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .secondarySystemBackground
        return field
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
        addSubview(webView)
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        urlTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            urlTextField.heightAnchor.constraint(equalToConstant: 25),
            urlTextField.widthAnchor.constraint(equalToConstant: 250)
        ])
    }
}
