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

class ViewController2: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate, CatchProtcol {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "Settings")
    
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    
    @IBAction func terms(_ sender: Any) {
        let url = URL(string: "https://apps.apple.com/jp/app/nfctool/id1548623317")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
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
        if let count = UserDefaults.standard.object(forKey: "buy") as? Int, count == 1 {
            bannerView.removeFromSuperview()
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
            
            bannerView.removeFromSuperview()
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
        let url = URL(string: "http://jin021ncf.html.xdomain.jp/Terms-of-service.html")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func terms4(_ sender: Any) {
        let url = URL(string: "https://amzn.to/45nMq0T")!
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    
}
