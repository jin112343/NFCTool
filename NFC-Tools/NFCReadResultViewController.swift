import UIKit
import CoreNFC
import GoogleMobileAds
import OSLog

// MARK: - NFC読み取り結果データモデル
struct NFCReadResult: Codable {
    var tagType: String              // タグの種類（NDEF, FeliCa, ISO7816, MiFare等）
    var tagIdentifier: String?       // タグのUID/識別子
    var capacity: Int                // 容量（bytes）
    var usedSize: Int                // 使用サイズ
    var freeSpace: Int               // 空き容量
    var isWritable: Bool             // 書き込み可能か
    var ndefStatus: String           // NDEFステータス（notSupported, readOnly, readWrite）
    var records: [NFCRecordInfo]     // 各レコードの情報
    var felicaBalance: Int?          // FeliCa残高（交通系IC・電子マネー）
    var felicaCardType: String?      // FeliCaカード種別（交通系IC, 楽天Edy, nanaco, WAON 等）
    var felicaSystemCode: String?    // FeliCaシステムコード
    var felicaHistories: [FeliCaHistoryEntry]  // FeliCa利用履歴
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
        self.felicaCardType = nil
        self.felicaSystemCode = nil
        self.felicaHistories = []
        self.rawPayloadData = []
    }
}

// MARK: - FeliCa利用履歴エントリ
struct FeliCaHistoryEntry: Codable {
    var index: Int                   // 履歴インデックス（0が最新）
    var terminalType: UInt8          // 端末種
    var processType: UInt8           // 処理種
    var entryStationCode: Int        // 入場駅コード
    var exitStationCode: Int         // 出場駅コード
    var balance: Int                 // 残高
    var year: Int                    // 年
    var month: Int                   // 月
    var day: Int                     // 日
    var sequenceNumber: Int          // 通番
    var regionCode: UInt8            // 地域コード

    enum CodingKeys: String, CodingKey {
        case index, terminalType, processType, entryStationCode, exitStationCode
        case balance, year, month, day, sequenceNumber, regionCode
    }

    var dateString: String {
        return String(format: "%04d/%02d/%02d", year, month, day)
    }

    var terminalTypeName: String {
        switch terminalType {
        case 0x03: return NSLocalizedString("terminal_fare_machine", tableName: "Main", comment: "精算機")
        case 0x04: return NSLocalizedString("terminal_mobile", tableName: "Main", comment: "携帯電話")
        case 0x05: return NSLocalizedString("terminal_ticket_machine", tableName: "Main", comment: "券売機")
        case 0x07: return NSLocalizedString("terminal_ticket_machine_commuter", tableName: "Main", comment: "券売機(定期)")
        case 0x08: return NSLocalizedString("terminal_ticket_machine", tableName: "Main", comment: "券売機")
        case 0x09: return NSLocalizedString("terminal_charge_machine", tableName: "Main", comment: "入金機")
        case 0x12: return NSLocalizedString("terminal_auto_ticket_machine", tableName: "Main", comment: "自動券売機")
        case 0x14: return NSLocalizedString("terminal_gate", tableName: "Main", comment: "改札機")
        case 0x15: return NSLocalizedString("terminal_auto_fare_machine", tableName: "Main", comment: "自動精算機")
        case 0x16: return NSLocalizedString("terminal_gate", tableName: "Main", comment: "改札機")
        case 0x17: return NSLocalizedString("terminal_simple_gate", tableName: "Main", comment: "簡易改札機")
        case 0x18, 0x19, 0x1A, 0x1B, 0x1F: return NSLocalizedString("terminal_counter", tableName: "Main", comment: "窓口")
        case 0x1C, 0x1D: return NSLocalizedString("terminal_auto_fare_machine", tableName: "Main", comment: "自動精算機")
        case 0x46, 0x48: return "VIEW ALTTE"
        case 0xC7, 0xC8: return NSLocalizedString("terminal_retail", tableName: "Main", comment: "物販")
        default: return NSLocalizedString("terminal_default", tableName: "Main", comment: "端末")
        }
    }

