import UIKit
import FirebaseAuth
import JGProgressHUD

/// Контроллер, отображающий список диалогов
final class ConversationsViewController: UIViewController {
    
    // MARK: - Properties
    private let conversationsView = ConversationsView()
    public var conversations = [Conversation]()
    private var loginObserver: NSObjectProtocol?
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = conversationsView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupNavigationBar()
        setupListConversation()
    }
    
    // MARK: - Functions
    private func setupView() {
        conversationsView.setupUIElements()
        conversationsView.backgroundColor = .systemBackground
        conversationsView.tableView.delegate = self
        conversationsView.tableView.dataSource = self
        conversationsView.tableView.register(ConversationTableViewCell.self, forCellReuseIdentifier: Identifiers.conversationTableViewCell)
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "Чаты"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Изм.",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapEditButton))
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
    }
    
    private func setupListConversation() {
        startListeningForConversations()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversations()
        })
    }
    
    // MARK: - Actions
    public func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: UserDefaultsKeys.email.rawValue) as? String else {
            return
        }
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case let .success(conversations):
                guard !conversations.isEmpty else {
                    self?.conversationsView.tableView.isHidden = true
                    self?.conversationsView.noConversationsLabel.isHidden = false
                    return
                }
                self?.conversationsView.tableView.isHidden = false
                self?.conversationsView.noConversationsLabel.isHidden = true
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.conversationsView.tableView.reloadData()
                }
            case let .failure(error):
                self?.conversationsView.tableView.isHidden = true
                self?.conversationsView.noConversationsLabel.isHidden = false
                print("Не удается получить сообщения: \(error)")
            }
        })
    }

    @objc private func didTapComposeButton() {
        let viewController = NewConversationViewController()
        viewController.completion = { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            let currentConversations = strongSelf.conversations
            if let targetConversation = currentConversations.first(where: {
                $0.otherUserEmail == DatabaseManager.safeEmail(emailAddress: result.email)
            }) {
                let viewController = ChatViewController(with: targetConversation.otherUserEmail, id: targetConversation.id)
                viewController.isNewConversation = false
                viewController.title = targetConversation.name
                viewController.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
            } else {
                strongSelf.createNewConversation(result: result)
            }
        }
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc private func didTapEditButton() {
        conversationsView.tableView.setEditing(!conversationsView.tableView.isEditing, animated: true)
    }
    
    private func createNewConversation(result: SearchResult) {
        let name = result.name
        let email = DatabaseManager.safeEmail(emailAddress: result.email)
        // Проверяем в базе данных, существует ли разговор с этими двумя пользователями
        // Если это так, повторно используем id диалога
        // В противном случае используем существующий код
        DatabaseManager.shared.conversationExists(with: email, completion: { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case let .success(conversationId):
                let viewController = ChatViewController(with: email, id: conversationId)
                viewController.isNewConversation = false
                viewController.title = name
                viewController.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
            case .failure:
                let viewController = ChatViewController(with: email, id: nil)
                viewController.isNewConversation = true
                viewController.title = name
                viewController.navigationItem.largeTitleDisplayMode = .never
                strongSelf.navigationController?.pushViewController(viewController, animated: true)
            }
        })
    }
}
