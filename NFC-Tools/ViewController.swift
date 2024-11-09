import UIKit
import CoreNFC
import GoogleMobileAds

enum State {
    case standBy
    case read
    case write
    case delete
}

class ViewController: UIViewController, GADBannerViewDelegate, CatchProtcol {
    
    // MARK: - IBOutlets
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var eraseBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!
    
    // MARK: - Properties
    var session: NFCNDEFReaderSession?
    var message: NFCNDEFMessage?
    var state: State = .standBy
    var text: String = ""
    
    // MARK: - Lifecycle Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstLaunch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAdvertisement()
    }
    
    // MARK: - Setup Methods
    private func checkFirstLaunch() {
        let ud = UserDefaults.standard
        let firstLunchKey = "firstLunch"
        if ud.bool(forKey: firstLunchKey) {
            ud.set(false, forKey: firstLunchKey)
            ud.synchronize()
            self.performSegue(withIdentifier: "nfc", sender: nil)
        }
    }
    
    private func setupAdvertisement() {
        if let count = UserDefaults.standard.object(forKey: "buy") as? Int,
           count == 1 {
            bannerView.removeFromSuperview()
        } else {
            bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    
    // MARK: - NFC Methods
    func startSession(state: State) {
        self.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            Swift.print("このNFCは使えません")
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = "NFCタグをiPhone上部に近づけてください"
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
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.tagRemovalDetect(tag)
            }
        }
    }
    
    func updateMessage(_ message: NFCNDEFMessage) -> Bool {
        if message.records.isEmpty { return false }
        var results = [String]()
        for record in message.records {
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" {
                    let res = record.wellKnownTypeTextPayload()
                    if let text = res.0 {
                        results.append("text: \(text)")
                    }
                } else if type == "U" {
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
    
    // MARK: - IBActions
    @IBAction func Erase(_ sender: Any) {
        startSession(state: .delete)
    }
    
    @IBAction func resetMode(_ sender: Any) {
        startSession(state: .read)
    }
    
    // MARK: - CatchProtcol
    func catchData(count: Int) {
        if count == 1 {
            bannerView.removeFromSuperview()
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Session became active
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        Swift.print(error.localizedDescription)
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Not called directly
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = "読み込ませるNFCタグは1枚にしてください"
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
                self.stopSession(error: "このNFCタグは対応していません")
                return
            }
            
            switch self.state {
            case .read:
                self.handleReadOperation(tag)
            case .delete:
                self.handleDeleteOperation(tag, status: status, capacity: capacity)
            default:
                break
            }
        }
    }
    
    private func handleReadOperation(_ tag: NFCNDEFTag) {
        tag.readNDEF { (message, error) in
            if error != nil || message == nil {
                self.stopSession(error: error!.localizedDescription)
                return
            }
            if !self.updateMessage(message!) {
                self.stopSession(error: "このNFCタグは対応していません")
            }
        }
    }
    
    private func handleDeleteOperation(_ tag: NFCNDEFTag, status: NFCNDEFStatus, capacity: Int) {
        tag.readNDEF { (message, error) in
            if error != nil || message == nil {
                self.stopSession(error: error!.localizedDescription)
                return
            }
            
            guard let message = message, !message.records.isEmpty else { return }
            
            let results = self.parseRecords(message.records)
            let msg = "[" + results.joined(separator: ", ") + "]"
            self.session?.alertMessage = "下記の情報を削除します、NFCタグを動かないでください \n\n \(msg)"
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if status == .readOnly {
                    self.stopSession(error: "このNFCタグには書き込みできません")
                    return
                }
                self.performDelete(tag, capacity: capacity)
            }
        }
    }
    
    private func parseRecords(_ records: [NFCNDEFPayload]) -> [String] {
        var results = [String]()
        for record in records {
            if let type = String(data: record.type, encoding: .utf8) {
                if type == "T" {
                    if let text = record.wellKnownTypeTextPayload().0 {
                        results.append("text: \(text)")
                    }
                } else if type == "U" {
                    if let url = record.wellKnownTypeURIPayload() {
                        results.append("url: \(url)")
                    }
                }
            }
        }
        return results
    }
    
    private func performDelete(_ tag: NFCNDEFTag, capacity: Int) {
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: " ",
                                                                   locale: Locale(identifier: "text")),
              let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: " ") else {
            self.stopSession(error: "ペイロードの作成に失敗しました")
            return
        }
        
        self.message = NFCNDEFMessage(records: [payload, urlPayload])
        
        guard let message = self.message else { return }
        
        if message.length > capacity {
            self.stopSession(error: "容量オーバーで書き込めません！\n容量は\(capacity)bytesです")
            return
        }
        
        tag.writeNDEF(message) { (error) in
            if let error = error {
                self.stopSession(error: error.localizedDescription)
            } else {
                self.stopSession(alert: "削除しました")
            }
        }
    }
}
