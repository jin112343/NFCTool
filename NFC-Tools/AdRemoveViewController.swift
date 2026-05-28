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
    @IBOutlet weak var priceLabel: UILabel!

    private let productID = "8721897482"

    var delegate:CatchProtcol?

    var count:Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        CrashlyticsManager.shared.setCurrentScreen("広告削除画面")
        priceLabel.text = NSLocalizedString("loading", tableName: "Main", comment: "読み込み中...")
        fetchProductPrice()
    }

    /// ストアから価格情報を取得してラベルに表示
    private func fetchProductPrice() {
        SwiftyStoreKit.retrieveProductsInfo([productID]) { [weak self] result in
            guard let self = self else { return }

            if let product = result.retrievedProducts.first {
                // App Storeから取得した価格をそのまま表示
                let priceString = product.localizedPrice ?? "---"
                DispatchQueue.main.async {
                    self.priceLabel.text = priceString
                }
            } else if let error = result.error {
                debugPrint("価格取得エラー: \(error.localizedDescription)")
            }
        }
    }

    @IBAction func removeAdAction(_ sender: Any) {
        CrashlyticsManager.shared.logAction("広告削除購入ボタンタップ")
        purchase(PRODUCT_ID: productID)
    }
    
    
    
    func purchase(PRODUCT_ID: String) {
        SwiftyStoreKit.purchaseProduct(PRODUCT_ID) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success:
                // 購入が成功したとき
                if !KeychainHelper.hasPurchased() {
                    self.count = 1
                    SafeUserDefaults.set(1, forKey: "buy")
                    KeychainHelper.savePurchaseState(1)
                }

                self.verifyPurchase(PRODUCT_ID: PRODUCT_ID)
                self.delegate?.catchData(count: self.count)
                self.navigationController?.popViewController(animated: true)

            case .error(let error):
                switch error.code {
                case .paymentCancelled:
                    // ユーザーがキャンセルした場合は何もしない
                    debugPrint("Purchase cancelled by user")
                default:
                    // その他のエラー
                    debugPrint("Purchase error: \(error.localizedDescription)")
                }

            @unknown default:
                break
            }
        }
    }
    
    func verifyPurchase(PRODUCT_ID: String) {
        // 共有シークレット リストア
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "2db4fa884a054cc8a6ca5131145c9b55")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let receipt):
                let purchaseResult = SwiftyStoreKit.verifyPurchase(productId: PRODUCT_ID, inReceipt: receipt)
                switch purchaseResult {
                case .purchased:
                    // リストア成功
                    self.count = 1
                    SafeUserDefaults.set(1, forKey: "buy")
                    KeychainHelper.savePurchaseState(1)
                case .notPurchased:
                    // リストアされていない場合
                    SafeUserDefaults.removeObject(forKey: "buy")
                    KeychainHelper.removePurchaseState()
                @unknown default:
                    break
                }
            case .error:
                break
            @unknown default:
                break
            }
        }
    }
    
    
    @IBAction func restore(_ sender: Any) {
        
        //リストア機能
        
        SwiftyStoreKit.restorePurchases { [weak self] results in
            guard let self = self else { return }
            if results.restoreFailedPurchases.count > 0{
                //リストア失敗

            }else if results.restoredPurchases.count > 0{
                //リストア成功
                SafeUserDefaults.set(1, forKey: "buy")
                KeychainHelper.savePurchaseState(1)
                self.count = 1
                self.delegate?.catchData(count: self.count)
                self.navigationController?.popViewController(animated: true)
            }else{

                //リストアするものがない
            }
        }
        
    }
    
    
    
    
    
    @IBOutlet weak var bannerView: GADBannerView!
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // 購入済みかチェックして広告を表示/非表示、購入ボタンをグレーアウト
        if KeychainHelper.hasPurchased() {
            bannerView.isHidden = true
            // 購入済みの場合は購入ボタンをグレーアウト
            removeButton.isEnabled = false
            removeButton.alpha = 0.5
            restoreButton.isEnabled = false
            restoreButton.alpha = 0.5
            priceLabel.text = NSLocalizedString("purchased", tableName: "Main", comment: "購入済み")
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
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
