import UIKit
import OSLog

/// NFC読み取り履歴の一覧表示画面
class NFCHistoryViewController: UITableViewController {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "History")
    private var history: [NFCReadResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("history_title", tableName: "Main", comment: "履歴")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "trash"),
            style: .plain,
            target: self,
            action: #selector(clearHistory)
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        history = NFCHistoryManager.loadHistory()
        tableView.reloadData()
        navigationItem.rightBarButtonItem?.isEnabled = !history.isEmpty
    }

    @objc private func clearHistory() {
        let alert = UIAlertController(
            title: nil,
            message: NSLocalizedString("clear_history_confirm", tableName: "Main", comment: "履歴を全て削除しますか？"),
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", tableName: "Main", comment: "キャンセル"), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("delete", tableName: "Main", comment: "削除"), style: .destructive) { [weak self] _ in
            NFCHistoryManager.clearHistory()
            self?.history = []
            self?.tableView.reloadData()
            self?.navigationItem.rightBarButtonItem?.isEnabled = false
        })
        present(alert, animated: true)
    }

    // MARK: - TableView DataSource

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if history.isEmpty {
            let label = UILabel()
            label.text = NSLocalizedString("no_history", tableName: "Main", comment: "履歴なし")
            label.textAlignment = .center
            label.textColor = .secondaryLabel
            tableView.backgroundView = label
            return 0
        }
        tableView.backgroundView = nil
        return history.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        let result = history[indexPath.row]

        var config = cell.defaultContentConfiguration()
        config.text = result.tagType + (result.tagIdentifier.map { " - \($0)" } ?? "")

        if let balance = result.felicaBalance {
            config.secondaryText = "¥\(balance)"
        } else if let first = result.records.first {
            config.secondaryText = first.textContent ?? first.urlContent?.absoluteString ?? first.payloadType
        } else {
            config.secondaryText = "\(result.capacity) bytes"
        }

        cell.contentConfiguration = config
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - TableView Delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard indexPath.row < history.count else { return }
        let resultVC = NFCReadResultViewController()
        resultVC.readResult = history[indexPath.row]
        navigationController?.pushViewController(resultVC, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            NFCHistoryManager.deleteResult(at: indexPath.row)
            history.remove(at: indexPath.row)
            if history.isEmpty {
                tableView.reloadData()
                navigationItem.rightBarButtonItem?.isEnabled = false
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}
