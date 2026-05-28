import UIKit

/// UserDefaultsへのアクセスをデバイスロック状態から保護するラッパー
/// iOS 15以降のアプリプリウォーミングでUserDefaultsがnilを返す問題を防止
enum SafeUserDefaults {

    /// デバイスがアンロックされ、データ保護が解除されているかチェック
    static var isDataAvailable: Bool {
        return UIApplication.shared.isProtectedDataAvailable
    }

    /// UserDefaultsからIntを安全に読み取る（デバイスロック中はnilを返す）
    static func integer(forKey key: String) -> Int? {
        guard isDataAvailable else { return nil }
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.integer(forKey: key)
        }
        return nil
    }

    /// UserDefaultsからBoolを安全に読み取る（デバイスロック中はnilを返す）
    static func bool(forKey key: String) -> Bool? {
        guard isDataAvailable else { return nil }
        if UserDefaults.standard.object(forKey: key) != nil {
            return UserDefaults.standard.bool(forKey: key)
        }
        return nil
    }

    /// UserDefaultsからオブジェクトを安全に読み取る（デバイスロック中はnilを返す）
    static func object(forKey key: String) -> Any? {
        guard isDataAvailable else { return nil }
        return UserDefaults.standard.object(forKey: key)
    }

    /// UserDefaultsに安全に書き込む（デバイスロック中はスキップ）
    @discardableResult
    static func set(_ value: Any, forKey key: String) -> Bool {
        guard isDataAvailable else { return false }
        UserDefaults.standard.set(value, forKey: key)
        return true
    }

    /// UserDefaultsから安全に削除（デバイスロック中はスキップ）
    @discardableResult
    static func removeObject(forKey key: String) -> Bool {
        guard isDataAvailable else { return false }
        UserDefaults.standard.removeObject(forKey: key)
        return true
    }
}
