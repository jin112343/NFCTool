//
//  ViewController2.swift
//  NFCTool
//
//  Created by Jin Mizou on 2021/01/19.
//  Copyright © 2021 Jin Mizoi. All rights reserved.
//

import UIKit
import MessageUI
import GoogleMobileAds
import SwiftUI
import OSLog
import StoreKit
import SafariServices

class ViewController2: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate, CatchProtcol {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "Settings")
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    @IBAction func terms(_ sender: Any) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
    
    
    @IBAction func terms2(_ sender: Any) {
        let contactVC = ContactFormViewController()
        let nav = UINavigationController(rootViewController: contactVC)
        present(nav, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 購入済みかチェックして広告を表示/非表示
        if KeychainHelper.hasPurchased() {
            bannerView.isHidden = true
        } else {
            // GADBannerViewのプロパティを設定
            bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
            bannerView.rootViewController = self

            // 広告読み込み
            bannerView.load(GADRequest())
        }
    }
    
    func catchData(count: Int) {

        if count == 1 {
            bannerView?.isHidden = true
        }

    }
    func addBannerViewToView(_ bannerView: GADBannerView) {
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bannerView)
        view.addConstraints(
            [NSLayoutConstraint(item: bannerView,
                                attribute: .bottom,
                                relatedBy: .equal,
                                toItem: view.safeAreaLayoutGuide,
                                attribute: .bottom,
                                multiplier: 1,
                                constant: 0),
             NSLayoutConstraint(item: bannerView,
                                attribute: .centerX,
                                relatedBy: .equal,
                                toItem: view,
                                attribute: .centerX,
                                multiplier: 1,
                                constant: 0)
            ])
    }
    
    
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            logger.info("メール作成キャンセル")
        case .saved:
            logger.info("メール下書き保存")
        case .sent:
            logger.info("メール送信成功")
        case .failed:
            logger.error("メール送信失敗: \(error?.localizedDescription ?? "unknown")")
        @unknown default:
            logger.warning("メール結果: 不明な状態")
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func terms3(_ sender: Any) {
        let url = URL(string: "https://jinpost.wordpress.com/2021/01/14/nfc-tool%e5%88%a9%e7%94%a8%e8%a6%8f%e7%b4%84/")!
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
    
    @IBAction func terms4(_ sender: Any) {
        let url = URL(string: "https://amzn.to/45nMq0T")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
}