    var processTypeName: String {
        switch processType {
        case 0x01: return NSLocalizedString("process_fare_payment", tableName: "Main", comment: "運賃支払")
        case 0x02: return NSLocalizedString("process_charge", tableName: "Main", comment: "チャージ")
        case 0x03: return NSLocalizedString("process_commuter_pass", tableName: "Main", comment: "定期購入")
        case 0x04, 0x05: return NSLocalizedString("process_fare_adjustment", tableName: "Main", comment: "精算")
        case 0x06: return NSLocalizedString("process_counter_exit", tableName: "Main", comment: "窓口出場")
        case 0x07: return NSLocalizedString("process_new_issue", tableName: "Main", comment: "新規発行")
        case 0x08: return NSLocalizedString("process_deduction", tableName: "Main", comment: "控除")
        case 0x0C: return NSLocalizedString("process_counter_entry", tableName: "Main", comment: "窓口入場")
        case 0x0D: return NSLocalizedString("process_bus_charge", tableName: "Main", comment: "バス入金")
        case 0x0F: return NSLocalizedString("process_bus_payment", tableName: "Main", comment: "バス支払")
        case 0x11: return NSLocalizedString("process_reissue", tableName: "Main", comment: "再発行")
        case 0x13: return NSLocalizedString("process_payment_refund", tableName: "Main", comment: "支払/払戻")
        case 0x14: return NSLocalizedString("process_charge_commuter", tableName: "Main", comment: "入金/定期")
        case 0x15: return NSLocalizedString("process_ticket_counter", tableName: "Main", comment: "券売窓口")
        case 0x1F, 0x49, 0x4A, 0xCB: return NSLocalizedString("process_deposit", tableName: "Main", comment: "入金")
        case 0x23: return NSLocalizedString("process_counter", tableName: "Main", comment: "窓口")
        case 0x46: return NSLocalizedString("process_retail", tableName: "Main", comment: "物販")
        case 0x48: return NSLocalizedString("process_retail_bonus", tableName: "Main", comment: "物販特典")
        case 0x4B: return NSLocalizedString("process_retail_cancel", tableName: "Main", comment: "物販取消")
        case 0xC6: return NSLocalizedString("process_cash_combined", tableName: "Main", comment: "現金併用")
        case 0x84, 0x85: return NSLocalizedString("process_transfer_adjustment", tableName: "Main", comment: "他社精算")
        default: return NSLocalizedString("process_default", tableName: "Main", comment: "処理")
        }
    }
}

// MARK: - NFCレコード情報
struct NFCRecordInfo: Codable {
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
        case felica
        case history
        case records
        case rawData

