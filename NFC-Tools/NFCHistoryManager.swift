import Foundation

/// NFC読み取り結果をDocumentsディレクトリにJSON形式で永続保存するマネージャー
enum NFCHistoryManager {

    private static let fileName = "nfc_read_history.json"
    private static let maxEntries = 50

    private static var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent(fileName)
    }

    /// 保存済みの全履歴を読み込む（新しい順）
    static func loadHistory() -> [NFCReadResult] {
        guard let data = try? Data(contentsOf: fileURL) else { return [] }
        return (try? JSONDecoder().decode([NFCReadResult].self, from: data)) ?? []
    }

    /// 新しい読み取り結果を履歴に追加
    static func saveResult(_ result: NFCReadResult) {
        var history = loadHistory()
        history.insert(result, at: 0)
        if history.count > maxEntries {
            history = Array(history.prefix(maxEntries))
        }
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    /// 指定インデックスの履歴を削除
    static func deleteResult(at index: Int) {
        var history = loadHistory()
        guard index < history.count else { return }
        history.remove(at: index)
        if let data = try? JSONEncoder().encode(history) {
            try? data.write(to: fileURL, options: .atomic)
        }
    }

    /// 全履歴を削除
    static func clearHistory() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
