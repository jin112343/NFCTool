import UIKit
import EAIntroView

class TutorialViewController: UIViewController, EAIntroDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アプリが初めて起動されたかどうかを確認する
        checkIfLaunchedBefore()
        
        // 画面の幅を取得
        let width = UIScreen.main.bounds.size.width

        // 端末の現在の言語を取得
        let currentLanguage = Locale.current.languageCode ?? "en"
        
        // チュートリアルページを作成（言語と画面サイズに応じて画像を設定）
        let pages = createIntroPages(forLanguage: currentLanguage, width: width)
        
        // チュートリアルビューを生成し、ページを追加する
        let introView = EAIntroView(frame: self.view.bounds, andPages: pages)
        
        // スキップボタンのタイトルと色を設定する（日本語と英語で異なる表示にする）
        introView?.skipButton.setTitle(currentLanguage == "ja" ? "スキップ" : "Skip", for: .normal)
        introView?.skipButton.setTitleColor(UIColor.systemBlue, for: .normal)
        
        // デリゲートを設定し、チュートリアルを表示する
        introView?.delegate = self
        introView?.show(in: self.view, animateDuration: 1.0)
        
        // チュートリアル表示済みフラグを保存する
        UserDefaults.standard.set(1, forKey: "Tutorial")
    }
    
    // アプリが初めて起動されたかどうかを確認するメソッド
    private func checkIfLaunchedBefore() {
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            UserDefaults.standard.set(true, forKey: "launchedBefore")
            // 初回起動時の処理（例: 初回ユーザー向けの設定やデータ準備など）
        }
    }

    // 言語と画面幅に応じてチュートリアルページを作成するメソッド
    private func createIntroPages(forLanguage language: String, width: CGFloat) -> [EAIntroPage] {
        // 日本語の場合は通常の画像、英語の場合は "-en" が付いた画像を使用する
        let imageSuffix = language == "ja" ? "" : "-en"
        
        // 各ページの画像名を条件に応じて設定する
        let pageImages = [
            width > 1100 ? "nfc1\(imageSuffix)" : "nfc11\(imageSuffix)",
            width > 1100 ? "nfc2\(imageSuffix)" : "nfc22\(imageSuffix)",
            width > 1100 ? "nfc3\(imageSuffix)" : "nfc33\(imageSuffix)",
            width > 1100 ? "nfc4\(imageSuffix)" : "nfc44\(imageSuffix)"
        ]

        // ページを生成し、画像を設定した配列を返す
        return pageImages.map {
            let page = EAIntroPage()
            page.bgImage = UIImage(named: $0)
            return page
        }
    }

    // チュートリアルが終了したときに呼ばれるメソッド（スキップされたかどうかも含む）
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        print("Tutorial finished. Skipped: \(wasSkipped)")
        
        // メイン画面（ViewController）を表示するための処理
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // メイン画面を取得し、ナビゲーションコントローラでラップする
        if let mainVC = storyboard.instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let nav = UINavigationController(rootViewController: mainVC)
            nav.modalPresentationStyle = .fullScreen
            
            // メイン画面をフルスクリーンで表示する
            self.present(nav, animated: true, completion: nil)
        }
    }
}
