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
        loadRequest()
    }
    
    public func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.titleView = browserView.urlTextField
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"),
                                         style: .done,
                                         target: self,
                                         action: #selector(didTapBackButton))
        let forwardButton = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"),
                                         style: .done,
                                         target: self,
                                         action: #selector(didTapForwardButton))
        navigationItem.leftBarButtonItems = [backButton, forwardButton]
        let refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh,
                                            target: self,
                                            action: #selector(refreshAction))
        navigationItem.rightBarButtonItem = refreshButton
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
            browserView.urlTextField.text = browserView.webView.url?.absoluteString
        }
    }
    
    @objc private func didTapForwardButton() {
        if browserView.webView.canGoForward {
            browserView.webView.goForward()
            browserView.urlTextField.text = browserView.webView.url?.absoluteString
        }
    }
    
    @objc private func refreshAction() {
        browserView.webView.reload()
    }
}
