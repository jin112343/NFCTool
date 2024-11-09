//  ViewController3.swift
//
//
//  Created by 溝井迅 on 2022/12/15.
//
//
//  ViewController.swift
//  NFCTool
//
//  Created by Jin Mizou on 2019/11/11.
//  Copyright © 2019 Jin Mizoi. All rights reserved.
//

import UIKit
import CoreNFC
import GoogleMobileAds
import SwiftUI

enum States {
    case standBy
    case read
    case write
    case delete
}

class ViewController3: UIViewController, GADBannerViewDelegate, CatchProtcol {
    //CatchProtcol
    
    //ボタン設定
    
    //書き込みテキスト
    @IBOutlet weak var textField: UITextField!
    //書き込みボタン
    @IBOutlet weak var writeBtn: UIButton!
 
    //広告
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: States = .standBy
    var text: String = ""
    var deleting = false
    
    
    // 初期表示時に必要な処理を設定します。
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //この下の7行を追加
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        if ud
        .bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            self.performSegue(withIdentifier: "nfc", sender: nil)
        }
        
       
        
    }
    // 画面に表示される直前に呼ばれます。
    override func viewWillAppear(_ animated: Bool) {
        loadView()
        viewDidLoad()
        super.viewWillAppear(animated)

        //もしbuyというキー値に1という数字が入っていたら
        //購入済み = 広告を排除

        if UserDefaults.standard.object(forKey: "buy") != nil{
              let count  = UserDefaults.standard.object(forKey: "buy") as! Int
            if count == 1{

               



            }else{
                
            }
            
            
        }else{

                // GADBannerViewのプロパティを設定
                bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
                bannerView.rootViewController = self

                // 広告読み込み
                bannerView.load(GADRequest())

                let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
                multipleAdsOptions.numberOfAds = 5

            }

        
    }

    func catchData(count: Int) {

        if count == 1 {

            bannerView.removeFromSuperview()
        }
        
    }
    //広告UI設定
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
    
    //書き込みの際、タップでキーボード下げる
    @IBAction func tapScreen(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    //書き込みボタン
    @IBAction func write(_ sender: Any) {
        textField.resignFirstResponder()
        if textField.text == nil || textField.text!.isEmpty { return }
        text = textField.text!
        startSession(states: .write)
    }
    
    //スキャン全体
    func startSession(states: States) {
        self.state = states
        guard NFCNDEFReaderSession.readingAvailable else {
            Swift.print("このNFCは使えません")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session?.begin()
    }
    //ストップ時(エラー)
    func stopSession(alert: String = "", error: String = "") {
        session?.alertMessage = alert
        if error.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: error)
        }
        self.state = .standBy
        
    }
    //時間エラー
    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        session?.connect(to: tag) { (error: Error?) in
            if error != nil || !tag.isAvailable {
                self.session?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: DispatchTime.now() + .milliseconds(500), execute: {
                self.tagRemovalDetect(tag)
            })
        }
    }
    //読み込み
    func updateMessage(_ message: NFCNDEFMessage) -> Bool {
        if message.records.isEmpty { return false }
        var results = [String]()
        for record in message.records {
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" { //データ形式がテキストならば
                    let res = record.wellKnownTypeTextPayload()
                    if let text = res.0 {
                        results.append("text: \(text)")
                    }
                } else if type == "U" { //データ形式がURLならば
                    let res = record.wellKnownTypeURIPayload()
                    if let url = res {
                        results.append("url: \(url)")
                    }
                }
            }
        }
        stopSession(alert: "[" + results.joined(separator: ", ") + "]")
        return true
    }
    
}

extension ViewController3: NFCNDEFReaderSessionDelegate {
    
    //無線周波数ポーリングが有効になっており、リーダー セッションがアクティブになり、タグをスキャンしている場合に通知します。
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        //
    }
    
    //メッセージで NFC タグを検出したことをデリゲートに伝えます。(エラー)
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Swift.print(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // not called
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "読み込ませるNFCタグは1枚にしてください．"
            tagRemovalDetect(tags.first!)
            return
        }
        let tag = tags.first!
        session.connect(to: tag) { (error) in
            if error != nil {
                session.restartPolling()
                return
            }
        }
        
        tag.queryNDEFStatus { (status, capacity, error) in
            if status == .notSupported {
                self.stopSession(error: "このNFCタグは対応していません．")
                return
            }
            if self.state == .write {
                if status == .readOnly {
                    self.stopSession(error: "このNFCタグには書き込みできません")
                    return
                }
                if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: self.text, locale: Locale(identifier: "text")) {
                    let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: self.text)!
                    self.message = NFCNDEFMessage(records: [payload, urlPayload])
                    if self.message!.length > capacity {
                        self.stopSession(error: "容量オーバーで書き込めません！\n容量は\(capacity)bytesです．")
                        return
                    }
                    tag.writeNDEF(self.message!) { (error) in
                        if error != nil {
                            // self.printTimestamp()
                            self.stopSession(error: error!.localizedDescription)
                        } else {
                            self.stopSession(alert: "書き込み成功")
                        }
                    }
                }
            }
        }
    }
    //時間
    func printTimestamp() {
        let df = DateFormatter()
        df.timeStyle = .long
        df.dateStyle = .long
        df.locale = Locale.current
        let now = Date()
        Swift.print("Timestamp: ", df.string(from: now))
    }
    
}

//アラート
public extension UIAlertController {
    func show1() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
