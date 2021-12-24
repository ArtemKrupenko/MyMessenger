import UIKit
import WebKit

class BrowserView: UIView {
    
    // MARK: - UI
    public let webView = WKWebView()
    
    let navigationBar = UINavigationBar()
//    public let backButton = UIBarButtonItem(systemItem: .rewind)
//    public let forwardButton = UIBarButtonItem(systemItem: .fastForward)
//    public let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
//    public let refreshButton = UIBarButtonItem(systemItem: .refresh)
    
//    public let backButton: UIButton = {
//        let button = UIButton()
//        return button
//    }()
//
//    public let forwardButton: UIButton = {
//        let button = UIButton()
//        return button
//    }()
//
//    public let spacer: UIButton = {
//        let button = UIButton()
//        return button
//    }()
//
//    public let refreshButton: UIButton = {
//        let button = UIButton()
//        return button
//    }()
    
    public let urlTextField: UITextField = {
        let field = UITextField()
        field.autocorrectionType = .no
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
//        addSubview(navigationBar)
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor)
//            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
//        navigationBar.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            navigationBar.leadingAnchor.constraint(equalTo: leadingAnchor),
//            navigationBar.trailingAnchor.constraint(equalTo: trailingAnchor),
//            navigationBar.topAnchor.constraint(equalTo: webView.bottomAnchor),
//            navigationBar.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
    }
}
