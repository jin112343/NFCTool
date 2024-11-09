//
//  AdRemoveViewController.swift
//  NFC-Tools
//
//  Created by 溝井迅 on 2022/09/20.
//  Copyright © 2022 Jin Mizoi. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyStoreKit

protocol CatchProtcol {
    
    func catchData(count:Int)
    
}

class AdRemoveViewController: UIViewController,GADBannerViewDelegate {
    
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    
    var delegate:CatchProtcol?
    
    var count:Int = 0
    
    @IBAction func removeAdAction(_ sender: Any) {
        
        purchase(PRODUCT_ID: "8721897482")
    }
    
    
    
    func purchase(PRODUCT_ID:String){
        
        SwiftyStoreKit.purchaseProduct(PRODUCT_ID) { (result) in
            
            switch result{
                
            case .success(_):
                
                //ここに書く
                //購入が成功したとき
                
                if UserDefaults.standard.object(forKey: "buy") != nil{
                    _ = UserDefaults.standard.object(forKey: "buy") as! Int
                    
                }else{
                    
                    self.count = 1

                    UserDefaults.standard.set(1, forKey: "buy")
                }
                
                
                self.verifyPurchase(PRODUCT_ID:PRODUCT_ID)
                
                self.delegate?.catchData(count: self.count)
                self.navigationController?.popViewController(animated: true)
                
                break
            case .error(let error):
                print(error)
                
                break
            }
            
            
        }
        
        
    }
    
    func verifyPurchase(PRODUCT_ID:String){
        //共有シークレット リストア
        let appeValidator = AppleReceiptValidator(service: .production, sharedSecret: "2db4fa884a054cc8a6ca5131145c9b55")
        SwiftyStoreKit.verifyReceipt(using: appeValidator) { (result) in
            
            switch result{
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: PRODUCT_ID, inReceipt: receipt)
                switch purchaseResult{
                case.purchased:
                    //リストア成功
                    self.count = 1
                    UserDefaults.standard.set(1, forKey: "buy")
                    break
                case .notPurchased:
                    //リストアされていない場合
                    
                    UserDefaults.standard.set(nil, forKey: "buy")
                    break
                    
                }
            case .error(_):
                break
            }
            
        }
        
        
    }
    
    
    @IBAction func restore(_ sender: Any) {
        
        //リストア機能
        
        SwiftyStoreKit.restorePurchases { (results) in
            if results.restoreFailedPurchases.count > 0{
                //リストア失敗
                
            }else if results.restoredPurchases.count > 0{
                //リストア成功
                UserDefaults.standard.set(1, forKey: "buy")
                self.count =  1
                self.navigationController?.popViewController(animated: true)
            }else{
                
                //リストアするものがない
            }
        }
        
    }
    
    
    
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //もしbuyというキー値に1という数字が入っていたら
        //購入済み = 広告を排除
        
        if UserDefaults.standard.object(forKey: "buy") != nil{
              let count  = UserDefaults.standard.object(forKey: "buy") as! Int
            if count == 1{
                
                bannerView.removeFromSuperview()
                
                
                
                
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
