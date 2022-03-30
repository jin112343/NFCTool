//
//  TutorialViewController.swift
//  NFC-Tools
//
//  Created by 溝井迅 on 2022/03/17.
//  Copyright © 2022 Jin Mizoi. All rights reserved.
//
import UIKit
import EAIntroView
class TutorialViewController: UIViewController, EAIntroDelegate {


        override func viewDidLoad() {
        super.viewDidLoad()
        
        _ = UserDefaults.standard.bool(forKey: "launchedBefore")
        let page1 = EAIntroPage()
        page1.bgImage = UIImage(named: "nfc1")
         
        let page2 = EAIntroPage()
        page2.bgImage = UIImage(named: "nfc2")
         
        let page3 = EAIntroPage()
        page3.bgImage = UIImage(named: "nfc3")
        
        let page4 = EAIntroPage()
        page4.bgImage = UIImage(named: "nfc4")
         
        //ここでページを追加
        let introView = EAIntroView(frame: self.view.bounds, andPages:  [page1, page2, page3, page4])
        //スキップボタン
        introView?.skipButton.setTitle("スキップ", for: UIControl.State.normal)
        //スキップボタンの色変更
        introView?.skipButton.setTitleColor(UIColor.systemBlue, for: UIControl.State.normal)
        
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 1.0)
        
        UserDefaults.standard.set(1, forKey: "Tutorial")

}
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        print("test",wasSkipped)
        let storybord = UIStoryboard(name: "Main", bundle: nil)
               let mainVC = storybord.instantiateViewController(withIdentifier: "ViewController")
        

        let nav = UINavigationController(rootViewController: mainVC)
        nav.modalPresentationStyle = .fullScreen
               self.present(nav, animated: true, completion: nil)
    }
}
