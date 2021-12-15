import UIKit

class NewConversationView: UIView {
    
    // MARK: - UI

    public let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        return table
    }()

    public let noResultLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.text = "Нет результатов"
        label.textAlignment = .center
        label.textColor = UIColor.gray
        label.font = .systemFont(ofSize: 18, weight: .medium)
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
        addSubview(noResultLabel)
        addSubview(tableView)
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
        
        noResultLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            noResultLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            noResultLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            noResultLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            noResultLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        ])
    }
}
