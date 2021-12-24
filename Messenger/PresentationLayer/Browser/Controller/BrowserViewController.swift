import UIKit
import WebKit

/// Контроллер, отображающий браузер
final class BrowserViewController: UIViewController {
    
    // MARK: - Properties
    public let browserView = BrowserView()

    // MARK: - VC Lifecycle
    override func loadView() {
        view = browserView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    // MARK: - Functions
    private func setupView() {
        browserView.setupUIElements()
        browserView.backgroundColor = .systemBackground
        browserView.urlTextField.delegate = self
        browserView.webView.navigationDelegate = self
//        browserView.backButton.action = #selector(didTapBackButton)
//        browserView.forwardButton.action = #selector(didTapForwardButton)
//        browserView.refreshButton.action = #selector(refreshAction)
        loadRequest()
    }
    
    public func setupNavigationBar() {
        let backButton = UIBarButtonItem(barButtonSystemItem: .rewind,
                                         target: self,
                                         action: #selector(didTapBackButton))
        let forwardButton = UIBarButtonItem(barButtonSystemItem: .fastForward,
                                         target: self,
                                         action: #selector(didTapForwardButton))
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        navigationItem.leftBarButtonItems = [backButton, forwardButton, spacer]
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(refreshAction))
        navigationItem.rightBarButtonItem = refreshButton
//        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Назад",
//                                                            style: .plain,
//                                                            target: self,
//                                                            action: #selector(didTapBackButton))
//        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Вперед",
//                                                            style: .plain,
//                                                            target: self,
//                                                            action: #selector(didTapForwardButton))
    }
    
    private func loadRequest() {
        let homePage = "https://www.google.com"
        guard let url = URL(string: homePage) else {
            return
        }
        let urlRequest = URLRequest(url: url)
        browserView.webView.load(urlRequest)
        browserView.webView.allowsBackForwardNavigationGestures = true
        browserView.urlTextField.text = homePage
    }
    
    // MARK: - Actions
    @objc private func didTapBackButton() {
        if browserView.webView.canGoBack {
            browserView.webView.goBack()
        }
    }
    
    @objc private func didTapForwardButton() {
        if browserView.webView.canGoForward {
            browserView.webView.goForward()
        }
    }
    
    @objc private func refreshAction() {
        browserView.webView.reload()
    }
}
