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

class ViewController2: UIViewController, MFMailComposeViewControllerDelegate, GADBannerViewDelegate {
    
    
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
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["mizoijin.0201@gmail.com"]) // 宛先アドレス
                    mail.setSubject("お問い合わせ") // 件名
                    mail.setMessageBody("ここに本文が入ります。", isHTML: false) // 本文
                    present(mail, animated: true, completion: nil)
                } else {
                    print("送信できません")
                }
            }
    override func viewDidLoad() {
        super.viewDidLoad()
        // GADBannerViewのプロパティを設定
        bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
        bannerView.rootViewController = self

        // 広告読み込み
        bannerView.load(GADRequest())
        
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
            multipleAdsOptions.numberOfAds = 5
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
                    print("キャンセル")
                case .saved:
                    print("下書き保存")
                case .sent:
                    print("送信成功")
                default:
                    print("送信失敗")
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
            let url = URL(string: "https://www.amazon.co.jp/s?k=nfc&__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&ref=nb_sb_noss_1")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
}