        var title: String {
            switch self {
            case .tagInfo: return NSLocalizedString("result_section_tag_info", tableName: "Main", comment: "タグ情報")
            case .felica: return NSLocalizedString("result_section_felica", tableName: "Main", comment: "FeliCa情報")
            case .history: return NSLocalizedString("result_section_history", tableName: "Main", comment: "利用履歴")
            case .records: return NSLocalizedString("result_section_records", tableName: "Main", comment: "レコード")
            case .rawData: return NSLocalizedString("result_section_raw", tableName: "Main", comment: "生データ")
            }
        }
    }


    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        CrashlyticsManager.shared.setCurrentScreen("NFC読取結果画面")
        setupUI()
        setupTableView()
        setupAdvertisement()

        // デバッグログ
        if let result = readResult {
            logger.info("NFCReadResultViewController - Balance: \(result.felicaBalance ?? -1), SystemCode: \(result.felicaSystemCode ?? "nil"), Histories: \(result.felicaHistories.count)")
        } else {
            logger.error("NFCReadResultViewController - readResult is nil!")
        }
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
        if KeychainHelper.hasPurchased() {
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
        return NSLocalizedString(key, tableName: "Main", comment: "")
    }

    // MARK: - Helper Methods

    private func formatCurrency(_ amount: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        let formattedNumber = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return "¥\(formattedNumber)"
    }

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

    // 動的にセクションを決定するヘルパー
    private func getVisibleSections() -> [Section] {
        guard let result = readResult else { return [] }
        var sections: [Section] = [.tagInfo]

        // FeliCa情報（残高がある場合）
        if result.felicaBalance != nil || result.felicaSystemCode != nil {
            sections.append(.felica)
        }

        // 利用履歴（履歴がある場合）
        if !result.felicaHistories.isEmpty {
            sections.append(.history)
        }

        // NDEFレコード（レコードがある場合）
        if !result.records.isEmpty {
            sections.append(.records)
        }

        // 生データ（データがある場合）
        if !result.rawPayloadData.isEmpty {
            sections.append(.rawData)
        }

        return sections
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return getVisibleSections().count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sections = getVisibleSections()
        guard section < sections.count else { return nil }

        switch sections[section] {
        case .tagInfo:
            return getLocalizedMessage(key: "result_section_tag_info")
        case .felica:
            return getLocalizedMessage(key: "result_section_felica")
        case .history:
            return getLocalizedMessage(key: "result_section_history")
        case .records:
            return getLocalizedMessage(key: "result_section_records")
        case .rawData:
            return getLocalizedMessage(key: "result_section_raw")
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let result = readResult else { return 0 }
        let sections = getVisibleSections()
        guard section < sections.count else { return 0 }

        switch sections[section] {
        case .tagInfo:
            return 6 // タイプ、ID、容量、使用サイズ、空き、書き込み可否
        case .felica:
            return 3 // カード種別、残高、システムコード
        case .history:
            return result.felicaHistories.count
        case .records:
            return result.records.isEmpty ? 1 : result.records.count * 5 // 各レコードに5行
        case .rawData:
            return result.rawPayloadData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let result = readResult else {
            return UITableViewCell()
        }

        let sections = getVisibleSections()
        guard indexPath.section < sections.count else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as? SubtitleCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none

        switch sections[indexPath.section] {
        case .tagInfo:
            configureTagInfoCell(cell, row: indexPath.row, result: result)
        case .felica:
            configureFeliCaCell(cell, row: indexPath.row, result: result)
        case .history:
            configureHistoryCell(cell, row: indexPath.row, result: result)
        case .records:
            configureRecordCell(cell, row: indexPath.row, result: result)
        case .rawData:
            configureRawDataCell(cell, row: indexPath.row, result: result)
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
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes_format"), result.capacity)
        case 3:
            cell.textLabel?.text = getLocalizedMessage(key: "used_size")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes_format"), result.usedSize)
        case 4:
            cell.textLabel?.text = getLocalizedMessage(key: "free_space")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes_format"), result.freeSpace)
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
            } else if let rawText = String(data: record.rawPayload, encoding: .utf8)?
                        .trimmingCharacters(in: .controlCharacters),
                      !rawText.isEmpty {
                // テキスト/URLがない場合、生データをテキストとして表示試行
                cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_text")
                cell.detailTextLabel?.text = rawText
                cell.detailTextLabel?.numberOfLines = 0
            } else {
                // テキスト/URL/生データのいずれも無い場合は内容行をプレースホルダ表示
                // （サイズは case 4 で表示するため、ここで重複表示しない）
                cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_text")
                cell.detailTextLabel?.text = "-"
            }
        case 4:
            cell.textLabel?.text = "  " + getLocalizedMessage(key: "record_size")
            cell.detailTextLabel?.text = String(format: getLocalizedMessage(key: "bytes_format"), record.payloadSize)
        default:
            break
        }
    }

    private func configureFeliCaCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        switch row {
        case 0:
            cell.textLabel?.text = getLocalizedMessage(key: "felica_card_type")
            cell.detailTextLabel?.text = result.felicaCardType ?? "-"
        case 1:
            cell.textLabel?.text = getLocalizedMessage(key: "felica_balance")
            if let balance = result.felicaBalance {
                cell.detailTextLabel?.text = formatCurrency(balance)
                cell.detailTextLabel?.textColor = .systemGreen
                cell.detailTextLabel?.font = .boldSystemFont(ofSize: 20)
            } else {
                cell.detailTextLabel?.text = "-"
            }
        case 2:
            cell.textLabel?.text = getLocalizedMessage(key: "felica_system")
            cell.detailTextLabel?.text = result.felicaSystemCode ?? "-"
        default:
            break
        }
    }

    private func configureHistoryCell(_ cell: SubtitleCell, row: Int, result: NFCReadResult) {
        guard row < result.felicaHistories.count else { return }
        let history = result.felicaHistories[row]

        // 日付と処理種別
        cell.textLabel?.text = "\(history.dateString)  \(history.processTypeName)"
        cell.textLabel?.font = .systemFont(ofSize: 15)

        // 残高（カンマ区切り）
        cell.detailTextLabel?.text = formatCurrency(history.balance)
        cell.detailTextLabel?.font = .boldSystemFont(ofSize: 16)

        // チャージは緑、支払いは赤
        switch history.processType {
        case 0x02, 0x1F, 0x49, 0x4A, 0xCB: // チャージ系
            cell.detailTextLabel?.textColor = .systemGreen
        case 0x01, 0x04, 0x05, 0x0F, 0x46, 0xC6: // 支払い系
            cell.detailTextLabel?.textColor = .systemRed
        default:
            cell.detailTextLabel?.textColor = .label
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

        guard let result = readResult else { return }

        let sections = getVisibleSections()
        guard indexPath.section < sections.count else { return }

        // レコードセクションの場合、URLタップ処理
        if sections[indexPath.section] == .records {
            let recordIndex = indexPath.row / 5
            let fieldIndex = indexPath.row % 5

            guard recordIndex < result.records.count, fieldIndex == 3 else { return }
            let record = result.records[recordIndex]

            if let url = record.urlContent {
                UIApplication.shared.open(url)
            }
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
