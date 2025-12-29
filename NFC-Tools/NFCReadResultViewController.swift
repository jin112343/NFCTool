import UIKit
import CoreNFC
import GoogleMobileAds
import OSLog

// MARK: - NFC読み取り結果データモデル
struct NFCReadResult {
    var tagType: String              // タグの種類（NDEF, FeliCa, ISO7816, MiFare等）
    var tagIdentifier: String?       // タグのUID/識別子
    var capacity: Int                // 容量（bytes）
    var usedSize: Int                // 使用サイズ
    var freeSpace: Int               // 空き容量
    var isWritable: Bool             // 書き込み可能か
    var ndefStatus: String           // NDEFステータス（notSupported, readOnly, readWrite）
    var records: [NFCRecordInfo]     // 各レコードの情報
    var felicaBalance: Int?          // FeliCa残高（交通系IC）
    var felicaSystemCode: String?    // FeliCaシステムコード
    var rawPayloadData: [Data]       // 生データ

    init() {
        self.tagType = "Unknown"
        self.tagIdentifier = nil
        self.capacity = 0
        self.usedSize = 0
        self.freeSpace = 0
        self.isWritable = false
        self.ndefStatus = "unknown"
        self.records = []
        self.felicaBalance = nil
        self.felicaSystemCode = nil
        self.rawPayloadData = []
    }
}

// MARK: - NFCレコード情報
struct NFCRecordInfo {
    var recordIndex: Int             // レコード番号
    var tnf: String                  // Type Name Format
    var type: String                 // タイプ（T, U等）
    var identifier: String           // 識別子
    var payloadType: String          // ペイロードの種類（テキスト、URL、その他）
    var textContent: String?         // テキスト内容
    var urlContent: URL?             // URL内容
    var locale: String?              // テキストのロケール
    var payloadSize: Int             // ペイロードサイズ
    var rawPayload: Data             // 生のペイロードデータ
}

