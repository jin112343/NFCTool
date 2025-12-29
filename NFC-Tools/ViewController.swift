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
    
    
    
    
    let localizedMessages: [String: [String: String]] = [
        "ja": [ // 日本語
            "nfc_not_supported": "このNFCは使えません",
            "nfc_bring_closer": "NFCタグをiPhone上部に近づけてください",
            "nfc_tag_not_supported": "このNFCタグは対応していません",
            "nfc_remove_alert": "下記の情報を削除します\nNFCタグを動かないでください \n\n %@",
            "nfc_read_only": "このNFCタグには書き込みできません",
            "nfc_payload_fail": "ペイロードの作成に失敗しました",
            "nfc_over_capacity": "容量オーバーで書き込めません！\n容量は%@bytesです",
            "nfc_deleted": "削除しました"
              ],
        "ar": [ // アラビア語
            "nfc_not_supported": "لا يمكن استخدام NFC هذا",
            "nfc_bring_closer": "قرب علامة NFC إلى أعلى iPhone",
            "nfc_tag_not_supported": "علامة NFC هذه غير مدعومة",
            "nfc_remove_alert": "سيتم حذف المعلومات التالية\nيرجى عدم تحريك علامة NFC \n\n %@",
            "nfc_read_only": "علامة NFC هذه للقراءة فقط",
            "nfc_payload_fail": "فشل إنشاء الحمولة",
            "nfc_over_capacity": "لا يمكن الكتابة بسبب تجاوز السعة!\nالسعة هي %@ بايت",
            "nfc_deleted": "تم الحذف بنجاح"
              ],
        "it": [ // イタリア語
            "nfc_not_supported": "Questo NFC non può essere utilizzato",
            "nfc_bring_closer": "Avvicina il tag NFC alla parte superiore dell'iPhone",
            "nfc_tag_not_supported": "Questo tag NFC non è supportato",
            "nfc_remove_alert": "Le seguenti informazioni saranno eliminate\nNon spostare il tag NFC \n\n %@",
            "nfc_read_only": "Questo tag NFC è solo in lettura",
            "nfc_payload_fail": "Creazione del payload non riuscita",
            "nfc_over_capacity": "Impossibile scrivere a causa del superamento della capacità!\nLa capacità è di %@ byte",
            "nfc_deleted": "Eliminato con successo"
              ],
        "id": [ // インドネシア語
            "nfc_not_supported": "NFC ini tidak dapat digunakan",
            "nfc_bring_closer": "Dekatkan tag NFC ke bagian atas iPhone",
            "nfc_tag_not_supported": "Tag NFC ini tidak didukung",
            "nfc_remove_alert": "Informasi berikut akan dihapus\nJangan pindahkan tag NFC \n\n %@",
            "nfc_read_only": "Tag NFC ini hanya dapat dibaca",
            "nfc_payload_fail": "Gagal membuat payload",
            "nfc_over_capacity": "Tidak dapat menulis karena kapasitas melebihi batas!\nKapasitas adalah %@ byte",
            "nfc_deleted": "Berhasil dihapus"
              ],
        "uk": [ // ウクライナ語
            "nfc_not_supported": "Цей NFC не можна використовувати",
            "nfc_bring_closer": "Піднесіть NFC-тег до верхньої частини iPhone",
            "nfc_tag_not_supported": "Цей NFC-тег не підтримується",
            "nfc_remove_alert": "Наступна інформація буде видалена\nНе рухайте NFC-тег \n\n %@",
            "nfc_read_only": "Цей NFC-тег лише для читання",
            "nfc_payload_fail": "Не вдалося створити корисне навантаження",
            "nfc_over_capacity": "Неможливо записати через перевищення місткості!\nМісткість %@ байт",
            "nfc_deleted": "Успішно видалено"
              ],
        "nl": [ // オランダ語
            "nfc_not_supported": "Deze NFC kan niet worden gebruikt",
            "nfc_bring_closer": "Houd de NFC-tag dichter bij de bovenkant van de iPhone",
            "nfc_tag_not_supported": "Deze NFC-tag wordt niet ondersteund",
            "nfc_remove_alert": "De volgende informatie wordt verwijderd\nBeweeg de NFC-tag niet \n\n %@",
            "nfc_read_only": "Deze NFC-tag is alleen-lezen",
            "nfc_payload_fail": "Kan de payload niet maken",
            "nfc_over_capacity": "Kan niet schrijven vanwege overcapaciteit!\nCapaciteit is %@ bytes",
            "nfc_deleted": "Succesvol verwijderd"
              ],
        "fr": [ // フランス語
            "nfc_not_supported": "Ce NFC ne peut pas être utilisé",
            "nfc_bring_closer": "Approchez l'étiquette NFC de la partie supérieure de l'iPhone",
            "nfc_tag_not_supported": "Cette étiquette NFC n'est pas prise en charge",
            "nfc_remove_alert": "Les informations suivantes seront supprimées\nNe déplacez pas l'étiquette NFC \n\n %@",
            "nfc_read_only": "Cette étiquette NFC est en lecture seule",
            "nfc_payload_fail": "Échec de la création de la charge utile",
            "nfc_over_capacity": "Impossible d'écrire en raison de la surcharge de capacité !\nLa capacité est de %@ octets",
            "nfc_deleted": "Supprimé avec succès"
              ],
        "tr": [ // トルコ語
            "nfc_not_supported": "Bu NFC kullanılamaz",
            "nfc_bring_closer": "NFC etiketini iPhone'un üst kısmına yaklaştırın",
            "nfc_tag_not_supported": "Bu NFC etiketi desteklenmiyor",
            "nfc_remove_alert": "Aşağıdaki bilgiler silinecek\nLütfen NFC etiketini hareket ettirmeyin \n\n %@",
            "nfc_read_only": "Bu NFC etiketi yalnızca okunabilir",
            "nfc_payload_fail": "Yük oluşturulamadı",
            "nfc_over_capacity": "Kapasite aşıldığından yazılamıyor!\nKapasite %@ bayt",
            "nfc_deleted": "Başarıyla silindi"
              ],
        "sv": [ // スウェーデン語
            "nfc_not_supported": "Denna NFC går inte att använda",
            "nfc_bring_closer": "För NFC-märket närmare toppen av iPhone",
            "nfc_tag_not_supported": "Denna NFC-märke stöds inte",
            "nfc_remove_alert": "Följande information kommer att raderas\nFlytta inte NFC-märket \n\n %@",
            "nfc_read_only": "Denna NFC-märke är skrivskyddad",
            "nfc_payload_fail": "Kunde inte skapa nyttolast",
            "nfc_over_capacity": "Kan inte skriva på grund av överkapacitet!\nKapaciteten är %@ bytes",
            "nfc_deleted": "Borttaget framgångsrikt"
              ],
        "es": [ // スペイン語（スペイン）
            "nfc_not_supported": "Este NFC no se puede usar",
            "nfc_bring_closer": "Acerca la etiqueta NFC a la parte superior del iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC no es compatible",
            "nfc_remove_alert": "La siguiente información será eliminada\nNo muevas la etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC es de solo lectura",
            "nfc_payload_fail": "Error al crear la carga útil",
            "nfc_over_capacity": "No se puede escribir debido a la sobrecarga de capacidad!\nLa capacidad es %@ bytes",
            "nfc_deleted": "Eliminado con éxito"
              ],
        "es-MX": [ // スペイン語（メキシコ）
            "nfc_not_supported": "Este NFC no se puede utilizar",
            "nfc_bring_closer": "Acerca la etiqueta NFC a la parte superior del iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC no es compatible",
            "nfc_remove_alert": "La siguiente información será eliminada\nNo muevas la etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC es de solo lectura",
            "nfc_payload_fail": "Error al crear la carga útil",
            "nfc_over_capacity": "No se puede escribir debido a la sobrecarga de capacidad!\nLa capacidad es %@ bytes",
            "nfc_deleted": "Eliminado con éxito"
                 ],
        "sk": [ // スロバキア語
            "nfc_not_supported": "Tento NFC sa nedá použiť",
            "nfc_bring_closer": "Priblížte NFC značku k hornej časti iPhonu",
            "nfc_tag_not_supported": "Táto NFC značka nie je podporovaná",
            "nfc_remove_alert": "Nasledujúce informácie budú vymazané\nNepohybujte NFC značkou \n\n %@",
            "nfc_read_only": "Táto NFC značka je iba na čítanie",
            "nfc_payload_fail": "Nepodarilo sa vytvoriť užitočné zaťaženie",
            "nfc_over_capacity": "Nie je možné zapisovať z dôvodu prekročenia kapacity!\nKapacita je %@ bajtov",
            "nfc_deleted": "Úspešne vymazané"
              ],
        "th": [ // タイ語
            "nfc_not_supported": "ไม่สามารถใช้ NFC นี้ได้",
            "nfc_bring_closer": "นำแท็ก NFC มาใกล้ด้านบนของ iPhone",
            "nfc_tag_not_supported": "แท็ก NFC นี้ไม่รองรับ",
            "nfc_remove_alert": "ข้อมูลต่อไปนี้จะถูกลบ\nกรุณาอย่าเคลื่อนย้ายแท็ก NFC \n\n %@",
            "nfc_read_only": "แท็ก NFC นี้อ่านได้อย่างเดียว",
            "nfc_payload_fail": "ไม่สามารถสร้างข้อมูลโหลดได้",
            "nfc_over_capacity": "ไม่สามารถเขียนได้เนื่องจากเกินความจุ!\nความจุคือ %@ ไบต์",
            "nfc_deleted": "ลบสำเร็จ"
              ],
        "cs": [ // チェコ語
            "nfc_not_supported": "Tento NFC nelze použít",
            "nfc_bring_closer": "Přibližte NFC štítek k horní části iPhonu",
            "nfc_tag_not_supported": "Tento NFC štítek není podporován",
            "nfc_remove_alert": "Následující informace budou odstraněny\nNepohybujte NFC štítkem \n\n %@",
            "nfc_read_only": "Tento NFC štítek je pouze pro čtení",
            "nfc_payload_fail": "Nepodařilo se vytvořit užitečné zatížení",
            "nfc_over_capacity": "Nelze zapisovat kvůli překročení kapacity!\nKapacita je %@ bajtů",
            "nfc_deleted": "Úspěšně odstraněno"
              ],
        "da": [ // デンマーク語
            "nfc_not_supported": "Denne NFC kan ikke bruges",
            "nfc_bring_closer": "Hold NFC-mærket tættere på toppen af iPhone",
            "nfc_tag_not_supported": "Dette NFC-mærke understøttes ikke",
            "nfc_remove_alert": "Følgende oplysninger vil blive slettet\nFlyt ikke NFC-mærket \n\n %@",
            "nfc_read_only": "Dette NFC-mærke er kun til læsning",
            "nfc_payload_fail": "Kunne ikke oprette nyttelast",
            "nfc_over_capacity": "Kan ikke skrive på grund af overkapacitet!\nKapaciteten er %@ bytes",
            "nfc_deleted": "Succesfuldt slettet"
              ],
        "de": [ // ドイツ語
            "nfc_not_supported": "Dieses NFC kann nicht verwendet werden",
            "nfc_bring_closer": "Halten Sie das NFC-Tag näher an die Oberseite des iPhones",
            "nfc_tag_not_supported": "Dieses NFC-Tag wird nicht unterstützt",
            "nfc_remove_alert": "Die folgenden Informationen werden gelöscht\nBewegen Sie das NFC-Tag nicht \n\n %@",
            "nfc_read_only": "Dieses NFC-Tag ist schreibgeschützt",
            "nfc_payload_fail": "Erstellung der Nutzlast fehlgeschlagen",
            "nfc_over_capacity": "Schreiben aufgrund von Überkapazität nicht möglich!\nKapazität beträgt %@ Bytes",
            "nfc_deleted": "Erfolgreich gelöscht"
              ],
        "no": [ // ノルウェー語
            "nfc_not_supported": "Denne NFC kan ikke brukes",
            "nfc_bring_closer": "Hold NFC-merket nærmere toppen av iPhone",
            "nfc_tag_not_supported": "Dette NFC-merket støttes ikke",
            "nfc_remove_alert": "Følgende informasjon vil bli slettet\nIkke flytt NFC-merket \n\n %@",
            "nfc_read_only": "Dette NFC-merket er kun lesbart",
            "nfc_payload_fail": "Kunne ikke opprette nyttelast",
            "nfc_over_capacity": "Kan ikke skrive på grunn av overkapasitet!\nKapasitet er %@ byte",
            "nfc_deleted": "Slettet vellykket"
              ],
        "hu": [ // ハンガリー語
            "nfc_not_supported": "Ez az NFC nem használható",
            "nfc_bring_closer": "Helyezze közelebb az NFC-címkét az iPhone tetejéhez",
            "nfc_tag_not_supported": "Ez az NFC-címke nem támogatott",
            "nfc_remove_alert": "A következő információk törlődnek\nNe mozgassa az NFC-címkét \n\n %@",
            "nfc_read_only": "Ez az NFC-címke csak olvasható",
            "nfc_payload_fail": "A hasznos teher létrehozása nem sikerült",
            "nfc_over_capacity": "Nem lehet írni a kapacitás túllépése miatt!\nA kapacitás %@ bájt",
            "nfc_deleted": "Sikeresen törölve"
              ],
        "hi": [ // ヒンディー語
            "nfc_not_supported": "यह NFC उपयोग नहीं किया जा सकता",
            "nfc_bring_closer": "NFC टैग को iPhone के शीर्ष के पास लाएं",
            "nfc_tag_not_supported": "यह NFC टैग समर्थित नहीं है",
            "nfc_remove_alert": "निम्नलिखित जानकारी हटा दी जाएगी\nकृपया NFC टैग को न हिलाएं \n\n %@",
            "nfc_read_only": "यह NFC टैग केवल पढ़ने योग्य है",
            "nfc_payload_fail": "पेलोड बनाने में विफल",
            "nfc_over_capacity": "क्षमता अधिक हो जाने के कारण लिख नहीं सकता!\nक्षमता %@ बाइट्स है",
            "nfc_deleted": "सफलतापूर्वक हटाया गया"
              ],
        "fi": [ // フィンランド語
            "nfc_not_supported": "Tätä NFC:tä ei voi käyttää",
            "nfc_bring_closer": "Pidä NFC-tunniste lähellä iPhonen yläosaa",
            "nfc_tag_not_supported": "Tätä NFC-tunnistetta ei tueta",
            "nfc_remove_alert": "Seuraavat tiedot poistetaan\nÄlä liikuta NFC-tunnistetta \n\n %@",
            "nfc_read_only": "Tämä NFC-tunniste on vain lukuoikeudellinen",
            "nfc_payload_fail": "Hyötykuorman luominen epäonnistui",
            "nfc_over_capacity": "Kirjoittaminen ei onnistu kapasiteetin ylityksen vuoksi!\nKapasiteetti on %@ tavua",
            "nfc_deleted": "Poistettu onnistuneesti"
              ],
        "pl": [ // ポーランド語
            "nfc_not_supported": "Ten NFC nie może być używany",
            "nfc_bring_closer": "Zbliż znacznik NFC do górnej części iPhone’a",
            "nfc_tag_not_supported": "Ten znacznik NFC nie jest obsługiwany",
            "nfc_remove_alert": "Poniższe informacje zostaną usunięte\nNie przesuwaj znacznika NFC \n\n %@",
            "nfc_read_only": "Ten znacznik NFC jest tylko do odczytu",
            "nfc_payload_fail": "Nie udało się utworzyć ładunku",
            "nfc_over_capacity": "Nie można zapisać z powodu przekroczenia pojemności!\nPojemność to %@ bajtów",
            "nfc_deleted": "Pomyślnie usunięto"
              ],
        "pt-BR": [ // ポルトガル語（ブラジル）
            "nfc_not_supported": "Este NFC não pode ser usado",
            "nfc_bring_closer": "Aproxime a etiqueta NFC da parte superior do iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC não é suportada",
            "nfc_remove_alert": "As seguintes informações serão excluídas\nNão mova a etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC é apenas leitura",
            "nfc_payload_fail": "Falha ao criar carga útil",
            "nfc_over_capacity": "Não é possível gravar devido à sobrecarga de capacidade!\nA capacidade é de %@ bytes",
            "nfc_deleted": "Excluído com sucesso"
                 ],
        "pt-PT": [ // ポルトガル語（ポルトガル）
            "nfc_not_supported": "Este NFC não pode ser utilizado",
            "nfc_bring_closer": "Aproxime a etiqueta NFC da parte superior do iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC não é suportada",
            "nfc_remove_alert": "As seguintes informações serão eliminadas\nNão mova a etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC é apenas de leitura",
            "nfc_payload_fail": "Falha ao criar carga útil",
            "nfc_over_capacity": "Não é possível escrever devido ao excesso de capacidade!\nA capacidade é de %@ bytes",
            "nfc_deleted": "Eliminado com sucesso"
                 ],
        "ms": [ // マレー語
            "nfc_not_supported": "NFC ini tidak boleh digunakan",
            "nfc_bring_closer": "Dekatkan tag NFC ke bahagian atas iPhone",
            "nfc_tag_not_supported": "Tag NFC ini tidak disokong",
            "nfc_remove_alert": "Maklumat berikut akan dipadamkan\nJangan gerakkan tag NFC \n\n %@",
            "nfc_read_only": "Tag NFC ini hanya untuk dibaca",
            "nfc_payload_fail": "Gagal membuat payload",
            "nfc_over_capacity": "Tidak dapat menulis kerana kapasiti melebihi!\nKapasiti ialah %@ bait",
            "nfc_deleted": "Berjaya dipadamkan"
              ],
        "ro": [ // ルーマニア語
            "nfc_not_supported": "Acest NFC nu poate fi utilizat",
            "nfc_bring_closer": "Apropiați eticheta NFC de partea superioară a iPhone-ului",
            "nfc_tag_not_supported": "Această etichetă NFC nu este acceptată",
            "nfc_remove_alert": "Următoarele informații vor fi șterse\nNu mișcați eticheta NFC \n\n %@",
            "nfc_read_only": "Această etichetă NFC este doar pentru citire",
            "nfc_payload_fail": "Eșec la crearea payload-ului",
            "nfc_over_capacity": "Nu se poate scrie din cauza depășirii capacității!\nCapacitatea este de %@ bytes",
            "nfc_deleted": "Șters cu succes"
              ],
        "ru": [ // ロシア語
            "nfc_not_supported": "Этот NFC не может быть использован",
            "nfc_bring_closer": "Поднесите метку NFC к верхней части iPhone",
            "nfc_tag_not_supported": "Эта метка NFC не поддерживается",
            "nfc_remove_alert": "Следующая информация будет удалена\nНе двигайте метку NFC \n\n %@",
            "nfc_read_only": "Эта метка NFC доступна только для чтения",
            "nfc_payload_fail": "Не удалось создать полезную нагрузку",
            "nfc_over_capacity": "Невозможно записать из-за превышения емкости!\nЕмкость %@ байт",
            "nfc_deleted": "Успешно удалено"
              ],
        "vi": [ // ベトナム語
            "nfc_not_supported": "NFC này không thể được sử dụng",
            "nfc_bring_closer": "Đưa thẻ NFC đến gần phần trên cùng của iPhone",
            "nfc_tag_not_supported": "Thẻ NFC này không được hỗ trợ",
            "nfc_remove_alert": "Thông tin sau sẽ bị xóa\nĐừng di chuyển thẻ NFC \n\n %@",
            "nfc_read_only": "Thẻ NFC này chỉ đọc được",
            "nfc_payload_fail": "Không thể tạo payload",
            "nfc_over_capacity": "Không thể ghi do vượt quá dung lượng!\nDung lượng là %@ bytes",
            "nfc_deleted": "Đã xóa thành công"
              ],
        "ko": [ // 韓国語
            "nfc_not_supported": "이 NFC는 사용할 수 없습니다",
            "nfc_bring_closer": "NFC 태그를 iPhone 상단으로 가까이 가져오세요",
            "nfc_tag_not_supported": "이 NFC 태그는 지원되지 않습니다",
            "nfc_remove_alert": "다음 정보가 삭제됩니다\nNFC 태그를 움직이지 마세요 \n\n %@",
            "nfc_read_only": "이 NFC 태그는 읽기 전용입니다",
            "nfc_payload_fail": "페이로드 생성에 실패했습니다",
            "nfc_over_capacity": "용량 초과로 인해 쓸 수 없습니다!\n용량은 %@ 바이트입니다",
            "nfc_deleted": "성공적으로 삭제되었습니다"
              ],
        "zh": [ // 中国語（簡体字）
            "nfc_not_supported": "此NFC无法使用",
            "nfc_bring_closer": "将NFC标签靠近iPhone顶部",
            "nfc_tag_not_supported": "此NFC标签不支持",
            "nfc_remove_alert": "以下信息将被删除\n请勿移动NFC标签 \n\n %@",
            "nfc_read_only": "此NFC标签为只读",
            "nfc_payload_fail": "创建有效负载失败",
            "nfc_over_capacity": "由于容量超限，无法写入！\n容量为%@字节",
            "nfc_deleted": "删除成功"
                   ],
        "zh-Hant": [ // 中国語（繁体字）
            "nfc_not_supported": "此NFC無法使用",
            "nfc_bring_closer": "將NFC標籤靠近iPhone頂部",
            "nfc_tag_not_supported": "此NFC標籤不支援",
            "nfc_remove_alert": "以下資訊將被刪除\n請勿移動NFC標籤 \n\n %@",
            "nfc_read_only": "此NFC標籤為唯讀",
            "nfc_payload_fail": "建立有效負載失敗",
            "nfc_over_capacity": "由於容量超限，無法寫入！\n容量為%@字節",
            "nfc_deleted": "刪除成功"
                   ]
    ]
    
    
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
            
        } else {
            bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
        }
    }
    
    // 言語別メッセージを取得するメソッド
    func getLocalizedMessage(key: String) -> String {
        let currentLanguage = Locale.current.languageCode ?? "en"
        print("Current Language Code: \(currentLanguage)")
        // デフォルトは英語、キーが見つからない場合は代替メッセージを提供
        return localizedMessages[currentLanguage]?[key]
            ?? localizedMessages["en"]?[key]
            ?? "Message not available"
    }
    
    // MARK: - NFC Methods
    func startSession(state: State) {
        self.state = state
        guard NFCNDEFReaderSession.readingAvailable else {
            // 正しいメッセージを取得して表示
            Swift.print(getLocalizedMessage(key: "nfc_not_supported"))
            return
        }
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session?.alertMessage = getLocalizedMessage(key: "nfc_bring_closer")
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
            session.alertMessage = NSLocalizedString("nfc_single_tag", comment: "")
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
                self.stopSession(error: NSLocalizedString("nfc_tag_not_supported", comment: ""))
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
                self.stopSession(error: error?.localizedDescription ?? NSLocalizedString("nfc_tag_not_supported", comment: ""))
                return
            }
            if !self.updateMessage(message!) {
                self.stopSession(error: NSLocalizedString("nfc_tag_not_supported", comment: ""))
            }
        }
    }
    
    private func handleDeleteOperation(_ tag: NFCNDEFTag, status: NFCNDEFStatus, capacity: Int) {
        tag.readNDEF { (message, error) in
            if error != nil || message == nil {
                self.stopSession(error: error?.localizedDescription ?? NSLocalizedString("nfc_tag_not_supported", comment: ""))
                return
            }
            
            guard let message = message, !message.records.isEmpty else { return }
            
            let results = self.parseRecords(message.records)
            let msg = "[" + results.joined(separator: ", ") + "]"
            self.session?.alertMessage = String(format: NSLocalizedString("nfc_remove_alert", comment: ""), msg)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                if status == .readOnly {
                    self.stopSession(error: NSLocalizedString("nfc_read_only", comment: ""))
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
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: " ", locale: Locale(identifier: "text")),
              let urlPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: " ") else {
            self.stopSession(error: NSLocalizedString("nfc_payload_fail", comment: ""))
            return
        }
        
        self.message = NFCNDEFMessage(records: [payload, urlPayload])
        guard let message = self.message else { return }
        
        if message.length > capacity {
            self.stopSession(error: String(format: NSLocalizedString("nfc_over_capacity", comment: ""), "\(capacity)"))
            return
        }
        
        tag.writeNDEF(message) { (error) in
            if let error = error {
                self.stopSession(error: error.localizedDescription)
            } else {
                self.stopSession(alert: NSLocalizedString("nfc_deleted", comment: ""))
            }
        }
    }
    
}
