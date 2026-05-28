import Foundation
import Security

/// 課金状態をKeychainに安全に保存するヘルパー
/// UserDefaultsのデータ消失時のバックアップとして機能
enum KeychainHelper {

    private static let service = "com.nfctools.app"
    private static let purchaseKey = "buy"

    /// 課金状態をKeychainに保存
    static func savePurchaseState(_ value: Int) {
        let data = withUnsafeBytes(of: value) { Data($0) }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: purchaseKey
        ]

        // 既存のアイテムを削除してから追加（重複防止）
        SecItemDelete(query as CFDictionary)

        var addQuery = query
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        SecItemAdd(addQuery as CFDictionary, nil)
    }

    /// Keychainから課金状態を読み取る（見つからない場合はnil）
    static func loadPurchaseState() -> Int? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: purchaseKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess, let data = result as? Data, data.count >= MemoryLayout<Int>.size else {
            return nil
        }

        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }

    /// Keychainから課金状態を削除
    static func removePurchaseState() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: purchaseKey
        ]
        SecItemDelete(query as CFDictionary)
    }

    /// 課金済みかチェック（UserDefaults → Keychain のフォールバック）
    /// Keychainにあり、UserDefaultsにない場合は自動復元する
    static func hasPurchased() -> Bool {
        // UserDefaultsから確認（高速パス）
        if let count = SafeUserDefaults.object(forKey: "buy") as? Int, count == 1 {
            return true
        }
        // Keychainフォールバック
        if let keychainValue = loadPurchaseState(), keychainValue == 1 {
            // UserDefaultsに復元
            SafeUserDefaults.set(1, forKey: "buy")
            return true
        }
        return false
    }
}
