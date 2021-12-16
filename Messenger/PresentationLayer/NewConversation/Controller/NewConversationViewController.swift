import UIKit
import JGProgressHUD

/// Контроллер, отображающий поиск и создание нового диалога
final class NewConversationViewController: UIViewController {

    // MARK: - Properties
    public var completion: ((SearchResult) -> Void)?
    public let spinner = JGProgressHUD(style: .dark)
    public var users = [[String: String]]()
    public var results = [SearchResult]()
    public var hasFetched = false
    public let newConversationView = NewConversationView()
    
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        return searchBar
    }()

    // MARK: - VC Lifecycle
    override func loadView() {
        view = newConversationView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
    }
    
    // MARK: - Functions
    private func setupView() {
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        newConversationView.setupUIElements()
        newConversationView.tableView.delegate = self
        newConversationView.tableView.dataSource = self
        newConversationView.tableView.register(NewConversationTableViewCell.self, forCellReuseIdentifier: Identifiers.newConversationTableViewCell)
        newConversationView.tableView.frame = view.bounds
    }
    
    private func setupNavigationBar() {
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Отмена",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissSelf))
    }

    @objc private func dismissSelf() {
        dismiss(animated: true, completion: nil)
    }
}
