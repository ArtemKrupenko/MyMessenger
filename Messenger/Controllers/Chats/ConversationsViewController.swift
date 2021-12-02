//
//  ViewController.swift
//  Messenger
//
//  Created by Артем on 27.09.2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

/// Контроллер, отображающий список диалогов
final class ConversationsViewController: UIViewController {

    private let spinner = JGProgressHUD(style: .dark)

    private var conversations = [Conversation]()

    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.tableFooterView = UIView(frame: .zero)
        table.register(ConversationTableViewCell.self, forCellReuseIdentifier: Identifiers.conversationTableViewCell)
        return table
    }()

    private let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет диалогов"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
    }()

    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Чаты"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose,
                                                            target: self,
                                                            action: #selector(didTapComposeButton))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Изм.",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(didTapEditButton))
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        startListeningForConversations()
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.startListeningForConversations()
        })
    }

    public func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
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
                    self?.tableView.isHidden = true
                    self?.noConversationsLabel.isHidden = false
                    return
                }
                self?.tableView.isHidden = false
                self?.noConversationsLabel.isHidden = true
                self?.conversations = conversations
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case let .failure(error):
                self?.tableView.isHidden = true
                self?.noConversationsLabel.isHidden = false
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
        tableView.setEditing(!tableView.isEditing, animated: true)
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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noConversationsLabel.frame = CGRect(x: 10,
                                            y: (view.frame.size.height - 100) / 2,
                                            width: view.frame.size.width - 20,
                                            height: 100)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ConversationsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.conversationTableViewCell, for: indexPath) as! ConversationTableViewCell
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = conversations[indexPath.row]
        openConversation(model)
    }

    func openConversation(_ model: Conversation) {
        let viewController = ChatViewController(with: model.otherUserEmail, id: model.id)
        viewController.title = model.name
        viewController.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(viewController, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // удаление диалога
            let conversationId = conversations[indexPath.row].id
            tableView.beginUpdates()
            self.conversations.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
            DatabaseManager.shared.deleteConversation(conversationId: conversationId, completion: { success in
                if !success {
                }
            })
            tableView.endUpdates()
        }
    }
    
    func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        moveConversations(indexPath: fromIndexPath, toIndex: to.row)
        tableView.reloadData()
    }

    /// Перемещение диалогов
    func moveConversations(indexPath: IndexPath, toIndex: Int) {
        let from = conversations[indexPath.row]
        self.conversations.remove(at: indexPath.row)
        self.conversations.insert(from, at: toIndex)
    }
}