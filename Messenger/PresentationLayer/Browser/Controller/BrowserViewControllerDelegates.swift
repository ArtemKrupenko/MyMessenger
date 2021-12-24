import UIKit
import WebKit

// MARK: - UITextField
extension BrowserViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let urlString = textField.text!
        let url = URL(string: urlString)!
        let urlRequest = URLRequest(url: url)
        browserView.webView.load(urlRequest)
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - WKNavigation
extension BrowserViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        browserView.urlTextField.text = webView.url?.absoluteString
//        browserView.backButton.isEnabled = webView.canGoBack
//        browserView.forwardButton.isEnabled = webView.canGoForward
    }
}
