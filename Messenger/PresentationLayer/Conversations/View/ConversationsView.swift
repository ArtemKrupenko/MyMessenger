import UIKit

class ConversationsView: UIView {
    
    // MARK: - UI
    public let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.tableFooterView = UIView(frame: .zero)
        return table
    }()

    public let noConversationsLabel: UILabel = {
        let label = UILabel()
        label.text = "Нет диалогов"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.isHidden = true
        return label
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
        addSubview(tableView)
        addSubview(noConversationsLabel)
        setupConstraints()
    }
    
    // MARK: - Constraints
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
        
        noConversationsLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noConversationsLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            noConversationsLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            noConversationsLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
