//
//  ViewController3.swift
//  NFC-Tools
//
//  Created by 溝井迅 on 2022/03/18.
//  Copyright © 2022 Jin Mizoi. All rights reserved.
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

class ViewController3: UIViewController, GADBannerViewDelegate {
    

    //ボタン設定
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var writeBtn: UIButton!
    
    @IBOutlet weak var mediaView: GADMediaView!
    
    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: State = .standBy
    var text: String = ""
    var deleting = false
    var adLoader: GADAdLoader!
    
    
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

      

            adLoader = GADAdLoader(adUnitID:"ca-app-pub-1187210314934709/1149830919", rootViewController: self,
                adTypes: [.native],
                options: [multipleAdsOptions])
            adLoader.delegate = self
            adLoader.load(GADRequest())

      }
    func adLoader(_ adLoader: GADAdLoader,
                    didReceive nativeAd: GADNativeAd) {
        // A native ad has loaded, and can be displayed.
      }

      func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
          // The adLoader has finished loading ads, and a new request can be sent.
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
}

