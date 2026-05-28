//
//  CrashlyticsManager.swift
//  NFC-Tools
//
//  Created for crash reporting with Firebase Crashlytics
//

import Foundation
import FirebaseCrashlytics

/// Crashlyticsへのクラッシュ情報記録を管理するシングルトン
final class CrashlyticsManager {

    static let shared = CrashlyticsManager()

    private let crashlytics = Crashlytics.crashlytics()

    private init() {}

    // MARK: - 画面トラッキング

    /// 現在の画面名を記録
    /// - Parameter screenName: 画面名（例: "NFC読取画面", "URL書込画面"）
    func setCurrentScreen(_ screenName: String) {
        crashlytics.setCustomValue(screenName, forKey: "current_screen")
        crashlytics.log("画面遷移: \(screenName)")
    }

    // MARK: - 操作トラッキング

    /// ユーザーの操作を記録
    /// - Parameters:
    ///   - action: 操作内容（例: "読取ボタンタップ", "URL入力"）
    ///   - details: 追加情報（オプション）
    func logAction(_ action: String, details: String? = nil) {
        crashlytics.setCustomValue(action, forKey: "last_action")
        if let details = details {
            crashlytics.log("操作: \(action) - \(details)")
        } else {
            crashlytics.log("操作: \(action)")
        }
    }

    // MARK: - NFC操作トラッキング

    /// NFC操作の開始を記録
    /// - Parameter operationType: 操作タイプ（読取、書込、削除など）
    func logNFCOperationStart(_ operationType: String) {
        crashlytics.setCustomValue(operationType, forKey: "nfc_operation")
        crashlytics.setCustomValue("started", forKey: "nfc_operation_status")
        crashlytics.log("NFC操作開始: \(operationType)")
    }

    /// NFC操作の完了を記録
    /// - Parameters:
    ///   - operationType: 操作タイプ
    ///   - success: 成功したかどうか
    func logNFCOperationEnd(_ operationType: String, success: Bool) {
        let status = success ? "success" : "failed"
        crashlytics.setCustomValue(status, forKey: "nfc_operation_status")
        crashlytics.log("NFC操作完了: \(operationType) - \(status)")
    }

    // MARK: - エラー記録

    /// 非致命的エラーを記録（クラッシュはしないがエラーとして記録）
    /// - Parameters:
    ///   - error: エラーオブジェクト
    ///   - context: エラーが発生したコンテキスト
    func recordError(_ error: Error, context: String) {
        crashlytics.setCustomValue(context, forKey: "error_context")
        crashlytics.record(error: error)
    }

    /// カスタムエラーを記録
    /// - Parameters:
    ///   - message: エラーメッセージ
    ///   - code: エラーコード
    ///   - context: エラーが発生したコンテキスト
    func recordCustomError(message: String, code: Int, context: String) {
        let error = NSError(
            domain: "com.nfctools.error",
            code: code,
            userInfo: [NSLocalizedDescriptionKey: message]
        )
        crashlytics.setCustomValue(context, forKey: "error_context")
        crashlytics.record(error: error)
    }

    // MARK: - カスタムキー

    /// カスタムキーを設定
    /// - Parameters:
    ///   - value: 値
    ///   - key: キー名
    func setCustomValue(_ value: Any, forKey key: String) {
        crashlytics.setCustomValue(value, forKey: key)
    }

    // MARK: - ログ

    /// カスタムログメッセージを記録
    /// - Parameter message: ログメッセージ
    func log(_ message: String) {
        crashlytics.log(message)
    }
}
