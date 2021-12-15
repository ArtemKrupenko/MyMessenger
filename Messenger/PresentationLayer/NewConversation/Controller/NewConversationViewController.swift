import UIKit
import JGProgressHUD

/// Контроллер, отображающий поиск и создание нового диалога
final class NewConversationViewController: UIViewController {

    // MARK: - Properties
    public var completion: ((SearchResult) -> Void)?
    private let spinner = JGProgressHUD(style: .dark)
    private var users = [[String: String]]()
    public var results = [SearchResult]()
    private var hasFetched = false
    private let newConversationView = NewConversationView()
    
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
        newConversationView.setupUIElements()
        newConversationView.backgroundColor = .systemBackground
        newConversationView.tableView.delegate = self
        newConversationView.tableView.dataSource = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
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

extension NewConversationViewController: UISearchBarDelegate {

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        searchBar.resignFirstResponder()
        results.removeAll()
        spinner.show(in: view)
        searchUsers(query: text)
    }

    func searchUsers(query: String) {
        // Проверяем имеет ли массив результаты firebase
        if hasFetched {
            // если это так: фильтруем
            filterUsers(with: query)
        } else {
            // если нет: то извлекаем, затем фильтруем
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case let .success(usersCollection):
                    self?.hasFetched = true
                    self?.users = usersCollection
                    self?.filterUsers(with: query)
                case let .failure(error):
                    print("Не удалось получить пользователей: \(error)")
                }
            })
        }
    }

    func filterUsers(with term: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String, hasFetched else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        self.spinner.dismiss()
        let results: [SearchResult] = users.filter({
            guard let email = $0["email"], email != safeEmail else {
                return false
            }
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        }).compactMap({
            guard let email = $0["email"], let name = $0["name"] else {
                return nil
            }
            return SearchResult(name: name, email: email)
        })
        self.results = results
        updateUI()
    }

    func updateUI() {
        if results.isEmpty {
            newConversationView.noResultLabel.isHidden = false
            newConversationView.tableView.isHidden = true
        } else {
            newConversationView.noResultLabel.isHidden = true
            newConversationView.tableView.isHidden = false
            newConversationView.tableView.reloadData()
        }
    }
}
