import UIKit
import CoreNFC
import GoogleMobileAds
import OSLog
import StoreKit

enum State {
    case standBy
    case read
    case write
    case delete
}

class ViewController: UIViewController, GADBannerViewDelegate, CatchProtcol {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "NFCRead")

    // MARK: - IBOutlets
    @IBOutlet weak var readBtn: UIButton!
    @IBOutlet weak var eraseBtn: UIButton!
    @IBOutlet weak var bannerView: GADBannerView!

    // MARK: - Properties
    var session: NFCNDEFReaderSession?
    var tagSession: NFCTagReaderSession?
    var message: NFCNDEFMessage?
    var state: State = .standBy
    var text: String = ""
    var currentReadResult: NFCReadResult?
    
    
    
    
    let localizedMessages: [String: [String: String]] = [
        "en": [ // 英語
            "nfc_not_supported": "NFC is not supported on this device",
            "nfc_bring_closer": "Hold the NFC tag near the top of your iPhone",
            "nfc_tag_not_supported": "This NFC tag is not supported",
            "nfc_remove_alert": "The following information will be deleted\nDo not move the NFC tag \n\n %@",
            "nfc_read_only": "This NFC tag is read-only",
            "nfc_payload_fail": "Failed to create payload",
            "nfc_over_capacity": "Cannot write due to exceeding capacity!\nCapacity is %@ bytes",
            "nfc_deleted": "Deleted successfully",
            "nfc_read_success": "Read complete"
              ],
        "ja": [ // 日本語
            "nfc_not_supported": "このNFCは使えません",
            "nfc_bring_closer": "NFCタグをiPhone上部に近づけてください",
            "nfc_tag_not_supported": "このNFCタグは対応していません",
            "nfc_remove_alert": "下記の情報を削除します\nNFCタグを動かないでください \n\n %@",
            "nfc_read_only": "このNFCタグには書き込みできません",
            "nfc_payload_fail": "ペイロードの作成に失敗しました",
            "nfc_over_capacity": "容量オーバーで書き込めません！\n容量は%@bytesです",
            "nfc_deleted": "削除しました",
            "nfc_read_success": "読み取り完了"
              ],
        "ar": [ // アラビア語
            "nfc_not_supported": "لا يمكن استخدام NFC هذا",
            "nfc_bring_closer": "قرب علامة NFC إلى أعلى iPhone",
            "nfc_tag_not_supported": "علامة NFC هذه غير مدعومة",
            "nfc_remove_alert": "سيتم حذف المعلومات التالية\nيرجى عدم تحريك علامة NFC \n\n %@",
            "nfc_read_only": "علامة NFC هذه للقراءة فقط",
            "nfc_payload_fail": "فشل إنشاء الحمولة",
            "nfc_over_capacity": "لا يمكن الكتابة بسبب تجاوز السعة!\nالسعة هي %@ بايت",
            "nfc_deleted": "تم الحذف بنجاح",
            "nfc_read_success": "تمت القراءة بنجاح"
              ],
        "it": [ // イタリア語
            "nfc_not_supported": "Questo NFC non può essere utilizzato",
            "nfc_bring_closer": "Avvicina il tag NFC alla parte superiore dell'iPhone",
            "nfc_tag_not_supported": "Questo tag NFC non è supportato",
            "nfc_remove_alert": "Le seguenti informazioni saranno eliminate\nNon spostare il tag NFC \n\n %@",
            "nfc_read_only": "Questo tag NFC è solo in lettura",
            "nfc_payload_fail": "Creazione del payload non riuscita",
            "nfc_over_capacity": "Impossibile scrivere a causa del superamento della capacità!\nLa capacità è di %@ byte",
            "nfc_deleted": "Eliminato con successo",
            "nfc_read_success": "Lettura completata"
              ],
        "id": [ // インドネシア語
            "nfc_not_supported": "NFC ini tidak dapat digunakan",
            "nfc_bring_closer": "Dekatkan tag NFC ke bagian atas iPhone",
            "nfc_tag_not_supported": "Tag NFC ini tidak didukung",
            "nfc_remove_alert": "Informasi berikut akan dihapus\nJangan pindahkan tag NFC \n\n %@",
            "nfc_read_only": "Tag NFC ini hanya dapat dibaca",
            "nfc_payload_fail": "Gagal membuat payload",
            "nfc_over_capacity": "Tidak dapat menulis karena kapasitas melebihi batas!\nKapasitas adalah %@ byte",
            "nfc_deleted": "Berhasil dihapus",
            "nfc_read_success": "Pembacaan selesai"
              ],
        "uk": [ // ウクライナ語
            "nfc_not_supported": "Цей NFC не можна використовувати",
            "nfc_bring_closer": "Піднесіть NFC-тег до верхньої частини iPhone",
            "nfc_tag_not_supported": "Цей NFC-тег не підтримується",
            "nfc_remove_alert": "Наступна інформація буде видалена\nНе рухайте NFC-тег \n\n %@",
            "nfc_read_only": "Цей NFC-тег лише для читання",
            "nfc_payload_fail": "Не вдалося створити корисне навантаження",
            "nfc_over_capacity": "Неможливо записати через перевищення місткості!\nМісткість %@ байт",
            "nfc_deleted": "Успішно видалено",
            "nfc_read_success": "Зчитування завершено"
              ],
        "nl": [ // オランダ語
            "nfc_not_supported": "Deze NFC kan niet worden gebruikt",
            "nfc_bring_closer": "Houd de NFC-tag dichter bij de bovenkant van de iPhone",
            "nfc_tag_not_supported": "Deze NFC-tag wordt niet ondersteund",
            "nfc_remove_alert": "De volgende informatie wordt verwijderd\nBeweeg de NFC-tag niet \n\n %@",
            "nfc_read_only": "Deze NFC-tag is alleen-lezen",
            "nfc_payload_fail": "Kan de payload niet maken",
            "nfc_over_capacity": "Kan niet schrijven vanwege overcapaciteit!\nCapaciteit is %@ bytes",
            "nfc_deleted": "Succesvol verwijderd",
            "nfc_read_success": "Lezen voltooid"
              ],
        "fr": [ // フランス語
            "nfc_not_supported": "Ce NFC ne peut pas être utilisé",
            "nfc_bring_closer": "Approchez l'étiquette NFC de la partie supérieure de l'iPhone",
            "nfc_tag_not_supported": "Cette étiquette NFC n'est pas prise en charge",
            "nfc_remove_alert": "Les informations suivantes seront supprimées\nNe déplacez pas l'étiquette NFC \n\n %@",
            "nfc_read_only": "Cette étiquette NFC est en lecture seule",
            "nfc_payload_fail": "Échec de la création de la charge utile",
            "nfc_over_capacity": "Impossible d'écrire en raison de la surcharge de capacité !\nLa capacité est de %@ octets",
            "nfc_deleted": "Supprimé avec succès",
            "nfc_read_success": "Lecture terminée"
              ],
        "tr": [ // トルコ語
            "nfc_not_supported": "Bu NFC kullanılamaz",
            "nfc_bring_closer": "NFC etiketini iPhone'un üst kısmına yaklaştırın",
            "nfc_tag_not_supported": "Bu NFC etiketi desteklenmiyor",
            "nfc_remove_alert": "Aşağıdaki bilgiler silinecek\nLütfen NFC etiketini hareket ettirmeyin \n\n %@",
            "nfc_read_only": "Bu NFC etiketi yalnızca okunabilir",
            "nfc_payload_fail": "Yük oluşturulamadı",
            "nfc_over_capacity": "Kapasite aşıldığından yazılamıyor!\nKapasite %@ bayt",
            "nfc_deleted": "Başarıyla silindi",
            "nfc_read_success": "Okuma tamamlandı"
              ],
        "sv": [ // スウェーデン語
            "nfc_not_supported": "Denna NFC går inte att använda",
            "nfc_bring_closer": "För NFC-märket närmare toppen av iPhone",
            "nfc_tag_not_supported": "Denna NFC-märke stöds inte",
            "nfc_remove_alert": "Följande information kommer att raderas\nFlytta inte NFC-märket \n\n %@",
            "nfc_read_only": "Denna NFC-märke är skrivskyddad",
            "nfc_payload_fail": "Kunde inte skapa nyttolast",
            "nfc_over_capacity": "Kan inte skriva på grund av överkapacitet!\nKapaciteten är %@ bytes",
            "nfc_deleted": "Borttaget framgångsrikt",
            "nfc_read_success": "Läsningen klar"
              ],
        "es": [ // スペイン語（スペイン）
            "nfc_not_supported": "Este NFC no se puede usar",
            "nfc_bring_closer": "Acerca la etiqueta NFC a la parte superior del iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC no es compatible",
            "nfc_remove_alert": "La siguiente información será eliminada\nNo muevas la etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC es de solo lectura",
            "nfc_payload_fail": "Error al crear la carga útil",
            "nfc_over_capacity": "No se puede escribir debido a la sobrecarga de capacidad!\nLa capacidad es %@ bytes",
            "nfc_deleted": "Eliminado con éxito",
            "nfc_read_success": "Lectura completada"
              ],
        "es-MX": [ // スペイン語（メキシコ）
            "nfc_not_supported": "Este NFC no se puede utilizar",
            "nfc_bring_closer": "Acerca la etiqueta NFC a la parte superior del iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC no es compatible",
            "nfc_remove_alert": "La siguiente información será eliminada\nNo muevas la etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC es de solo lectura",
            "nfc_payload_fail": "Error al crear la carga útil",
            "nfc_over_capacity": "No se puede escribir debido a la sobrecarga de capacidad!\nLa capacidad es %@ bytes",
            "nfc_deleted": "Eliminado con éxito",
            "nfc_read_success": "Lectura completada"
                 ],
        "sk": [ // スロバキア語
            "nfc_not_supported": "Tento NFC sa nedá použiť",
            "nfc_bring_closer": "Priblížte NFC značku k hornej časti iPhonu",
            "nfc_tag_not_supported": "Táto NFC značka nie je podporovaná",
            "nfc_remove_alert": "Nasledujúce informácie budú vymazané\nNepohybujte NFC značkou \n\n %@",
            "nfc_read_only": "Táto NFC značka je iba na čítanie",
            "nfc_payload_fail": "Nepodarilo sa vytvoriť užitočné zaťaženie",
            "nfc_over_capacity": "Nie je možné zapisovať z dôvodu prekročenia kapacity!\nKapacita je %@ bajtov",
            "nfc_deleted": "Úspešne vymazané",
            "nfc_read_success": "Čítanie dokončené"
              ],
        "th": [ // タイ語
            "nfc_not_supported": "ไม่สามารถใช้ NFC นี้ได้",
            "nfc_bring_closer": "นำแท็ก NFC มาใกล้ด้านบนของ iPhone",
            "nfc_tag_not_supported": "แท็ก NFC นี้ไม่รองรับ",
            "nfc_remove_alert": "ข้อมูลต่อไปนี้จะถูกลบ\nกรุณาอย่าเคลื่อนย้ายแท็ก NFC \n\n %@",
            "nfc_read_only": "แท็ก NFC นี้อ่านได้อย่างเดียว",
            "nfc_payload_fail": "ไม่สามารถสร้างข้อมูลโหลดได้",
            "nfc_over_capacity": "ไม่สามารถเขียนได้เนื่องจากเกินความจุ!\nความจุคือ %@ ไบต์",
            "nfc_deleted": "ลบสำเร็จ",
            "nfc_read_success": "อ่านเสร็จสมบูรณ์"
              ],
        "cs": [ // チェコ語
            "nfc_not_supported": "Tento NFC nelze použít",
            "nfc_bring_closer": "Přibližte NFC štítek k horní části iPhonu",
            "nfc_tag_not_supported": "Tento NFC štítek není podporován",
            "nfc_remove_alert": "Následující informace budou odstraněny\nNepohybujte NFC štítkem \n\n %@",
            "nfc_read_only": "Tento NFC štítek je pouze pro čtení",
            "nfc_payload_fail": "Nepodařilo se vytvořit užitečné zatížení",
            "nfc_over_capacity": "Nelze zapisovat kvůli překročení kapacity!\nKapacita je %@ bajtů",
            "nfc_deleted": "Úspěšně odstraněno",
            "nfc_read_success": "Čtení dokončeno"
              ],
        "da": [ // デンマーク語
            "nfc_not_supported": "Denne NFC kan ikke bruges",
            "nfc_bring_closer": "Hold NFC-mærket tættere på toppen af iPhone",
            "nfc_tag_not_supported": "Dette NFC-mærke understøttes ikke",
            "nfc_remove_alert": "Følgende oplysninger vil blive slettet\nFlyt ikke NFC-mærket \n\n %@",
            "nfc_read_only": "Dette NFC-mærke er kun til læsning",
            "nfc_payload_fail": "Kunne ikke oprette nyttelast",
            "nfc_over_capacity": "Kan ikke skrive på grund af overkapacitet!\nKapaciteten er %@ bytes",
            "nfc_deleted": "Succesfuldt slettet",
            "nfc_read_success": "Læsning fuldført"
              ],
        "de": [ // ドイツ語
            "nfc_not_supported": "Dieses NFC kann nicht verwendet werden",
            "nfc_bring_closer": "Halten Sie das NFC-Tag näher an die Oberseite des iPhones",
            "nfc_tag_not_supported": "Dieses NFC-Tag wird nicht unterstützt",
            "nfc_remove_alert": "Die folgenden Informationen werden gelöscht\nBewegen Sie das NFC-Tag nicht \n\n %@",
            "nfc_read_only": "Dieses NFC-Tag ist schreibgeschützt",
            "nfc_payload_fail": "Erstellung der Nutzlast fehlgeschlagen",
            "nfc_over_capacity": "Schreiben aufgrund von Überkapazität nicht möglich!\nKapazität beträgt %@ Bytes",
            "nfc_deleted": "Erfolgreich gelöscht",
            "nfc_read_success": "Lesen abgeschlossen"
              ],
        "no": [ // ノルウェー語
            "nfc_not_supported": "Denne NFC kan ikke brukes",
            "nfc_bring_closer": "Hold NFC-merket nærmere toppen av iPhone",
            "nfc_tag_not_supported": "Dette NFC-merket støttes ikke",
            "nfc_remove_alert": "Følgende informasjon vil bli slettet\nIkke flytt NFC-merket \n\n %@",
            "nfc_read_only": "Dette NFC-merket er kun lesbart",
            "nfc_payload_fail": "Kunne ikke opprette nyttelast",
            "nfc_over_capacity": "Kan ikke skrive på grunn av overkapasitet!\nKapasitet er %@ byte",
            "nfc_deleted": "Slettet vellykket",
            "nfc_read_success": "Lesing fullført"
              ],
        "hu": [ // ハンガリー語
            "nfc_not_supported": "Ez az NFC nem használható",
            "nfc_bring_closer": "Helyezze közelebb az NFC-címkét az iPhone tetejéhez",
            "nfc_tag_not_supported": "Ez az NFC-címke nem támogatott",
            "nfc_remove_alert": "A következő információk törlődnek\nNe mozgassa az NFC-címkét \n\n %@",
            "nfc_read_only": "Ez az NFC-címke csak olvasható",
            "nfc_payload_fail": "A hasznos teher létrehozása nem sikerült",
            "nfc_over_capacity": "Nem lehet írni a kapacitás túllépése miatt!\nA kapacitás %@ bájt",
            "nfc_deleted": "Sikeresen törölve",
            "nfc_read_success": "Olvasás befejezve"
              ],
        "hi": [ // ヒンディー語
            "nfc_not_supported": "यह NFC उपयोग नहीं किया जा सकता",
            "nfc_bring_closer": "NFC टैग को iPhone के शीर्ष के पास लाएं",
            "nfc_tag_not_supported": "यह NFC टैग समर्थित नहीं है",
            "nfc_remove_alert": "निम्नलिखित जानकारी हटा दी जाएगी\nकृपया NFC टैग को न हिलाएं \n\n %@",
            "nfc_read_only": "यह NFC टैग केवल पढ़ने योग्य है",
            "nfc_payload_fail": "पेलोड बनाने में विफल",
            "nfc_over_capacity": "क्षमता अधिक हो जाने के कारण लिख नहीं सकता!\nक्षमता %@ बाइट्स है",
            "nfc_deleted": "सफलतापूर्वक हटाया गया",
            "nfc_read_success": "पढ़ना पूरा हुआ"
              ],
        "fi": [ // フィンランド語
            "nfc_not_supported": "Tätä NFC:tä ei voi käyttää",
            "nfc_bring_closer": "Pidä NFC-tunniste lähellä iPhonen yläosaa",
            "nfc_tag_not_supported": "Tätä NFC-tunnistetta ei tueta",
            "nfc_remove_alert": "Seuraavat tiedot poistetaan\nÄlä liikuta NFC-tunnistetta \n\n %@",
            "nfc_read_only": "Tämä NFC-tunniste on vain lukuoikeudellinen",
            "nfc_payload_fail": "Hyötykuorman luominen epäonnistui",
            "nfc_over_capacity": "Kirjoittaminen ei onnistu kapasiteetin ylityksen vuoksi!\nKapasiteetti on %@ tavua",
            "nfc_deleted": "Poistettu onnistuneesti",
            "nfc_read_success": "Lukeminen valmis"
              ],
        "pl": [ // ポーランド語
            "nfc_not_supported": "Ten NFC nie może być używany",
            "nfc_bring_closer": "Zbliż znacznik NFC do górnej części iPhone’a",
            "nfc_tag_not_supported": "Ten znacznik NFC nie jest obsługiwany",
            "nfc_remove_alert": "Poniższe informacje zostaną usunięte\nNie przesuwaj znacznika NFC \n\n %@",
            "nfc_read_only": "Ten znacznik NFC jest tylko do odczytu",
            "nfc_payload_fail": "Nie udało się utworzyć ładunku",
            "nfc_over_capacity": "Nie można zapisać z powodu przekroczenia pojemności!\nPojemność to %@ bajtów",
            "nfc_deleted": "Pomyślnie usunięto",
            "nfc_read_success": "Odczyt zakończony"
              ],
        "pt-BR": [ // ポルトガル語（ブラジル）
            "nfc_not_supported": "Este NFC não pode ser usado",
            "nfc_bring_closer": "Aproxime a etiqueta NFC da parte superior do iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC não é suportada",
            "nfc_remove_alert": "As seguintes informações serão excluídas\nNão mova a etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC é apenas leitura",
            "nfc_payload_fail": "Falha ao criar carga útil",
            "nfc_over_capacity": "Não é possível gravar devido à sobrecarga de capacidade!\nA capacidade é de %@ bytes",
            "nfc_deleted": "Excluído com sucesso",
            "nfc_read_success": "Leitura concluída"
                 ],
        "pt-PT": [ // ポルトガル語（ポルトガル）
            "nfc_not_supported": "Este NFC não pode ser utilizado",
            "nfc_bring_closer": "Aproxime a etiqueta NFC da parte superior do iPhone",
            "nfc_tag_not_supported": "Esta etiqueta NFC não é suportada",
            "nfc_remove_alert": "As seguintes informações serão eliminadas\nNão mova a etiqueta NFC \n\n %@",
            "nfc_read_only": "Esta etiqueta NFC é apenas de leitura",
            "nfc_payload_fail": "Falha ao criar carga útil",
            "nfc_over_capacity": "Não é possível escrever devido ao excesso de capacidade!\nA capacidade é de %@ bytes",
            "nfc_deleted": "Eliminado com sucesso",
            "nfc_read_success": "Leitura concluída"
                 ],
        "ms": [ // マレー語
            "nfc_not_supported": "NFC ini tidak boleh digunakan",
            "nfc_bring_closer": "Dekatkan tag NFC ke bahagian atas iPhone",
            "nfc_tag_not_supported": "Tag NFC ini tidak disokong",
            "nfc_remove_alert": "Maklumat berikut akan dipadamkan\nJangan gerakkan tag NFC \n\n %@",
            "nfc_read_only": "Tag NFC ini hanya untuk dibaca",
            "nfc_payload_fail": "Gagal membuat payload",
            "nfc_over_capacity": "Tidak dapat menulis kerana kapasiti melebihi!\nKapasiti ialah %@ bait",
            "nfc_deleted": "Berjaya dipadamkan",
            "nfc_read_success": "Pembacaan selesai"
              ],
        "ro": [ // ルーマニア語
            "nfc_not_supported": "Acest NFC nu poate fi utilizat",
            "nfc_bring_closer": "Apropiați eticheta NFC de partea superioară a iPhone-ului",
            "nfc_tag_not_supported": "Această etichetă NFC nu este acceptată",
            "nfc_remove_alert": "Următoarele informații vor fi șterse\nNu mișcați eticheta NFC \n\n %@",
            "nfc_read_only": "Această etichetă NFC este doar pentru citire",
            "nfc_payload_fail": "Eșec la crearea payload-ului",
            "nfc_over_capacity": "Nu se poate scrie din cauza depășirii capacității!\nCapacitatea este de %@ bytes",
            "nfc_deleted": "Șters cu succes",
            "nfc_read_success": "Citire finalizată"
              ],
        "ru": [ // ロシア語
            "nfc_not_supported": "Этот NFC не может быть использован",
            "nfc_bring_closer": "Поднесите метку NFC к верхней части iPhone",
            "nfc_tag_not_supported": "Эта метка NFC не поддерживается",
            "nfc_remove_alert": "Следующая информация будет удалена\nНе двигайте метку NFC \n\n %@",
            "nfc_read_only": "Эта метка NFC доступна только для чтения",
            "nfc_payload_fail": "Не удалось создать полезную нагрузку",
            "nfc_over_capacity": "Невозможно записать из-за превышения емкости!\nЕмкость %@ байт",
            "nfc_deleted": "Успешно удалено",
            "nfc_read_success": "Чтение завершено"
              ],
        "vi": [ // ベトナム語
            "nfc_not_supported": "NFC này không thể được sử dụng",
            "nfc_bring_closer": "Đưa thẻ NFC đến gần phần trên cùng của iPhone",
            "nfc_tag_not_supported": "Thẻ NFC này không được hỗ trợ",
            "nfc_remove_alert": "Thông tin sau sẽ bị xóa\nĐừng di chuyển thẻ NFC \n\n %@",
            "nfc_read_only": "Thẻ NFC này chỉ đọc được",
            "nfc_payload_fail": "Không thể tạo payload",
            "nfc_over_capacity": "Không thể ghi do vượt quá dung lượng!\nDung lượng là %@ bytes",
            "nfc_deleted": "Đã xóa thành công",
            "nfc_read_success": "Đọc hoàn tất"
              ],
        "ko": [ // 韓国語
            "nfc_not_supported": "이 NFC는 사용할 수 없습니다",
            "nfc_bring_closer": "NFC 태그를 iPhone 상단으로 가까이 가져오세요",
            "nfc_tag_not_supported": "이 NFC 태그는 지원되지 않습니다",
            "nfc_remove_alert": "다음 정보가 삭제됩니다\nNFC 태그를 움직이지 마세요 \n\n %@",
            "nfc_read_only": "이 NFC 태그는 읽기 전용입니다",
            "nfc_payload_fail": "페이로드 생성에 실패했습니다",
            "nfc_over_capacity": "용량 초과로 인해 쓸 수 없습니다!\n용량은 %@ 바이트입니다",
            "nfc_deleted": "성공적으로 삭제되었습니다",
            "nfc_read_success": "읽기 완료"
              ],
        "zh": [ // 中国語（簡体字）
            "nfc_not_supported": "此NFC无法使用",
            "nfc_bring_closer": "将NFC标签靠近iPhone顶部",
            "nfc_tag_not_supported": "此NFC标签不支持",
            "nfc_remove_alert": "以下信息将被删除\n请勿移动NFC标签 \n\n %@",
            "nfc_read_only": "此NFC标签为只读",
            "nfc_payload_fail": "创建有效负载失败",
            "nfc_over_capacity": "由于容量超限，无法写入！\n容量为%@字节",
            "nfc_deleted": "删除成功",
            "nfc_read_success": "读取完成"
                   ],
        "zh-Hant": [ // 中国語（繁体字）
            "nfc_not_supported": "此NFC無法使用",
            "nfc_bring_closer": "將NFC標籤靠近iPhone頂部",
            "nfc_tag_not_supported": "此NFC標籤不支援",
            "nfc_remove_alert": "以下資訊將被刪除\n請勿移動NFC標籤 \n\n %@",
            "nfc_read_only": "此NFC標籤為唯讀",
            "nfc_payload_fail": "建立有效負載失敗",
            "nfc_over_capacity": "由於容量超限，無法寫入！\n容量為%@字節",
            "nfc_deleted": "刪除成功",
            "nfc_read_success": "讀取完成"
                   ]
    ]
    
    
    // MARK: - Lifecycle Methods
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        CrashlyticsManager.shared.setCurrentScreen("NFC読取画面")
        setupHistoryButton()
        checkFirstLaunch()
        requestAppReview()
    }

    private func setupHistoryButton() {
        guard navigationItem.leftBarButtonItem == nil else { return }
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "clock.arrow.circlepath"),
            style: .plain,
            target: self,
            action: #selector(showHistory)
        )
    }

    @objc private func showHistory() {
        let historyVC = NFCHistoryViewController()
        navigationController?.pushViewController(historyVC, animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAdvertisement()
    }
    
    // MARK: - Setup Methods
    private func checkFirstLaunch() {
        guard let firstLunch = SafeUserDefaults.bool(forKey: "firstLunch") else { return }
        if firstLunch {
            SafeUserDefaults.set(false, forKey: "firstLunch")
            self.performSegue(withIdentifier: "nfc", sender: nil)
        }
    }

    private func requestAppReview() {
        guard SafeUserDefaults.isDataAvailable else { return }

        var launchCount = SafeUserDefaults.integer(forKey: "appLaunchCount") ?? 0
        launchCount += 1
        SafeUserDefaults.set(launchCount, forKey: "appLaunchCount")

        // 5回以上起動 かつ まだレビューリクエストしていない場合
        let hasRequested = SafeUserDefaults.bool(forKey: "hasRequestedReview") ?? false
        if launchCount >= 5 && !hasRequested {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: windowScene)
                    SafeUserDefaults.set(true, forKey: "hasRequestedReview")
                }
            }
        }
    }
    
    private func setupAdvertisement() {
        if KeychainHelper.hasPurchased() {
            return
        }
        bannerView.adUnitID = "ca-app-pub-1187210314934709/5463627829"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    
    // 言語別メッセージを取得するメソッド
    func getLocalizedMessage(key: String) -> String {
        let currentLanguage: String
        if #available(iOS 16, *) {
            currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            currentLanguage = Locale.current.languageCode ?? "en"
        }
        // デフォルトは英語、キーが見つからない場合は代替メッセージを提供
        return localizedMessages[currentLanguage]?[key]
            ?? localizedMessages["en"]?[key]
            ?? "Message not available"
    }
    
    // MARK: - NFC Methods
    func startSession(state: State) {
        self.state = state
        self.currentReadResult = nil

        guard NFCNDEFReaderSession.readingAvailable else {
            logger.error("NFC not supported: \(self.getLocalizedMessage(key: "nfc_not_supported"))")
            return
        }

        if state == .read {
            // 読み取りモードではNFCTagReaderSessionを使用（FeliCa含む全タグ対応）
            tagSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693, .iso18092], delegate: self, queue: nil)
            tagSession?.alertMessage = getLocalizedMessage(key: "nfc_bring_closer")
            tagSession?.begin()
        } else {
            // 削除モードでは従来のNDEFセッションを使用
            session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
            session?.alertMessage = getLocalizedMessage(key: "nfc_bring_closer")
            session?.begin()
        }
    }

    func stopSession(alert: String = "", error: String = "") {
        session?.alertMessage = alert
        tagSession?.alertMessage = alert
        if error.isEmpty {
            session?.invalidate()
            tagSession?.invalidate()
        } else {
            session?.invalidate(errorMessage: error)
            tagSession?.invalidate(errorMessage: error)
        }
        self.state = .standBy
    }

    func stopSessionAndShowResult(alert: String = "") {
        tagSession?.alertMessage = alert
        tagSession?.invalidate()
        self.state = .standBy

        // 結果画面へ遷移
        DispatchQueue.main.async {
            self.showReadResultViewController()
        }
    }

    private func showReadResultViewController() {
        guard let result = currentReadResult else { return }
        NFCHistoryManager.saveResult(result)
        let resultVC = NFCReadResultViewController()
        resultVC.readResult = result
        self.navigationController?.pushViewController(resultVC, animated: true)
    }
    func tagRemovalDetect(_ tag: NFCNDEFTag) {
        session?.connect(to: tag) { [weak self] (error: Error?) in
            guard let self = self else { return }
            if error != nil || !tag.isAvailable {
                self.session?.restartPolling()
                return
            }
            DispatchQueue.global().asyncAfter(deadline: .now() + .milliseconds(500)) { [weak self] in
                self?.tagRemovalDetect(tag)
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
        CrashlyticsManager.shared.logAction("削除ボタンタップ")
        CrashlyticsManager.shared.logNFCOperationStart("NFC削除")
        startSession(state: .delete)
    }

    @IBAction func resetMode(_ sender: Any) {
        CrashlyticsManager.shared.logAction("読取ボタンタップ")
        CrashlyticsManager.shared.logNFCOperationStart("NFC読取")
        startSession(state: .read)
    }
    
    // MARK: - CatchProtcol
    func catchData(count: Int) {
        if count == 1 {
            // view 未ロード時に bannerView が nil でも安全に no-op
            bannerView?.isHidden = true
        }
    }
}

// MARK: - NFCNDEFReaderSessionDelegate
extension ViewController: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Session became active
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let nfcError = error as? NFCReaderError,
           nfcError.code == .readerSessionInvalidationErrorUserCanceled ||
           nfcError.code == .readerSessionInvalidationErrorFirstNDEFTagRead {
            logger.info("NFCセッション正常終了")
            return
        }
        logger.error("NFCセッションエラー: \(error.localizedDescription)")
        CrashlyticsManager.shared.recordError(error, context: "NFCセッション - NFC読取画面")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Not called directly
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if tags.count > 1 {
            session.alertMessage = NSLocalizedString("nfc_single_tag", comment: "")
            if let firstTag = tags.first {
                tagRemovalDetect(firstTag)
            } else {
                session.restartPolling()
            }
            return
        }

        guard let tag = tags.first else {
            session.restartPolling()
            return
        }

        session.connect(to: tag) { (error) in
            if error != nil {
                session.restartPolling()
                return
            }

            // connect の完了を待ってから NDEF ステータスを照会する（接続前照会の競合を防ぐ）
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
        guard let payload = NFCNDEFPayload.wellKnownTypeTextPayload(string: " ", locale: Locale(identifier: "en")),
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

// MARK: - NFCTagReaderSessionDelegate
extension ViewController: NFCTagReaderSessionDelegate {

    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        logger.info("NFCTagReaderSession became active")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        logger.error("NFCTagReaderSession error: \(error.localizedDescription)")
    }

    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first else {
            session.invalidate(errorMessage: getLocalizedMessage(key: "nfc_tag_not_supported"))
            return
        }

        session.connect(to: tag) { error in
            if let error = error {
                self.logger.error("Failed to connect to tag: \(error.localizedDescription)")
                session.invalidate(errorMessage: error.localizedDescription)
                return
            }

            // タグの種類に応じて処理を分岐
            switch tag {
            case .iso7816(let iso7816Tag):
                self.handleISO7816Tag(iso7816Tag, session: session)
            case .feliCa(let feliCaTag):
                self.handleFeliCaTag(feliCaTag, session: session)
            case .iso15693(let iso15693Tag):
                self.handleISO15693Tag(iso15693Tag, session: session)
            case .miFare(let miFareTag):
                self.handleMiFareTag(miFareTag, session: session)
            @unknown default:
                self.handleUnknownTag(session: session)
            }
        }
    }

    // MARK: - Tag Handlers

    private func handleISO7816Tag(_ tag: NFCISO7816Tag, session: NFCTagReaderSession) {
        var result = NFCReadResult()
        result.tagType = "ISO7816"
        result.tagIdentifier = tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        // NDEFを読み取る（NFCISO7816TagはNFCNDEFTagに準拠）
        readNDEFFromTag(tag, result: &result, session: session)
    }

    private func handleFeliCaTag(_ tag: NFCFeliCaTag, session: NFCTagReaderSession) {
        var result = NFCReadResult()
        result.tagType = "FeliCa"
        result.tagIdentifier = tag.currentIDm.map { String(format: "%02X", $0) }.joined(separator: ":")
        result.felicaSystemCode = tag.currentSystemCode.map { String(format: "%02X", $0) }.joined()

        logger.info("FeliCa detected - IDm: \(result.tagIdentifier ?? "nil"), SystemCode: \(result.felicaSystemCode ?? "nil")")

        // カード種別を判定して残高読み取りを試みる（交通系/楽天Edy/nanaco/WAON 等）
        readFeliCaBalance(tag, result: result) { updatedResult in
            self.logger.info("FeliCa read complete - Type: \(updatedResult.felicaCardType ?? "unknown"), Balance: \(updatedResult.felicaBalance ?? -1), Histories: \(updatedResult.felicaHistories.count)")
            self.currentReadResult = updatedResult
            self.stopSessionAndShowResult(alert: self.getLocalizedMessage(key: "nfc_read_success"))
        }
    }

    private func handleISO15693Tag(_ tag: NFCISO15693Tag, session: NFCTagReaderSession) {
        var result = NFCReadResult()
        result.tagType = "ISO15693"
        result.tagIdentifier = tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        // システム情報を読み取る（async/await API）
        Task {
            do {
                let systemInfo = try await tag.systemInfo(requestFlags: [.highDataRate])
                result.capacity = systemInfo.blockSize * systemInfo.totalBlocks
            } catch {
                self.logger.error("ISO15693 systemInfo failed: \(error.localizedDescription)")
            }

            self.currentReadResult = result
            self.stopSessionAndShowResult(alert: self.getLocalizedMessage(key: "nfc_read_success"))
        }
    }

    private func handleMiFareTag(_ tag: NFCMiFareTag, session: NFCTagReaderSession) {
        var result = NFCReadResult()

        // MiFareのファミリーを判定
        switch tag.mifareFamily {
        case .ultralight:
            result.tagType = "MiFare Ultralight"
        case .plus:
            result.tagType = "MiFare Plus"
        case .desfire:
            result.tagType = "MiFare DESFire"
        case .unknown:
            result.tagType = "MiFare (Unknown)"
        @unknown default:
            result.tagType = "MiFare"
        }

        result.tagIdentifier = tag.identifier.map { String(format: "%02X", $0) }.joined(separator: ":")

        // NDEFタグとして読み取りを試みる
        readNDEFFromTag(tag, result: &result, session: session)
    }

    private func handleUnknownTag(session: NFCTagReaderSession) {
        var result = NFCReadResult()
        result.tagType = "Unknown"
        self.currentReadResult = result
        self.stopSessionAndShowResult(alert: getLocalizedMessage(key: "nfc_read_success"))
    }

    // MARK: - NDEF Reading

    private func readNDEFFromTag(_ tag: NFCNDEFTag, result: inout NFCReadResult, session: NFCTagReaderSession) {
        var mutableResult = result

        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                self.logger.error("NDEF query failed: \(error.localizedDescription)")
                self.currentReadResult = mutableResult
                self.stopSessionAndShowResult(alert: self.getLocalizedMessage(key: "nfc_read_success"))
                return
            }

            mutableResult.capacity = capacity

            switch status {
            case .notSupported:
                mutableResult.ndefStatus = "notSupported"
                mutableResult.isWritable = false
            case .readOnly:
                mutableResult.ndefStatus = "readOnly"
                mutableResult.isWritable = false
            case .readWrite:
                mutableResult.ndefStatus = "readWrite"
                mutableResult.isWritable = true
            @unknown default:
                mutableResult.ndefStatus = "unknown"
                mutableResult.isWritable = false
            }

            tag.readNDEF { message, error in
                if let message = message {
                    mutableResult.usedSize = message.length
                    mutableResult.freeSpace = capacity - message.length
                    mutableResult.records = self.parseNDEFRecords(message.records)
                    mutableResult.rawPayloadData = message.records.map { $0.payload }
                }

                self.currentReadResult = mutableResult
                self.stopSessionAndShowResult(alert: self.getLocalizedMessage(key: "nfc_read_success"))
            }
        }
    }

    private func parseNDEFRecords(_ records: [NFCNDEFPayload]) -> [NFCRecordInfo] {
        var recordInfos: [NFCRecordInfo] = []

        for (index, record) in records.enumerated() {
            var info = NFCRecordInfo(
                recordIndex: index,
                tnf: getTNFString(record.typeNameFormat),
                type: String(data: record.type, encoding: .utf8) ?? "",
                identifier: String(data: record.identifier, encoding: .utf8) ?? "",
                payloadType: "unknown",
                textContent: nil,
                urlContent: nil,
                locale: nil,
                payloadSize: record.payload.count,
                rawPayload: record.payload
            )

            // タイプに応じてペイロードを解析
            let type = String(data: record.type, encoding: .utf8) ?? ""

            switch record.typeNameFormat {
            case .nfcWellKnown:
                if type == "T" {
                    // テキストレコード
                    let textResult = record.wellKnownTypeTextPayload()
                    if let text = textResult.0 {
                        info.textContent = text
                        info.locale = textResult.1?.identifier
                    } else {
                        // wellKnownTypeTextPayloadが失敗した場合のフォールバック
                        let payload = record.payload
                        if payload.count > 1 {
                            let statusByte = payload[0]
                            let langCodeLength = Int(statusByte & 0x3F)
                            if payload.count > langCodeLength + 1 {
                                let textData = payload.subdata(in: (langCodeLength + 1)..<payload.count)
                                let isUTF16 = (statusByte & 0x80) != 0
                                let encoding: String.Encoding = isUTF16 ? .utf16 : .utf8
                                info.textContent = String(data: textData, encoding: encoding)
                            }
                        }
                    }
                    info.payloadType = "Text"
                } else if type == "U" {
                    // URLレコード
                    info.urlContent = record.wellKnownTypeURIPayload()
                    info.payloadType = "URL"
                } else {
                    info.payloadType = type
                }
            case .media:
                // メディアタイプレコード（text/plain等）
                if let text = String(data: record.payload, encoding: .utf8) {
                    info.textContent = text
                }
                info.payloadType = "Media (\(type))"
            case .nfcExternal:
                // 外部タイプレコード - テキストとして読み取り試行
                if let text = String(data: record.payload, encoding: .utf8)?
                    .trimmingCharacters(in: .controlCharacters),
                   !text.isEmpty {
                    info.textContent = text
                }
                info.payloadType = "External (\(type))"
            case .absoluteURI:
                if let urlString = String(data: record.payload, encoding: .utf8),
                   let url = URL(string: urlString) {
                    info.urlContent = url
                }
                info.payloadType = "URI"
            default:
                info.payloadType = type.isEmpty ? "Unknown" : type
            }

            recordInfos.append(info)
        }

        return recordInfos
    }

    private func getTNFString(_ tnf: NFCTypeNameFormat) -> String {
        switch tnf {
        case .empty: return "empty"
        case .nfcWellKnown: return "nfcWellKnown"
        case .media: return "media"
        case .absoluteURI: return "absoluteURI"
        case .nfcExternal: return "nfcExternal"
        case .unknown: return "unknown"
        case .unchanged: return "unchanged"
        @unknown default: return "unknown"
        }
    }

    // MARK: - FeliCa Balance Reading

    /// 対応する電子マネー/交通系カードの残高読み取り定義
    private struct FeliCaCardSpec {
        let name: String         // 表示名（カード種別）
        let systemCode: Data     // polling 用システムコード（ビッグエンディアン2バイト）
        let balanceService: Data // 残高サービスコード（リトルエンディアン2バイト）
        let balanceBlock: Data   // 残高ブロック（通常 [0x80, 0x00]）
        let balanceOffset: Int   // ブロック内の残高開始バイト
        let balanceLength: Int   // 残高バイト数（リトルエンディアン）
        let hasHistory: Bool     // 利用履歴を読むか（交通系のみ）
    }

    /// 既知のFeliCaカード定義。上から順に試し、最初に残高が取れたものを採用する。
    /// 注: 各サービスコード/バイト位置は有志解析に基づく。実カードでの検証を推奨。
    private var feliCaCardSpecs: [FeliCaCardSpec] {
        [
            // 交通系IC（Suica/PASMO/ICOCA など）: システム0x0003 / サービス0x008B / 残高はバイト11-12
            FeliCaCardSpec(name: "交通系IC", systemCode: Data([0x00, 0x03]), balanceService: Data([0x8B, 0x00]), balanceBlock: Data([0x80, 0x00]), balanceOffset: 11, balanceLength: 2, hasHistory: true),
            // 楽天Edy: 共通エリア(0xFE00) / サービス0x1317 / 先頭4バイト
            FeliCaCardSpec(name: "楽天Edy", systemCode: Data([0xFE, 0x00]), balanceService: Data([0x17, 0x13]), balanceBlock: Data([0x80, 0x00]), balanceOffset: 0, balanceLength: 4, hasHistory: false),
            // nanaco: 共通エリア(0xFE00) / サービス0x5597 / 先頭4バイト
            FeliCaCardSpec(name: "nanaco", systemCode: Data([0xFE, 0x00]), balanceService: Data([0x97, 0x55]), balanceBlock: Data([0x80, 0x00]), balanceOffset: 0, balanceLength: 4, hasHistory: false),
            // WAON: 共通エリア(0xFE00) / サービス0x6817 / 先頭3バイト
            FeliCaCardSpec(name: "WAON", systemCode: Data([0xFE, 0x00]), balanceService: Data([0x17, 0x68]), balanceBlock: Data([0x80, 0x00]), balanceOffset: 0, balanceLength: 3, hasHistory: false),
        ]
    }

    private func readFeliCaBalance(_ tag: NFCFeliCaTag, result: NFCReadResult, completion: @escaping (NFCReadResult) -> Void) {
        tryFeliCaCard(tag, specIndex: 0, result: result, completion: completion)
    }

    /// カード定義を順番に試し、残高が読めたら採用。読めなければ次の定義へ。
    /// すべて読めなくても、タグ情報（IDm/システムコード）は表示する。
    private func tryFeliCaCard(_ tag: NFCFeliCaTag, specIndex: Int, result: NFCReadResult, completion: @escaping (NFCReadResult) -> Void) {
        let specs = feliCaCardSpecs
        guard specIndex < specs.count else {
            completion(result)
            return
        }

        let spec = specs[specIndex]

        // 対象のシステムコードへ切り替え（カードが該当システムを持たなければエラー）
        tag.polling(systemCode: spec.systemCode, requestCode: .noRequest, timeSlot: .max1) { [weak self] (_, _, error) in
            guard let self = self else { return }

            if error != nil {
                self.tryFeliCaCard(tag, specIndex: specIndex + 1, result: result, completion: completion)
                return
            }

            tag.readWithoutEncryption(serviceCodeList: [spec.balanceService], blockList: [spec.balanceBlock]) { [weak self] status1, status2, blockData, readError in
                guard let self = self else { return }

                if readError == nil, status1 == 0x00, status2 == 0x00, let data = blockData.first {
                    let bytes = [UInt8](data)
                    if bytes.count >= spec.balanceOffset + spec.balanceLength {
                        // リトルエンディアンで残高を組み立てる
                        var balance = 0
                        for i in 0..<spec.balanceLength {
                            balance |= Int(bytes[spec.balanceOffset + i]) << (8 * i)
                        }

                        var mutableResult = result
                        mutableResult.felicaBalance = balance
                        mutableResult.felicaCardType = spec.name
                        self.logger.info("FeliCa \(spec.name) balance: \(balance)")

                        if spec.hasHistory {
                            self.readFeliCaHistory(tag, result: mutableResult, completion: completion)
                        } else {
                            completion(mutableResult)
                        }
                        return
                    }
                }

                // 残高が読めなかった → 次のカード定義を試す
                self.tryFeliCaCard(tag, specIndex: specIndex + 1, result: result, completion: completion)
            }
        }
    }

    private func readFeliCaHistory(_ tag: NFCFeliCaTag, result: NFCReadResult, completion: @escaping (NFCReadResult) -> Void) {
        var mutableResult = result

        // 利用履歴サービスコード: 0x090F (リトルエンディアン: 0x0F09)
        let historyServiceCode = Data([0x0F, 0x09])

        tag.requestService(nodeCodeList: [historyServiceCode]) { nodes, error in
            if let error = error {
                self.logger.error("FeliCa history requestService failed: \(error.localizedDescription)")
                completion(mutableResult)
                return
            }

            // サービスが存在するか確認
            self.logger.info("FeliCa history requestService response: \(nodes.map { $0.map { String(format: "%02X", $0) }.joined() })")

            guard let nodeKeyVersion = nodes.first,
                  nodeKeyVersion != Data([0xFF, 0xFF]) else {
                self.logger.info("FeliCa history service not available (0xFFFF)")
                completion(mutableResult)
                return
            }

            // 利用履歴を読み取る（FeliCaは一度に最大12ブロックまで）
            var blockList: [Data] = []
            for i in 0..<12 {
                blockList.append(Data([0x80, UInt8(i)]))
            }

            tag.readWithoutEncryption(serviceCodeList: [historyServiceCode], blockList: blockList) { status1, status2, blockData, error in
                if let error = error {
                    self.logger.error("FeliCa history read failed: \(error.localizedDescription)")
                    completion(mutableResult)
                    return
                }

                self.logger.info("FeliCa history read - status1: \(status1), status2: \(status2), blocks: \(blockData.count)")

                if status1 == 0x00 && status2 == 0x00 {
                    var histories: [FeliCaHistoryEntry] = []

                    for (index, data) in blockData.enumerated() {
                        self.logger.info("History block \(index): \(data.map { String(format: "%02X", $0) }.joined(separator: " "))")
                        guard data.count >= 16 else { continue }

                        // 空のブロックをスキップ（全て0x00の場合）
                        if data.allSatisfy({ $0 == 0x00 }) { continue }

                        let entry = self.parseHistoryBlock(data, index: index)
                        histories.append(entry)
                    }

                    mutableResult.felicaHistories = histories

                    // 残高が取得できていない場合は履歴から取得（フォールバック）
                    if mutableResult.felicaBalance == nil, let firstHistory = histories.first {
                        mutableResult.felicaBalance = firstHistory.balance
                        self.logger.info("FeliCa balance from history: \(firstHistory.balance)")
                    }
                }

                completion(mutableResult)
            }
        }
    }

    // MARK: - FeliCa History Parsing

    private func parseHistoryBlock(_ data: Data, index: Int) -> FeliCaHistoryEntry {
        // Data の添字は絶対インデックスのため、スライス（非ゼロ startIndex）でも
        // 安全に 0 始まりで扱えるよう [UInt8] 配列へ変換する
        let b = [UInt8](data)

        // バイト0: 端末種
        let terminalType = b[0]

        // バイト1: 処理種
        let processType = b[1]

        // バイト4-5: 日付（ビット詰め形式）
        // バイト4の上位7ビット: 年（2000年からのオフセット）
        // バイト4の最下位1ビット + バイト5の上位3ビット: 月
        // バイト5の下位5ビット: 日
        let year = Int(b[4] >> 1) + 2000
        let month = ((b[4] & 1) == 1 ? 8 : 0) + Int(b[5] >> 5)
        let day = Int(b[5] & 0x1F)

        // バイト6-7: 入場駅コード
        let entryStationCode = (Int(b[6]) << 8) + Int(b[7])

        // バイト8-9: 出場駅コード
        let exitStationCode = (Int(b[8]) << 8) + Int(b[9])

        // バイト10-11: 残高（リトルエンディアン）
        let balance = Int(b[10]) + (Int(b[11]) << 8)

        // バイト12-13: 通番
        let sequenceNumber = (Int(b[12]) << 8) + Int(b[13])

        // バイト15: 地域コード（入場: 上位2ビット、出場: 次の2ビット）
        let regionCode = b[15]

        return FeliCaHistoryEntry(
            index: index,
            terminalType: terminalType,
            processType: processType,
            entryStationCode: entryStationCode,
            exitStationCode: exitStationCode,
            balance: balance,
            year: year,
            month: month,
            day: day,
            sequenceNumber: sequenceNumber,
            regionCode: regionCode
        )
    }

    private func getTerminalTypeName(_ type: UInt8) -> String {
        switch type {
        case 0x03: return "精算機"
        case 0x04: return "携帯電話"
        case 0x05: return "券売機"
        case 0x07: return "券売機(定期)"
        case 0x08: return "券売機"
        case 0x09: return "入金機"
        case 0x12: return "自動券売機"
        case 0x14: return "改札機"
        case 0x15: return "自動精算機"
        case 0x16: return "改札機"
        case 0x17: return "簡易改札機"
        case 0x18: return "窓口"
        case 0x19: return "窓口"
        case 0x1A: return "窓口"
        case 0x1B: return "窓口"
        case 0x1C: return "自動精算機"
        case 0x1D: return "自動精算機"
        case 0x1F: return "窓口"
        case 0x46: return "VIEW ALTTE"
        case 0x48: return "VIEW ALTTE"
        case 0xC7: return "物販"
        case 0xC8: return "物販"
        default: return "端末(\(String(format: "0x%02X", type)))"
        }
    }

    private func getProcessTypeName(_ type: UInt8) -> String {
        switch type {
        case 0x01: return "運賃支払"
        case 0x02: return "チャージ"
        case 0x03: return "定期購入"
        case 0x04: return "精算"
        case 0x05: return "精算"
        case 0x06: return "窓口出場"
        case 0x07: return "新規発行"
        case 0x08: return "控除"
        case 0x0C: return "窓口入場"
        case 0x0D: return "バス入金(様)"
        case 0x0F: return "バス支払"
        case 0x11: return "再発行"
        case 0x13: return "支払/払戻"
        case 0x14: return "入金/定期"
        case 0x15: return "券売窓口"
        case 0x1F: return "入金(様)"
        case 0x23: return "窓口"
        case 0x46: return "物販"
        case 0x48: return "物販特典"
        case 0x49: return "入金(様)"
        case 0x4A: return "入金(様)"
        case 0x4B: return "物販取消"
        case 0xC6: return "現金併用"
        case 0xCB: return "入金(様)"
        case 0x84: return "他社精算"
        case 0x85: return "他社精算"
        default: return "処理(\(String(format: "0x%02X", type)))"
        }
    }
}
