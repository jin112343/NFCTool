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


enum State {
    case standBy
    case read
    case write
    case delete
}

class ViewController: UIViewController, GADBannerViewDelegate {
    
    
    //ボタン設定
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var writeBtn: UIButton!
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var eraseBtn : UIButton!

    @IBOutlet weak var bannerView: GADBannerView!
    
   
    
    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: State = .standBy
    var text: String = ""
    var deleting = false
    
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)

            //この下の7行を追加
            let ud = UserDefaults.standard
            let firstLunchKey = "firstLunch"
            if ud.bool(forKey: firstLunchKey) {
                ud.set(false, forKey: firstLunchKey)
                ud.synchronize()
                self.performSegue(withIdentifier: "nfc", sender: nil)
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
    
   
    
    @IBAction func tapScreen(_ sender: Any) {
        textField.resignFirstResponder()
    }
    
    @IBAction func write(_ sender: Any) {
        textField.resignFirstResponder()
        if textField.text == nil || textField.text!.isEmpty { return }
        text = textField.text!
        startSession(state: .write)
    }
    
    @IBAction func Erase(_ sender: Any) {
        //deleting = true
        startSession(state: .delete)
    }
    
    
    
    @IBAction func resetMode(_ sender: Any) {
         startSession(state: .read)
    }
    func resetMode(completionHandler: @escaping (Int, Int, Error?) -> Void) {
        
    }
    
    func startSession(state: State) {
        self.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            Swift.print("このNFCは使えません")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "NFCタグをiPhone上部に近づけてください．"
        session?.begin()
    }
    
    func stopSession(alert: String = "", error: String = "") {
        session?.alertMessage = alert
        if error.isEmpty {
            session?.invalidate()
        } else {
            session?.invalidate(errorMessage: error)
        }
        self.state = .standBy
        
    }
    
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

extension ViewController: NFCNDEFReaderSessionDelegate {
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        //
    }
    
    
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
            } else if self.state == .read {
                tag.readNDEF { (message, error) in
                    if error != nil || message == nil {
                        self.stopSession(error: error!.localizedDescription)
                        return
                    }
                    if !self.updateMessage(message!) {
                        self.stopSession(error: "このNFCタグは対応していません．")
                    }
                }
            } else if self.state == .delete {
                
                tag.readNDEF { (message, error) in
                    if error != nil || message == nil {
                        self.stopSession(error: error!.localizedDescription)
                        return
                    }

                    if (!message!.records.isEmpty){
                        var results = [String]()
                        for record in message!.records {
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
                        
                        let msg = "[" + results.joined(separator: ", ") + "]"
                        self.session?.alertMessage = "下記の情報を削除します、NFCタグを動かないでください \n\n \(msg)"
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            if status == .readOnly {
                                self.stopSession(error: "このNFCタグには書き込みできません")
                                return
                            }
                            if let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: " ", locale: Locale(identifier: "text")) {
                                let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: " ")!
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
                                        self.stopSession(alert: "削除しました")
                                    }
                                }
                            }
                            
                        }
    
                    }
 
                    
                }
                
            }
        }
    }
    
    func printTimestamp() {
        let df = DateFormatter()
        df.timeStyle = .long
        df.dateStyle = .long
        df.locale = Locale.current
        let now = Date()
        Swift.print("Timestamp: ", df.string(from: now))
    }
    
}


public extension UIAlertController {
    func show() {
        let win = UIWindow(frame: UIScreen.main.bounds)
        let vc = UIViewController()
        vc.view.backgroundColor = .clear
        win.rootViewController = vc
        win.windowLevel = UIWindow.Level.alert + 1  // Swift 3-4: UIWindowLevelAlert + 1
        win.makeKeyAndVisible()
        vc.present(self, animated: true, completion: nil)
    }
}