// MARK: - NFCReadResultViewController
class NFCReadResultViewController: UIViewController {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "NFCReadResult")

    // MARK: - Properties
    var readResult: NFCReadResult?
    private var tableView: UITableView!
    private var bannerView: GADBannerView!

    // セクション定義
    private enum Section: Int, CaseIterable {
        case tagInfo = 0
        case records
        case felica
        case rawData

        var title: String {
            switch self {
            case .tagInfo: return NSLocalizedString("result_section_tag_info", comment: "タグ情報")
            case .records: return NSLocalizedString("result_section_records", comment: "レコード")
            case .felica: return NSLocalizedString("result_section_felica", comment: "FeliCa情報")
            case .rawData: return NSLocalizedString("result_section_raw", comment: "生データ")
            }
        }
    }

    // 多言語対応メッセージ
    private let localizedMessages: [String: [String: String]] = [
        "ja": [
            "result_title": "読み取り結果",
            "result_section_tag_info": "タグ情報",
            "result_section_records": "レコード",
            "result_section_felica": "FeliCa情報",
            "result_section_raw": "生データ",
            "tag_type": "タグ種類",
            "tag_id": "タグID",
            "capacity": "容量",
            "used_size": "使用サイズ",
            "free_space": "空き容量",
            "writable": "書き込み",
            "writable_yes": "可能",
            "writable_no": "読み取り専用",
            "ndef_status": "NDEFステータス",
            "record_number": "レコード #%d",
            "record_type": "タイプ",
            "record_tnf": "TNF",
            "record_text": "テキスト",
            "record_url": "URL",
            "record_locale": "言語",
            "record_size": "サイズ",
            "felica_balance": "残高",
            "felica_system": "システムコード",
            "bytes": "%d bytes",
            "yen": "¥%d",
            "no_data": "データなし",
            "tap_to_open": "タップしてリンクを開く"
        ],
        "en": [
            "result_title": "Read Result",
            "result_section_tag_info": "Tag Information",
            "result_section_records": "Records",
            "result_section_felica": "FeliCa Information",
            "result_section_raw": "Raw Data",
            "tag_type": "Tag Type",
            "tag_id": "Tag ID",
            "capacity": "Capacity",
            "used_size": "Used Size",
            "free_space": "Free Space",
            "writable": "Writable",
            "writable_yes": "Yes",
            "writable_no": "Read Only",
            "ndef_status": "NDEF Status",
            "record_number": "Record #%d",
            "record_type": "Type",
            "record_tnf": "TNF",
            "record_text": "Text",
            "record_url": "URL",
            "record_locale": "Locale",
            "record_size": "Size",
            "felica_balance": "Balance",
            "felica_system": "System Code",
            "bytes": "%d bytes",
            "yen": "¥%d",
            "no_data": "No Data",
            "tap_to_open": "Tap to open link"
        ]
    ]

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupAdvertisement()
    }

    // MARK: - Setup
    private func setupUI() {
        title = getLocalizedMessage(key: "result_title")
        view.backgroundColor = .systemBackground
    }

    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.register(SubtitleCell.self, forCellReuseIdentifier: "SubtitleCell")
        view.addSubview(tableView)

        // 広告バナー用のスペースを確保
        let bannerHeight: CGFloat = 50

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -bannerHeight)
        ])
    }

    private func setupAdvertisement() {
        if let count = UserDefaults.standard.object(forKey: "buy") as? Int, count == 1 {
            return
        }

        bannerView = GADBannerView(adSize: GADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
        bannerView.rootViewController = self
        view.addSubview(bannerView)

        NSLayoutConstraint.activate([
            bannerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bannerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bannerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        bannerView.load(GADRequest())
    }

    // MARK: - Localization
    private func getLocalizedMessage(key: String) -> String {
        let currentLanguage: String
        if #available(iOS 16, *) {
            currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            currentLanguage = Locale.current.languageCode ?? "en"
        }
        return localizedMessages[currentLanguage]?[key]
            ?? localizedMessages["en"]?[key]
            ?? key
    }

    // MARK: - Helper Methods
    private func getTNFDescription(_ tnf: String) -> String {
        switch tnf {
        case "empty": return "Empty"
        case "nfcWellKnown": return "NFC Well Known"
        case "media": return "Media Type"
        case "absoluteURI": return "Absolute URI"
        case "nfcExternal": return "NFC External"
        case "unknown": return "Unknown"
        case "unchanged": return "Unchanged"
        default: return tnf
        }
    }
}

// MARK: - UITableViewDataSource
extension NFCReadResultViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let result = readResult else { return 0 }
        var count = 2 // タグ情報 + レコード
        if result.felicaBalance != nil || result.felicaSystemCode != nil {
            count += 1 // FeliCa情報
        }
        if !result.rawPayloadData.isEmpty {
            count += 1 // 生データ
        }
        return count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let result = readResult else { return nil }

        switch section {
        case 0:
            return getLocalizedMessage(key: "result_section_tag_info")
        case 1:
            return getLocalizedMessage(key: "result_section_records")
        case 2:
            if result.felicaBalance != nil || result.felicaSystemCode != nil {
                return getLocalizedMessage(key: "result_section_felica")
            } else {
                return getLocalizedMessage(key: "result_section_raw")
            }
        case 3:
            return getLocalizedMessage(key: "result_section_raw")
        default:
            return nil
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let result = readResult else { return 0 }

        switch section {
        case 0: // タグ情報
            return 6 // タイプ、ID、容量、使用サイズ、空き、書き込み可否
        case 1: // レコード
            return result.records.isEmpty ? 1 : result.records.count * 5 // 各レコードに5行
        case 2: // FeliCaまたは生データ
            if result.felicaBalance != nil || result.felicaSystemCode != nil {
                return 2 // 残高、システムコード
            } else {
                return result.rawPayloadData.count
            }
        case 3: // 生データ
            return result.rawPayloadData.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let result = readResult else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! SubtitleCell
        cell.selectionStyle = .none

        switch indexPath.section {
        case 0: // タグ情報
            configureTagInfoCell(cell, row: indexPath.row, result: result)
        case 1: // レコード
            configureRecordCell(cell, row: indexPath.row, result: result)
        case 2: // FeliCaまたは生データ
            if result.felicaBalance != nil || result.felicaSystemCode != nil {
                configureFeliCaCell(cell, row: indexPath.row, result: result)
            } else {
                configureRawDataCell(cell, row: indexPath.row, result: result)
            }
        case 3: // 生データ
            configureRawDataCell(cell, row: indexPath.row, result: result)
        default:
            break
        }

        return cell
    }

    private func configureTagInfoCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        switch row {
        case 0:
            cell.textLabel?.text = getLocalizedMessage(key: "tag_type")
            cell.detailTextLabel?.text = result.tagType
        case 1:
            cell.textLabel?.text = getLocalizedMessage(key: "tag_id")
            cell.detailTextLabel?.text = result.tagIdentifier ?? "-"
        case 2:
            cell.textLabel?.text = getLocalizedMessage(key: "capacity")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes"), result.capacity)
        case 3:
            cell.textLabel?.text = getLocalizedMessage(key: "used_size")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes"), result.usedSize)
        case 4:
            cell.textLabel?.text = getLocalizedMessage(key: "free_space")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes"), result.freeSpace)
        case 5:
            cell.textLabel?.text = getLocalizedMessage(key: "writable")
            cell.detailTextLabel?.text = result.isWritable ?
                getLocalizedMessage(key: "writable_yes") :
                getLocalizedMessage(key: "writable_no")
            cell.detailTextLabel?.textColor = result.isWritable ? .systemGreen : .systemRed
        default:
            break
        }
    }

    private func configureRecordCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        if result.records.isEmpty {
            cell.textLabel?.text = getLocalizedMessage(key: "no_data")
            cell.detailTextLabel?.text = nil
            return
        }

        let recordIndex = row / 5
        let fieldIndex = row % 5

        guard recordIndex < result.records.count else { return }
        let record = result.records[recordIndex]

        switch fieldIndex {
        case 0:
            cell.textLabel?.text = String(format: getLocalizedMessage(key: "record_number"), recordIndex + 1)
            cell.detailTextLabel?.text = record.payloadType
            cell.textLabel?.font = .boldSystemFont(ofSize: 16)
        case 1:
            cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_type")
            cell.detailTextLabel?.text = record.type.isEmpty ? "-" : record.type
        case 2:
            cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_tnf")
            cell.detailTextLabel?.text = getTNFDescription(record.tnf)
        case 3:
            if let text = record.textContent {
                cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_text")
                cell.detailTextLabel?.text = text
                cell.detailTextLabel?.numberOfLines = 0
            } else if let url = record.urlContent {
                cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_url")
                cell.detailTextLabel?.text = url.absoluteString
                cell.detailTextLabel?.textColor = .systemBlue
                cell.accessoryType = .disclosureIndicator
                cell.selectionStyle = .default
            } else {
                cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_size")
                cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes"), record.payloadSize)
            }
        case 4:
            cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_size")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes"), record.payloadSize)
        default:
            break
        }
    }

    private func configureFeliCaCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        switch row {
        case 0:
            cell.textLabel?.text = getLocalizedMessage(key: "felica_balance")
            if let balance = result.felicaBalance {
                cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "yen"), balance)
                cell.detailTextLabel?.textColor = .systemGreen
                cell.detailTextLabel?.font = .boldSystemFont(ofSize: 20)
            } else {
                cell.detailTextLabel?.text = "-"
            }
        case 1:
            cell.textLabel?.text = getLocalizedMessage(key: "felica_system")
            cell.detailTextLabel?.text = result.felicaSystemCode ?? "-"
        default:
            break
        }
    }

    private func configureRawDataCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        guard row < result.rawPayloadData.count else { return }
        let data = result.rawPayloadData[row]
        cell.textLabel?.text = "Payload \(row + 1)"
        cell.detailTextLabel?.text = data.map { String(format: "%02X", $0) }.joined(separator: " ")
        cell.detailTextLabel?.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        cell.detailTextLabel?.numberOfLines = 0
    }
}

// MARK: - UITableViewDelegate
extension NFCReadResultViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let result = readResult, indexPath.section == 1 else { return }

        let recordIndex = indexPath.row / 5
        let fieldIndex = indexPath.row % 5

        guard recordIndex < result.records.count, fieldIndex == 3 else { return }
        let record = result.records[recordIndex]

        if let url = record.urlContent {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - SubtitleCell
class SubtitleCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
        detailTextLabel?.textColor = .secondaryLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        textLabel?.text = nil
        textLabel?.font = .systemFont(ofSize: 17)
        detailTextLabel?.text = nil
        detailTextLabel?.textColor = .secondaryLabel
        detailTextLabel?.font = .systemFont(ofSize: 17)
        detailTextLabel?.numberOfLines = 1
        accessoryType = .none
        selectionStyle = .none
    }
}
