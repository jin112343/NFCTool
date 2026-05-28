//
//  AppDelegate.swift
//  NFCTool
//
//  Created by Jin Mizou on 2019/11/11.
//  Copyright © 2019 Jin Mizou. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import GoogleMobileAds
import FirebaseCore
import FirebaseCrashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Firebase初期化
        FirebaseApp.configure()

        // Crashlytics設定
        setupCrashlytics()

        //広告
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        
        //アプリ内課金
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // 未知の状態は無視
                }
            }
        }
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    // MARK: - Crashlytics Setup

    private func setupCrashlytics() {
        let crashlytics = Crashlytics.crashlytics()

        // デバイス情報（自動収集に加えて追加情報）
        crashlytics.setCustomValue(UIDevice.current.name, forKey: "device_name")
        crashlytics.setCustomValue(UIDevice.current.model, forKey: "device_model")
        crashlytics.setCustomValue(UIDevice.current.systemName, forKey: "os_name")
        crashlytics.setCustomValue(UIDevice.current.systemVersion, forKey: "os_version")

        // アプリバージョン情報
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            crashlytics.setCustomValue(appVersion, forKey: "app_version")
        }
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            crashlytics.setCustomValue(buildNumber, forKey: "build_number")
        }

        // Locale情報
        crashlytics.setCustomValue(Locale.current.identifier, forKey: "locale")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
}


