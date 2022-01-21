import UIKit

// MARK: - TableView
extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = results[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: Identifiers.newConversationTableViewCell, for: indexPath) as! NewConversationTableViewCell
        cell.configure(with: model)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Начинаем беседу
        let targetUserData = results[indexPath.row]
        dismiss(animated: true, completion: { [weak self] in
            self?.completion?(targetUserData)
        })
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        90
    }
}

// MARK: - SearchBar
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
        guard let currentUserEmail = UserDefaults.standard.value(forKey: UserDefaultsKeys.email.rawValue) as? String, hasFetched else {
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
