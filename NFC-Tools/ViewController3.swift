import UIKit
import CoreNFC
import GoogleMobileAds
import SwiftUI
import OSLog

// MARK: - NFCの状態を管理する列挙型
enum NFCState {
    case standBy    // 待機状態
    case read       // 読み取り状態
    case write      // 書き込み状態
    case delete     // 削除状態
}

// MARK: - LocalizationManager
enum LocalizationManager {

    
    enum MessageKey: String {
        case writePrompt
        case writeSuccess
        case urlWriteSuccess
        case textWriteSuccess
        case emptyText
        case invalidTag
        case writeError
        case readOnlyError
        case invalidURL
        case enterTextOrURL
        case write
        case notification
        case ok
        case cancel
        case urlConfirmation
        case writeAsURL
        case writeAsText
        case multipleTagsDetected
        case unknownTagStatus
        case nfcNotAvailable
        case capacityOverflow
        case payloadCreationFailed
        case writeURLConfirmation
    }
    
    static func message(_ key: MessageKey, language: String? = nil) -> String {
        let lang: String
        if let language = language {
            lang = language
        } else if #available(iOS 16, *) {
            lang = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            lang = Locale.current.languageCode ?? "en"
        }
        return messageTranslations[lang]?[key.rawValue] ?? messageTranslations["en"]?[key.rawValue] ?? key.rawValue
    }
    
    static func urlWriteSuccessMessage(_ url: String, language: String? = nil) -> String {
        let baseMessage = message(.urlWriteSuccess, language: language)
        return "\(baseMessage): \(url)"
    }
    
    private static let messageTranslations: [String: [String: String]] = [
        "en": [
            "writePrompt": "Please hold your iPhone near the NFC tag",
            "writeSuccess": "Writing completed",
            "urlWriteSuccess": "URL has been written",
            "textWriteSuccess": "Text has been written",
            "emptyText": "Please enter text",
            "invalidTag": "This NFC tag is not supported",
            "writeError": "Writing failed",
            "readOnlyError": "This tag is read-only",
            "invalidURL": "Invalid URL",
            "enterTextOrURL": "Enter text or URL",
            "write": "Write",
            "notification": "Notification",
            "ok": "OK",
            "cancel": "Cancel",
            "urlConfirmation": "URL Confirmation",
            "writeAsURL": "Write as URL",
            "writeAsText": "Write as Text",
            "multipleTagsDetected": "Please use only one NFC tag",
            "unknownTagStatus": "Unknown tag status",
            "nfcNotAvailable": "This device doesn't support NFC",
            "capacityOverflow": "Cannot write. Capacity is %@ bytes",
            "payloadCreationFailed": "Failed to create payload",
            "writeURLConfirmation": "Do you want to write the following URL?\n%@"
        ],
        "ar": [
            "writePrompt": "يرجى وضع iPhone بالقرب من علامة NFC",
            "writeSuccess": "اكتمل الكتابة",
            "urlWriteSuccess": "تم كتابة عنوان URL",
            "textWriteSuccess": "تم كتابة النص",
            "emptyText": "الرجاء إدخال النص",
            "invalidTag": "علامة NFC هذه غير مدعومة",
            "writeError": "فشلت الكتابة",
            "readOnlyError": "هذه العلامة للقراءة فقط",
            "invalidURL": "عنوان URL غير صالح",
            "enterTextOrURL": "أدخل النص أو عنوان URL",
            "write": "كتابة",
            "notification": "إشعار",
            "ok": "موافق",
            "cancel": "إلغاء",
            "urlConfirmation": "تأكيد URL",
            "writeAsURL": "كتابة كعنوان URL",
            "writeAsText": "كتابة كنص",
            "multipleTagsDetected": "يرجى استخدام علامة NFC واحدة فقط",
            "unknownTagStatus": "حالة العلامة غير معروفة",
            "nfcNotAvailable": "هذا الجهاز لا يدعم NFC",
            "capacityOverflow": "لا يمكن الكتابة. السعة هي %@ بايت",
            "payloadCreationFailed": "فشل إنشاء المحتوى",
            "writeURLConfirmation": "هل تريد كتابة عنوان URL التالي؟\n%@"
        ],
        "it": [
            "writePrompt": "Avvicina l'iPhone al tag NFC",
            "writeSuccess": "Scrittura completata",
            "urlWriteSuccess": "URL scritto",
            "textWriteSuccess": "Testo scritto",
            "emptyText": "Inserisci il testo",
            "invalidTag": "Questo tag NFC non è supportato",
            "writeError": "Scrittura fallita",
            "readOnlyError": "Questo tag è in sola lettura",
            "invalidURL": "URL non valido",
            "enterTextOrURL": "Inserisci testo o URL",
            "write": "Scrivi",
            "notification": "Notifica",
            "ok": "OK",
            "cancel": "Annulla",
            "urlConfirmation": "Conferma URL",
            "writeAsURL": "Scrivi come URL",
            "writeAsText": "Scrivi come testo",
            "multipleTagsDetected": "Usa solo un tag NFC",
            "unknownTagStatus": "Stato tag sconosciuto",
            "nfcNotAvailable": "Questo dispositivo non supporta NFC",
            "capacityOverflow": "Impossibile scrivere. La capacità è di %@ byte",
            "payloadCreationFailed": "Creazione payload fallita",
            "writeURLConfirmation": "Vuoi scrivere il seguente URL?\n%@"
        ],
        "id": [
            "writePrompt": "Dekatkan iPhone Anda ke tag NFC",
            "writeSuccess": "Penulisan selesai",
            "urlWriteSuccess": "URL telah ditulis",
            "textWriteSuccess": "Teks telah ditulis",
            "emptyText": "Silakan masukkan teks",
            "invalidTag": "Tag NFC ini tidak didukung",
            "writeError": "Penulisan gagal",
            "readOnlyError": "Tag ini hanya bisa dibaca",
            "invalidURL": "URL tidak valid",
            "enterTextOrURL": "Masukkan teks atau URL",
            "write": "Tulis",
            "notification": "Pemberitahuan",
            "ok": "OK",
            "cancel": "Batal",
            "urlConfirmation": "Konfirmasi URL",
            "writeAsURL": "Tulis sebagai URL",
            "writeAsText": "Tulis sebagai teks",
            "multipleTagsDetected": "Gunakan hanya satu tag NFC",
            "unknownTagStatus": "Status tag tidak diketahui",
            "nfcNotAvailable": "Perangkat ini tidak mendukung NFC",
            "capacityOverflow": "Tidak dapat menulis. Kapasitas adalah %@ byte",
            "payloadCreationFailed": "Pembuatan payload gagal",
            "writeURLConfirmation": "Apakah Anda ingin menulis URL berikut?\n%@"
        ],
        "uk": [
            "writePrompt": "Піднесіть iPhone до NFC-мітки",
            "writeSuccess": "Запис завершено",
            "urlWriteSuccess": "URL записано",
            "textWriteSuccess": "Текст записано",
            "emptyText": "Будь ласка, введіть текст",
            "invalidTag": "Ця NFC-мітка не підтримується",
            "writeError": "Помилка запису",
            "readOnlyError": "Ця мітка тільки для читання",
            "invalidURL": "Недійсний URL",
            "enterTextOrURL": "Введіть текст або URL",
            "write": "Записати",
            "notification": "Сповіщення",
            "ok": "OK",
            "cancel": "Скасувати",
            "urlConfirmation": "Підтвердження URL",
            "writeAsURL": "Записати як URL",
            "writeAsText": "Записати як текст",
            "multipleTagsDetected": "Використовуйте лише одну NFC-мітку",
            "unknownTagStatus": "Невідомий статус мітки",
            "nfcNotAvailable": "Цей пристрій не підтримує NFC",
            "capacityOverflow": "Неможливо записати. Ємність становить %@ байт",
            "payloadCreationFailed": "Помилка створення корисного навантаження",
            "writeURLConfirmation": "Бажаєте записати наступний URL?\n%@"
        ],
        "nl": [
            "writePrompt": "Houd je iPhone bij de NFC-tag",
            "writeSuccess": "Schrijven voltooid",
            "urlWriteSuccess": "URL geschreven",
            "textWriteSuccess": "Tekst geschreven",
            "emptyText": "Voer tekst in",
            "invalidTag": "Deze NFC-tag wordt niet ondersteund",
            "writeError": "Schrijven mislukt",
            "readOnlyError": "Deze tag is alleen-lezen",
            "invalidURL": "Ongeldige URL",
            "enterTextOrURL": "Voer tekst of URL in",
            "write": "Schrijven",
            "notification": "Melding",
            "ok": "OK",
            "cancel": "Annuleren",
            "urlConfirmation": "URL-bevestiging",
            "writeAsURL": "Schrijf als URL",
            "writeAsText": "Schrijf als tekst",
            "multipleTagsDetected": "Gebruik slechts één NFC-tag",
            "unknownTagStatus": "Onbekende tagstatus",
            "nfcNotAvailable": "Dit apparaat ondersteunt geen NFC",
            "capacityOverflow": "Kan niet schrijven. Capaciteit is %@ bytes",
            "payloadCreationFailed": "Maken van payload mislukt",
            "writeURLConfirmation": "Wil je de volgende URL schrijven?\n%@"
        ],"ca": [
            "writePrompt": "Apropa l'iPhone a l'etiqueta NFC",
            "writeSuccess": "Escriptura completada",
            "urlWriteSuccess": "URL escrita",
            "textWriteSuccess": "Text escrit",
            "emptyText": "Si us plau, introdueix text",
            "invalidTag": "Aquesta etiqueta NFC no és compatible",
            "writeError": "Error d'escriptura",
            "readOnlyError": "Aquesta etiqueta és només de lectura",
            "invalidURL": "URL no vàlida",
            "enterTextOrURL": "Introdueix text o URL",
            "write": "Escriure",
            "notification": "Notificació",
            "ok": "D'acord",
            "cancel": "Cancel·lar",
            "urlConfirmation": "Confirmació d'URL",
            "writeAsURL": "Escriure com a URL",
            "writeAsText": "Escriure com a text",
            "multipleTagsDetected": "Utilitza només una etiqueta NFC",
            "unknownTagStatus": "Estat d'etiqueta desconegut",
            "nfcNotAvailable": "Aquest dispositiu no és compatible amb NFC",
            "capacityOverflow": "No es pot escriure. La capacitat és de %@ bytes",
            "payloadCreationFailed": "Error en crear la càrrega útil",
            "writeURLConfirmation": "Vols escriure la següent URL?\n%@"
        ],
        "el": [
            "writePrompt": "Τοποθετήστε το iPhone κοντά στην ετικέτα NFC",
            "writeSuccess": "Η εγγραφή ολοκληρώθηκε",
            "urlWriteSuccess": "Το URL εγγράφηκε",
            "textWriteSuccess": "Το κείμενο εγγράφηκε",
            "emptyText": "Παρακαλώ εισάγετε κείμενο",
            "invalidTag": "Αυτή η ετικέτα NFC δεν υποστηρίζεται",
            "writeError": "Αποτυχία εγγραφής",
            "readOnlyError": "Αυτή η ετικέτα είναι μόνο για ανάγνωση",
            "invalidURL": "Μη έγκυρο URL",
            "enterTextOrURL": "Εισάγετε κείμενο ή URL",
            "write": "Εγγραφή",
            "notification": "Ειδοποίηση",
            "ok": "OK",
            "cancel": "Ακύρωση",
            "urlConfirmation": "Επιβεβαίωση URL",
            "writeAsURL": "Εγγραφή ως URL",
            "writeAsText": "Εγγραφή ως κείμενο",
            "multipleTagsDetected": "Χρησιμοποιήστε μόνο μία ετικέτα NFC",
            "unknownTagStatus": "Άγνωστη κατάσταση ετικέτας",
            "nfcNotAvailable": "Αυτή η συσκευή δεν υποστηρίζει NFC",
            "capacityOverflow": "Αδύνατη η εγγραφή. Η χωρητικότητα είναι %@ bytes",
            "payloadCreationFailed": "Αποτυχία δημιουργίας φορτίου",
            "writeURLConfirmation": "Θέλετε να γράψετε το ακόλουθο URL;\n%@"
        ],
        "hr": [
            "writePrompt": "Približite iPhone NFC oznaci",
            "writeSuccess": "Pisanje završeno",
            "urlWriteSuccess": "URL je zapisan",
            "textWriteSuccess": "Tekst je zapisan",
            "emptyText": "Molimo unesite tekst",
            "invalidTag": "Ova NFC oznaka nije podržana",
            "writeError": "Pisanje nije uspjelo",
            "readOnlyError": "Ova oznaka je samo za čitanje",
            "invalidURL": "Nevažeći URL",
            "enterTextOrURL": "Unesite tekst ili URL",
            "write": "Piši",
            "notification": "Obavijest",
            "ok": "U redu",
            "cancel": "Odustani",
            "urlConfirmation": "Potvrda URL-a",
            "writeAsURL": "Zapiši kao URL",
            "writeAsText": "Zapiši kao tekst",
            "multipleTagsDetected": "Koristite samo jednu NFC oznaku",
            "unknownTagStatus": "Nepoznat status oznake",
            "nfcNotAvailable": "Ovaj uređaj ne podržava NFC",
            "capacityOverflow": "Nije moguće pisati. Kapacitet je %@ bajtova",
            "payloadCreationFailed": "Stvaranje podataka nije uspjelo",
            "writeURLConfirmation": "Želite li zapisati sljedeći URL?\n%@"
        ],
        "sv": [
            "writePrompt": "Håll din iPhone nära NFC-taggen",
            "writeSuccess": "Skrivning slutförd",
            "urlWriteSuccess": "URL har skrivits",
            "textWriteSuccess": "Text har skrivits",
            "emptyText": "Vänligen ange text",
            "invalidTag": "Denna NFC-tagg stöds inte",
            "writeError": "Skrivning misslyckades",
            "readOnlyError": "Denna tagg är skrivskyddad",
            "invalidURL": "Ogiltig URL",
            "enterTextOrURL": "Ange text eller URL",
            "write": "Skriv",
            "notification": "Meddelande",
            "ok": "OK",
            "cancel": "Avbryt",
            "urlConfirmation": "URL-bekräftelse",
            "writeAsURL": "Skriv som URL",
            "writeAsText": "Skriv som text",
            "multipleTagsDetected": "Använd endast en NFC-tagg",
            "unknownTagStatus": "Okänd taggstatus",
            "nfcNotAvailable": "Denna enhet stödjer inte NFC",
            "capacityOverflow": "Kan inte skriva. Kapaciteten är %@ bytes",
            "payloadCreationFailed": "Misslyckades med att skapa payload",
            "writeURLConfirmation": "Vill du skriva följande URL?\n%@"
        ],
        "es": [
            "writePrompt": "Acerque su iPhone a la etiqueta NFC",
            "writeSuccess": "Escritura completada",
            "urlWriteSuccess": "URL escrita",
            "textWriteSuccess": "Texto escrito",
            "emptyText": "Por favor, introduzca texto",
            "invalidTag": "Esta etiqueta NFC no es compatible",
            "writeError": "Error de escritura",
            "readOnlyError": "Esta etiqueta es de solo lectura",
            "invalidURL": "URL no válida",
            "enterTextOrURL": "Introduzca texto o URL",
            "write": "Escribir",
            "notification": "Notificación",
            "ok": "Aceptar",
            "cancel": "Cancelar",
            "urlConfirmation": "Confirmación de URL",
            "writeAsURL": "Escribir como URL",
            "writeAsText": "Escribir como texto",
            "multipleTagsDetected": "Use solo una etiqueta NFC",
            "unknownTagStatus": "Estado de etiqueta desconocido",
            "nfcNotAvailable": "Este dispositivo no es compatible con NFC",
            "capacityOverflow": "No se puede escribir. La capacidad es de %@ bytes",
            "payloadCreationFailed": "Error al crear la carga útil",
            "writeURLConfirmation": "¿Desea escribir la siguiente URL?\n%@"
        ],"es-MX": [
            "writePrompt": "Acerque su iPhone a la etiqueta NFC",
            "writeSuccess": "Escritura completada",
            "urlWriteSuccess": "URL escrita",
            "textWriteSuccess": "Texto escrito",
            "emptyText": "Por favor, ingrese texto",
            "invalidTag": "Esta etiqueta NFC no es compatible",
            "writeError": "Error de escritura",
            "readOnlyError": "Esta etiqueta es de solo lectura",
            "invalidURL": "URL no válida",
            "enterTextOrURL": "Ingrese texto o URL",
            "write": "Escribir",
            "notification": "Notificación",
            "ok": "Aceptar",
            "cancel": "Cancelar",
            "urlConfirmation": "Confirmación de URL",
            "writeAsURL": "Escribir como URL",
            "writeAsText": "Escribir como texto",
            "multipleTagsDetected": "Use solo una etiqueta NFC",
            "unknownTagStatus": "Estado de etiqueta desconocido",
            "nfcNotAvailable": "Este dispositivo no es compatible con NFC",
            "capacityOverflow": "No se puede escribir. La capacidad es de %@ bytes",
            "payloadCreationFailed": "Error al crear la carga útil",
            "writeURLConfirmation": "¿Desea escribir la siguiente URL?\n%@"
        ],
        "sk": [
            "writePrompt": "Priložte iPhone k NFC štítku",
            "writeSuccess": "Zápis dokončený",
            "urlWriteSuccess": "URL bola zapísaná",
            "textWriteSuccess": "Text bol zapísaný",
            "emptyText": "Prosím, zadajte text",
            "invalidTag": "Tento NFC štítok nie je podporovaný",
            "writeError": "Zápis zlyhal",
            "readOnlyError": "Tento štítok je iba na čítanie",
            "invalidURL": "Neplatná URL",
            "enterTextOrURL": "Zadajte text alebo URL",
            "write": "Zapísať",
            "notification": "Oznámenie",
            "ok": "OK",
            "cancel": "Zrušiť",
            "urlConfirmation": "Potvrdenie URL",
            "writeAsURL": "Zapísať ako URL",
            "writeAsText": "Zapísať ako text",
            "multipleTagsDetected": "Použite iba jeden NFC štítok",
            "unknownTagStatus": "Neznámy stav štítku",
            "nfcNotAvailable": "Toto zariadenie nepodporuje NFC",
            "capacityOverflow": "Nie je možné zapísať. Kapacita je %@ bajtov",
            "payloadCreationFailed": "Vytvorenie užitočného zaťaženia zlyhalo",
            "writeURLConfirmation": "Chcete zapísať nasledujúcu URL?\n%@"
        ],
        "th": [
            "writePrompt": "กรุณานำ iPhone ใกล้กับแท็ก NFC",
            "writeSuccess": "การเขียนเสร็จสมบูรณ์",
            "urlWriteSuccess": "เขียน URL แล้ว",
            "textWriteSuccess": "เขียนข้อความแล้ว",
            "emptyText": "กรุณาป้อนข้อความ",
            "invalidTag": "ไม่รองรับแท็ก NFC นี้",
            "writeError": "การเขียนล้มเหลว",
            "readOnlyError": "แท็กนี้เป็นแบบอ่านอย่างเดียว",
            "invalidURL": "URL ไม่ถูกต้อง",
            "enterTextOrURL": "ป้อนข้อความหรือ URL",
            "write": "เขียน",
            "notification": "การแจ้งเตือน",
            "ok": "ตกลง",
            "cancel": "ยกเลิก",
            "urlConfirmation": "ยืนยัน URL",
            "writeAsURL": "เขียนเป็น URL",
            "writeAsText": "เขียนเป็นข้อความ",
            "multipleTagsDetected": "กรุณาใช้แท็ก NFC เพียงอันเดียว",
            "unknownTagStatus": "สถานะแท็กไม่ทราบ",
            "nfcNotAvailable": "อุปกรณ์นี้ไม่รองรับ NFC",
            "capacityOverflow": "ไม่สามารถเขียนได้ ความจุคือ %@ ไบต์",
            "payloadCreationFailed": "การสร้างเพย์โหลดล้มเหลว",
            "writeURLConfirmation": "คุณต้องการเขียน URL ต่อไปนี้หรือไม่?\n%@"
        ],
        "cs": [
            "writePrompt": "Přiložte iPhone k NFC štítku",
            "writeSuccess": "Zápis dokončen",
            "urlWriteSuccess": "URL byla zapsána",
            "textWriteSuccess": "Text byl zapsán",
            "emptyText": "Prosím zadejte text",
            "invalidTag": "Tento NFC štítek není podporován",
            "writeError": "Zápis selhal",
            "readOnlyError": "Tento štítek je pouze pro čtení",
            "invalidURL": "Neplatná URL",
            "enterTextOrURL": "Zadejte text nebo URL",
            "write": "Zapsat",
            "notification": "Oznámení",
            "ok": "OK",
            "cancel": "Zrušit",
            "urlConfirmation": "Potvrzení URL",
            "writeAsURL": "Zapsat jako URL",
            "writeAsText": "Zapsat jako text",
            "multipleTagsDetected": "Použijte pouze jeden NFC štítek",
            "unknownTagStatus": "Neznámý stav štítku",
            "nfcNotAvailable": "Toto zařízení nepodporuje NFC",
            "capacityOverflow": "Nelze zapisovat. Kapacita je %@ bajtů",
            "payloadCreationFailed": "Vytvoření dat selhalo",
            "writeURLConfirmation": "Chcete zapsat následující URL?\n%@"
        ],
        "da": [
            "writePrompt": "Hold din iPhone tæt på NFC-mærket",
            "writeSuccess": "Skrivning fuldført",
            "urlWriteSuccess": "URL er skrevet",
            "textWriteSuccess": "Tekst er skrevet",
            "emptyText": "Indtast venligst tekst",
            "invalidTag": "Dette NFC-mærke understøttes ikke",
            "writeError": "Skrivning mislykkedes",
            "readOnlyError": "Dette mærke er skrivebeskyttet",
            "invalidURL": "Ugyldig URL",
            "enterTextOrURL": "Indtast tekst eller URL",
            "write": "Skriv",
            "notification": "Meddelelse",
            "ok": "OK",
            "cancel": "Annuller",
            "urlConfirmation": "URL-bekræftelse",
            "writeAsURL": "Skriv som URL",
            "writeAsText": "Skriv som tekst",
            "multipleTagsDetected": "Brug kun ét NFC-mærke",
            "unknownTagStatus": "Ukendt mærkestatus",
            "nfcNotAvailable": "Denne enhed understøtter ikke NFC",
            "capacityOverflow": "Kan ikke skrive. Kapaciteten er %@ bytes",
            "payloadCreationFailed": "Oprettelse af payload mislykkedes",
            "writeURLConfirmation": "Vil du skrive følgende URL?\n%@"
        ],"de": [
            "writePrompt": "Halten Sie Ihr iPhone an den NFC-Tag",
            "writeSuccess": "Schreiben abgeschlossen",
            "urlWriteSuccess": "URL wurde geschrieben",
            "textWriteSuccess": "Text wurde geschrieben",
            "emptyText": "Bitte Text eingeben",
            "invalidTag": "Dieser NFC-Tag wird nicht unterstützt",
            "writeError": "Schreiben fehlgeschlagen",
            "readOnlyError": "Dieser Tag ist schreibgeschützt",
            "invalidURL": "Ungültige URL",
            "enterTextOrURL": "Text oder URL eingeben",
            "write": "Schreiben",
            "notification": "Benachrichtigung",
            "ok": "OK",
            "cancel": "Abbrechen",
            "urlConfirmation": "URL-Bestätigung",
            "writeAsURL": "Als URL schreiben",
            "writeAsText": "Als Text schreiben",
            "multipleTagsDetected": "Bitte nur einen NFC-Tag verwenden",
            "unknownTagStatus": "Unbekannter Tag-Status",
            "nfcNotAvailable": "Dieses Gerät unterstützt kein NFC",
            "capacityOverflow": "Kann nicht schreiben. Kapazität ist %@ Bytes",
            "payloadCreationFailed": "Payload-Erstellung fehlgeschlagen",
            "writeURLConfirmation": "Möchten Sie die folgende URL schreiben?\n%@"
        ],
        "tr": [
            "writePrompt": "iPhone'unuzu NFC etiketine yaklaştırın",
            "writeSuccess": "Yazma tamamlandı",
            "urlWriteSuccess": "URL yazıldı",
            "textWriteSuccess": "Metin yazıldı",
            "emptyText": "Lütfen metin girin",
            "invalidTag": "Bu NFC etiketi desteklenmiyor",
            "writeError": "Yazma başarısız",
            "readOnlyError": "Bu etiket salt okunur",
            "invalidURL": "Geçersiz URL",
            "enterTextOrURL": "Metin veya URL girin",
            "write": "Yaz",
            "notification": "Bildirim",
            "ok": "Tamam",
            "cancel": "İptal",
            "urlConfirmation": "URL Onayı",
            "writeAsURL": "URL olarak yaz",
            "writeAsText": "Metin olarak yaz",
            "multipleTagsDetected": "Lütfen sadece bir NFC etiketi kullanın",
            "unknownTagStatus": "Bilinmeyen etiket durumu",
            "nfcNotAvailable": "Bu cihaz NFC'yi desteklemiyor",
            "capacityOverflow": "Yazılamıyor. Kapasite %@ bayt",
            "payloadCreationFailed": "Yük oluşturma başarısız",
            "writeURLConfirmation": "Aşağıdaki URL'yi yazmak istiyor musunuz?\n%@"
        ],
        "no": [
            "writePrompt": "Hold iPhone nær NFC-brikken",
            "writeSuccess": "Skriving fullført",
            "urlWriteSuccess": "URL er skrevet",
            "textWriteSuccess": "Tekst er skrevet",
            "emptyText": "Vennligst skriv inn tekst",
            "invalidTag": "Denne NFC-brikken støttes ikke",
            "writeError": "Skriving mislyktes",
            "readOnlyError": "Denne brikken er skrivebeskyttet",
            "invalidURL": "Ugyldig URL",
            "enterTextOrURL": "Skriv inn tekst eller URL",
            "write": "Skriv",
            "notification": "Varsel",
            "ok": "OK",
            "cancel": "Avbryt",
            "urlConfirmation": "URL-bekreftelse",
            "writeAsURL": "Skriv som URL",
            "writeAsText": "Skriv som tekst",
            "multipleTagsDetected": "Bruk kun én NFC-brikke",
            "unknownTagStatus": "Ukjent brikkestatus",
            "nfcNotAvailable": "Denne enheten støtter ikke NFC",
            "capacityOverflow": "Kan ikke skrive. Kapasiteten er %@ bytes",
            "payloadCreationFailed": "Opprettelse av nyttelast mislyktes",
            "writeURLConfirmation": "Vil du skrive følgende URL?\n%@"
        ],
        "hu": [
            "writePrompt": "Tartsa az iPhone-t az NFC címke közelébe",
            "writeSuccess": "Írás befejezve",
            "urlWriteSuccess": "URL írása megtörtént",
            "textWriteSuccess": "Szöveg írása megtörtént",
            "emptyText": "Kérjük, írjon be szöveget",
            "invalidTag": "Ez az NFC címke nem támogatott",
            "writeError": "Írás sikertelen",
            "readOnlyError": "Ez a címke csak olvasható",
            "invalidURL": "Érvénytelen URL",
            "enterTextOrURL": "Írjon be szöveget vagy URL-t",
            "write": "Írás",
            "notification": "Értesítés",
            "ok": "OK",
            "cancel": "Mégse",
            "urlConfirmation": "URL megerősítése",
            "writeAsURL": "Írás URL-ként",
            "writeAsText": "Írás szövegként",
            "multipleTagsDetected": "Csak egy NFC címkét használjon",
            "unknownTagStatus": "Ismeretlen címke állapot",
            "nfcNotAvailable": "Ez az eszköz nem támogatja az NFC-t",
            "capacityOverflow": "Nem lehet írni. A kapacitás %@ byte",
            "payloadCreationFailed": "Payload létrehozása sikertelen",
            "writeURLConfirmation": "Szeretné írni a következő URL-t?\n%@"
        ],
        "hi": [
            "writePrompt": "अपने iPhone को NFC टैग के पास रखें",
            "writeSuccess": "लेखन पूर्ण हुआ",
            "urlWriteSuccess": "URL लिखा गया",
            "textWriteSuccess": "टेक्स्ट लिखा गया",
            "emptyText": "कृपया टेक्स्ट दर्ज करें",
            "invalidTag": "यह NFC टैग समर्थित नहीं है",
            "writeError": "लेखन विफल",
            "readOnlyError": "यह टैग केवल पठनीय है",
            "invalidURL": "अमान्य URL",
            "enterTextOrURL": "टेक्स्ट या URL दर्ज करें",
            "write": "लिखें",
            "notification": "सूचना",
            "ok": "ठीक है",
            "cancel": "रद्द करें",
            "urlConfirmation": "URL पुष्टि",
            "writeAsURL": "URL के रूप में लिखें",
            "writeAsText": "टेक्स्ट के रूप में लिखें",
            "multipleTagsDetected": "कृपया केवल एक NFC टैग का उपयोग करें",
            "unknownTagStatus": "अज्ञात टैग स्थिति",
            "nfcNotAvailable": "यह डिवाइस NFC का समर्थन नहीं करता है",
            "capacityOverflow": "नहीं लिख सकते। क्षमता %@ बाइट्स है",
            "payloadCreationFailed": "पेलोड बनाना विफल रहा",
            "writeURLConfirmation": "क्या आप निम्नलिखित URL लिखना चाहते हैं?\n%@"
        ],
        "fi": [
                "writePrompt": "Pidä iPhonea NFC-tunnisteen lähellä",
                "writeSuccess": "Kirjoitus valmis",
                "urlWriteSuccess": "URL kirjoitettu",
                "textWriteSuccess": "Teksti kirjoitettu",
                "emptyText": "Syötä teksti",
                "invalidTag": "Tätä NFC-tunnistetta ei tueta",
                "writeError": "Kirjoitus epäonnistui",
                "readOnlyError": "Tämä tunniste on vain luettavissa",
                "invalidURL": "Virheellinen URL",
                "enterTextOrURL": "Syötä teksti tai URL",
                "write": "Kirjoita",
                "notification": "Ilmoitus",
                "ok": "OK",
                "cancel": "Peruuta",
                "urlConfirmation": "URL-vahvistus",
                "writeAsURL": "Kirjoita URL:nä",
                "writeAsText": "Kirjoita tekstinä",
                "multipleTagsDetected": "Käytä vain yhtä NFC-tunnistetta",
                "unknownTagStatus": "Tuntematon tunnisteen tila",
                "nfcNotAvailable": "Tämä laite ei tue NFC:tä",
                "capacityOverflow": "Ei voi kirjoittaa. Kapasiteetti on %@ tavua",
                "payloadCreationFailed": "Hyötykuorman luonti epäonnistui",
                "writeURLConfirmation": "Haluatko kirjoittaa seuraavan URL:n?\n%@"
            ],
            "fr": [
                "writePrompt": "Approchez votre iPhone de l'étiquette NFC",
                "writeSuccess": "Écriture terminée",
                "urlWriteSuccess": "URL écrite",
                "textWriteSuccess": "Texte écrit",
                "emptyText": "Veuillez saisir du texte",
                "invalidTag": "Cette étiquette NFC n'est pas prise en charge",
                "writeError": "Échec de l'écriture",
                "readOnlyError": "Cette étiquette est en lecture seule",
                "invalidURL": "URL invalide",
                "enterTextOrURL": "Saisissez du texte ou une URL",
                "write": "Écrire",
                "notification": "Notification",
                "ok": "OK",
                "cancel": "Annuler",
                "urlConfirmation": "Confirmation de l'URL",
                "writeAsURL": "Écrire comme URL",
                "writeAsText": "Écrire comme texte",
                "multipleTagsDetected": "Utilisez une seule étiquette NFC",
                "unknownTagStatus": "État d'étiquette inconnu",
                "nfcNotAvailable": "Cet appareil ne prend pas en charge NFC",
                "capacityOverflow": "Impossible d'écrire. La capacité est de %@ octets",
                "payloadCreationFailed": "Échec de la création de la charge utile",
                "writeURLConfirmation": "Voulez-vous écrire l'URL suivante ?\n%@"
            ],
            "fr-CA": [
                "writePrompt": "Approchez votre iPhone de l'étiquette NFC",
                "writeSuccess": "Écriture complétée",
                "urlWriteSuccess": "URL écrite",
                "textWriteSuccess": "Texte écrit",
                "emptyText": "Veuillez saisir du texte",
                "invalidTag": "Cette étiquette NFC n'est pas supportée",
                "writeError": "Échec de l'écriture",
                "readOnlyError": "Cette étiquette est en lecture seule",
                "invalidURL": "URL invalide",
                "enterTextOrURL": "Saisissez du texte ou une URL",
                "write": "Écrire",
                "notification": "Notification",
                "ok": "OK",
                "cancel": "Annuler",
                "urlConfirmation": "Confirmation de l'URL",
                "writeAsURL": "Écrire comme URL",
                "writeAsText": "Écrire comme texte",
                "multipleTagsDetected": "Utilisez une seule étiquette NFC",
                "unknownTagStatus": "État d'étiquette inconnu",
                "nfcNotAvailable": "Cet appareil ne supporte pas NFC",
                "capacityOverflow": "Impossible d'écrire. La capacité est de %@ octets",
                "payloadCreationFailed": "Échec de la création du contenu",
                "writeURLConfirmation": "Voulez-vous écrire l'URL suivante ?\n%@"
            ],
            "vi": [
                "writePrompt": "Đặt iPhone gần thẻ NFC",
                "writeSuccess": "Ghi hoàn tất",
                "urlWriteSuccess": "Đã ghi URL",
                "textWriteSuccess": "Đã ghi văn bản",
                "emptyText": "Vui lòng nhập văn bản",
                "invalidTag": "Thẻ NFC này không được hỗ trợ",
                "writeError": "Ghi thất bại",
                "readOnlyError": "Thẻ này chỉ đọc",
                "invalidURL": "URL không hợp lệ",
                "enterTextOrURL": "Nhập văn bản hoặc URL",
                "write": "Ghi",
                "notification": "Thông báo",
                "ok": "OK",
                "cancel": "Hủy",
                "urlConfirmation": "Xác nhận URL",
                "writeAsURL": "Ghi như URL",
                "writeAsText": "Ghi như văn bản",
                "multipleTagsDetected": "Vui lòng chỉ sử dụng một thẻ NFC",
                "unknownTagStatus": "Trạng thái thẻ không xác định",
                "nfcNotAvailable": "Thiết bị này không hỗ trợ NFC",
                "capacityOverflow": "Không thể ghi. Dung lượng là %@ byte",
                "payloadCreationFailed": "Tạo payload thất bại",
                "writeURLConfirmation": "Bạn có muốn ghi URL sau không?\n%@"
            ],
            "he": [
                "writePrompt": "קרב את האייפון לתג NFC",
                "writeSuccess": "הכתיבה הושלמה",
                "urlWriteSuccess": "כתובת האתר נכתבה",
                "textWriteSuccess": "הטקסט נכתב",
                "emptyText": "נא להזין טקסט",
                "invalidTag": "תג NFC זה אינו נתמך",
                "writeError": "הכתיבה נכשלה",
                "readOnlyError": "תג זה הוא לקריאה בלבד",
                "invalidURL": "כתובת אתר לא חוקית",
                "enterTextOrURL": "הזן טקסט או כתובת אתר",
                "write": "כתיבה",
                "notification": "התראה",
                "ok": "אישור",
                "cancel": "ביטול",
                "urlConfirmation": "אישור כתובת אתר",
                "writeAsURL": "כתוב ככתובת אתר",
                "writeAsText": "כתוב כטקסט",
                "multipleTagsDetected": "נא להשתמש בתג NFC אחד בלבד",
                "unknownTagStatus": "סטטוס תג לא ידוע",
                "nfcNotAvailable": "מכשיר זה אינו תומך ב-NFC",
                "capacityOverflow": "לא ניתן לכתוב. הקיבולת היא %@ בתים",
                "payloadCreationFailed": "יצירת המטען נכשלה",
                "writeURLConfirmation": "האם ברצונך לכתוב את כתובת האתר הבאה?\n%@"
            ],
        "pl": [
                "writePrompt": "Przyłóż iPhone'a do tagu NFC",
                "writeSuccess": "Zapisywanie zakończone",
                "urlWriteSuccess": "URL został zapisany",
                "textWriteSuccess": "Tekst został zapisany",
                "emptyText": "Wprowadź tekst",
                "invalidTag": "Ten tag NFC nie jest obsługiwany",
                "writeError": "Błąd zapisu",
                "readOnlyError": "Ten tag jest tylko do odczytu",
                "invalidURL": "Nieprawidłowy URL",
                "enterTextOrURL": "Wprowadź tekst lub URL",
                "write": "Zapisz",
                "notification": "Powiadomienie",
                "ok": "OK",
                "cancel": "Anuluj",
                "urlConfirmation": "Potwierdzenie URL",
                "writeAsURL": "Zapisz jako URL",
                "writeAsText": "Zapisz jako tekst",
                "multipleTagsDetected": "Użyj tylko jednego tagu NFC",
                "unknownTagStatus": "Nieznany status tagu",
                "nfcNotAvailable": "To urządzenie nie obsługuje NFC",
                "capacityOverflow": "Nie można zapisać. Pojemność wynosi %@ bajtów",
                "payloadCreationFailed": "Utworzenie payload nie powiodło się",
                "writeURLConfirmation": "Czy chcesz zapisać następujący URL?\n%@"
            ],
            "pt-BR": [
                "writePrompt": "Aproxime seu iPhone da tag NFC",
                "writeSuccess": "Gravação concluída",
                "urlWriteSuccess": "URL gravada",
                "textWriteSuccess": "Texto gravado",
                "emptyText": "Por favor, insira o texto",
                "invalidTag": "Esta tag NFC não é suportada",
                "writeError": "Falha na gravação",
                "readOnlyError": "Esta tag é somente leitura",
                "invalidURL": "URL inválida",
                "enterTextOrURL": "Insira texto ou URL",
                "write": "Gravar",
                "notification": "Notificação",
                "ok": "OK",
                "cancel": "Cancelar",
                "urlConfirmation": "Confirmação de URL",
                "writeAsURL": "Gravar como URL",
                "writeAsText": "Gravar como texto",
                "multipleTagsDetected": "Use apenas uma tag NFC",
                "unknownTagStatus": "Status de tag desconhecido",
                "nfcNotAvailable": "Este dispositivo não suporta NFC",
                "capacityOverflow": "Não é possível gravar. A capacidade é de %@ bytes",
                "payloadCreationFailed": "Falha na criação do payload",
                "writeURLConfirmation": "Deseja gravar a seguinte URL?\n%@"
            ],
            "pt-PT": [
                "writePrompt": "Aproxime o seu iPhone da etiqueta NFC",
                "writeSuccess": "Gravação concluída",
                "urlWriteSuccess": "URL gravado",
                "textWriteSuccess": "Texto gravado",
                "emptyText": "Por favor, introduza o texto",
                "invalidTag": "Esta etiqueta NFC não é suportada",
                "writeError": "Falha na gravação",
                "readOnlyError": "Esta etiqueta é apenas de leitura",
                "invalidURL": "URL inválido",
                "enterTextOrURL": "Introduza texto ou URL",
                "write": "Gravar",
                "notification": "Notificação",
                "ok": "OK",
                "cancel": "Cancelar",
                "urlConfirmation": "Confirmação de URL",
                "writeAsURL": "Gravar como URL",
                "writeAsText": "Gravar como texto",
                "multipleTagsDetected": "Use apenas uma etiqueta NFC",
                "unknownTagStatus": "Estado de etiqueta desconhecido",
                "nfcNotAvailable": "Este dispositivo não suporta NFC",
                "capacityOverflow": "Não é possível gravar. A capacidade é de %@ bytes",
                "payloadCreationFailed": "Falha na criação do payload",
                "writeURLConfirmation": "Deseja gravar o seguinte URL?\n%@"
            ],
            "ms": [
                "writePrompt": "Dekatkan iPhone anda pada tag NFC",
                "writeSuccess": "Penulisan selesai",
                "urlWriteSuccess": "URL telah ditulis",
                "textWriteSuccess": "Teks telah ditulis",
                "emptyText": "Sila masukkan teks",
                "invalidTag": "Tag NFC ini tidak disokong",
                "writeError": "Penulisan gagal",
                "readOnlyError": "Tag ini adalah baca sahaja",
                "invalidURL": "URL tidak sah",
                "enterTextOrURL": "Masukkan teks atau URL",
                "write": "Tulis",
                "notification": "Pemberitahuan",
                "ok": "OK",
                "cancel": "Batal",
                "urlConfirmation": "Pengesahan URL",
                "writeAsURL": "Tulis sebagai URL",
                "writeAsText": "Tulis sebagai teks",
                "multipleTagsDetected": "Sila gunakan satu tag NFC sahaja",
                "unknownTagStatus": "Status tag tidak diketahui",
                "nfcNotAvailable": "Peranti ini tidak menyokong NFC",
                "capacityOverflow": "Tidak dapat menulis. Kapasiti adalah %@ bait",
                "payloadCreationFailed": "Pembuatan payload gagal",
                "writeURLConfirmation": "Adakah anda ingin menulis URL berikut?\n%@"
            ],
            "ro": [
                "writePrompt": "Apropiați iPhone-ul de eticheta NFC",
                "writeSuccess": "Scriere finalizată",
                "urlWriteSuccess": "URL-ul a fost scris",
                "textWriteSuccess": "Textul a fost scris",
                "emptyText": "Vă rugăm să introduceți text",
                "invalidTag": "Această etichetă NFC nu este suportată",
                "writeError": "Scrierea a eșuat",
                "readOnlyError": "Această etichetă este doar pentru citire",
                "invalidURL": "URL invalid",
                "enterTextOrURL": "Introduceți text sau URL",
                "write": "Scrieți",
                "notification": "Notificare",
                "ok": "OK",
                "cancel": "Anulare",
                "urlConfirmation": "Confirmare URL",
                "writeAsURL": "Scrieți ca URL",
                "writeAsText": "Scrieți ca text",
                "multipleTagsDetected": "Vă rugăm să folosiți o singură etichetă NFC",
                "unknownTagStatus": "Stare etichetă necunoscută",
                "nfcNotAvailable": "Acest dispozitiv nu suportă NFC",
                "capacityOverflow": "Nu se poate scrie. Capacitatea este de %@ bytes",
                "payloadCreationFailed": "Crearea payload-ului a eșuat",
                "writeURLConfirmation": "Doriți să scrieți următorul URL?\n%@"
            ],
        "ru": [
                "writePrompt": "Поднесите iPhone к NFC-метке",
                "writeSuccess": "Запись завершена",
                "urlWriteSuccess": "URL записан",
                "textWriteSuccess": "Текст записан",
                "emptyText": "Пожалуйста, введите текст",
                "invalidTag": "Эта NFC-метка не поддерживается",
                "writeError": "Ошибка записи",
                "readOnlyError": "Эта метка только для чтения",
                "invalidURL": "Недействительный URL",
                "enterTextOrURL": "Введите текст или URL",
                "write": "Записать",
                "notification": "Уведомление",
                "ok": "OK",
                "cancel": "Отмена",
                "urlConfirmation": "Подтверждение URL",
                "writeAsURL": "Записать как URL",
                "writeAsText": "Записать как текст",
                "multipleTagsDetected": "Используйте только одну NFC-метку",
                "unknownTagStatus": "Неизвестный статус метки",
                "nfcNotAvailable": "Это устройство не поддерживает NFC",
                "capacityOverflow": "Невозможно записать. Ёмкость составляет %@ байт",
                "payloadCreationFailed": "Не удалось создать полезную нагрузку",
                "writeURLConfirmation": "Хотите записать следующий URL?\n%@"
            ],
            "ko": [
                "writePrompt": "iPhone을 NFC 태그에 가까이 대주세요",
                "writeSuccess": "쓰기가 완료되었습니다",
                "urlWriteSuccess": "URL이 기록되었습니다",
                "textWriteSuccess": "텍스트가 기록되었습니다",
                "emptyText": "텍스트를 입력해주세요",
                "invalidTag": "이 NFC 태그는 지원되지 않습니다",
                "writeError": "쓰기 실패",
                "readOnlyError": "이 태그는 읽기 전용입니다",
                "invalidURL": "잘못된 URL",
                "enterTextOrURL": "텍스트 또는 URL 입력",
                "write": "쓰기",
                "notification": "알림",
                "ok": "확인",
                "cancel": "취소",
                "urlConfirmation": "URL 확인",
                "writeAsURL": "URL로 쓰기",
                "writeAsText": "텍스트로 쓰기",
                "multipleTagsDetected": "NFC 태그 하나만 사용해주세요",
                "unknownTagStatus": "알 수 없는 태그 상태",
                "nfcNotAvailable": "이 기기는 NFC를 지원하지 않습니다",
                "capacityOverflow": "쓸 수 없습니다. 용량이 %@ 바이트입니다",
                "payloadCreationFailed": "페이로드 생성 실패",
                "writeURLConfirmation": "다음 URL을 쓰시겠습니까?\n%@"
            ],
            "zh": [
                "writePrompt": "请将iPhone靠近NFC标签",
                "writeSuccess": "写入完成",
                "urlWriteSuccess": "URL已写入",
                "textWriteSuccess": "文本已写入",
                "emptyText": "请输入文本",
                "invalidTag": "不支持此NFC标签",
                "writeError": "写入失败",
                "readOnlyError": "此标签为只读",
                "invalidURL": "无效的URL",
                "enterTextOrURL": "输入文本或URL",
                "write": "写入",
                "notification": "通知",
                "ok": "确定",
                "cancel": "取消",
                "urlConfirmation": "URL确认",
                "writeAsURL": "作为URL写入",
                "writeAsText": "作为文本写入",
                "multipleTagsDetected": "请只使用一个NFC标签",
                "unknownTagStatus": "未知标签状态",
                "nfcNotAvailable": "此设备不支持NFC",
                "capacityOverflow": "无法写入。容量为%@字节",
                "payloadCreationFailed": "载荷创建失败",
                "writeURLConfirmation": "是否要写入以下URL？\n%@"
            ],
            "zh-Hant": [
                "writePrompt": "請將iPhone靠近NFC標籤",
                "writeSuccess": "寫入完成",
                "urlWriteSuccess": "URL已寫入",
                "textWriteSuccess": "文字已寫入",
                "emptyText": "請輸入文字",
                "invalidTag": "不支援此NFC標籤",
                "writeError": "寫入失敗",
                "readOnlyError": "此標籤為唯讀",
                "invalidURL": "無效的URL",
                "enterTextOrURL": "輸入文字或URL",
                "write": "寫入",
                "notification": "通知",
                "ok": "確定",
                "cancel": "取消",
                "urlConfirmation": "URL確認",
                "writeAsURL": "作為URL寫入",
                "writeAsText": "作為文字寫入",
                "multipleTagsDetected": "請只使用一個NFC標籤",
                "unknownTagStatus": "未知標籤狀態",
                "nfcNotAvailable": "此裝置不支援NFC",
                "capacityOverflow": "無法寫入。容量為%@位元組",
                "payloadCreationFailed": "裝載建立失敗",
                "writeURLConfirmation": "是否要寫入以下URL？\n%@"
            ],
            "en-GB": [
                "writePrompt": "Please hold your iPhone near the NFC tag",
                "writeSuccess": "Writing completed",
                "urlWriteSuccess": "URL has been written",
                "textWriteSuccess": "Text has been written",
                "emptyText": "Please enter text",
                "invalidTag": "This NFC tag is not supported",
                "writeError": "Writing failed",
                "readOnlyError": "This tag is read-only",
                "invalidURL": "Invalid URL",
                "enterTextOrURL": "Enter text or URL",
                "write": "Write",
                "notification": "Notification",
                "ok": "OK",
                "cancel": "Cancel",
                "urlConfirmation": "URL Confirmation",
                "writeAsURL": "Write as URL",
                "writeAsText": "Write as Text",
                "multipleTagsDetected": "Please use only one NFC tag",
                "unknownTagStatus": "Unknown tag status",
                "nfcNotAvailable": "This device doesn't support NFC",
                "capacityOverflow": "Cannot write. Capacity is %@ bytes",
                "payloadCreationFailed": "Failed to create payload",
                "writeURLConfirmation": "Do you want to write the following URL?\n%@"
            ],
            "en-AU": [
                "writePrompt": "Please hold your iPhone near the NFC tag",
                "writeSuccess": "Writing completed",
                "urlWriteSuccess": "URL has been written",
                "textWriteSuccess": "Text has been written",
                "emptyText": "Please enter text",
                "invalidTag": "This NFC tag is not supported",
                "writeError": "Writing failed",
                "readOnlyError": "This tag is read-only",
                "invalidURL": "Invalid URL",
                "enterTextOrURL": "Enter text or URL",
                "write": "Write",
                "notification": "Notification",
                "ok": "OK",
                "cancel": "Cancel",
                "urlConfirmation": "URL Confirmation",
                "writeAsURL": "Write as URL",
                "writeAsText": "Write as Text",
                "multipleTagsDetected": "Please use only one NFC tag",
                "unknownTagStatus": "Unknown tag status",
                "nfcNotAvailable": "This device doesn't support NFC",
                "capacityOverflow": "Cannot write. Capacity is %@ bytes",
                "payloadCreationFailed": "Failed to create payload",
                "writeURLConfirmation": "Do you want to write the following URL?\n%@"
            ],
            "en-CA": [
                "writePrompt": "Please hold your iPhone near the NFC tag",
                "writeSuccess": "Writing completed",
                "urlWriteSuccess": "URL has been written",
                "textWriteSuccess": "Text has been written",
                "emptyText": "Please enter text",
                "invalidTag": "This NFC tag is not supported",
                "writeError": "Writing failed",
                "readOnlyError": "This tag is read-only",
                "invalidURL": "Invalid URL",
                "enterTextOrURL": "Enter text or URL",
                "write": "Write",
                "notification": "Notification",
                "ok": "OK",
                "cancel": "Cancel",
                "urlConfirmation": "URL Confirmation",
                "writeAsURL": "Write as URL",
                "writeAsText": "Write as Text",
                "multipleTagsDetected": "Please use only one NFC tag",
                "unknownTagStatus": "Unknown tag status",
                "nfcNotAvailable": "This device doesn't support NFC",
                "capacityOverflow": "Cannot write. Capacity is %@ bytes",
                "payloadCreationFailed": "Failed to create payload",
                "writeURLConfirmation": "Do you want to write the following URL?\n%@"
            ],
            
        "ja": [
            "writePrompt": "NFCタグをiPhone上部に近づけてください",
            "writeSuccess": "書き込みが完了しました",
            "urlWriteSuccess": "URLを書き込みました",
            "textWriteSuccess": "テキストを書き込みました",
            "emptyText": "テキストを入力してください",
            "invalidTag": "このNFCタグは対応していません",
            "writeError": "書き込みに失敗しました",
            "readOnlyError": "このタグは読み取り専用です",
            "invalidURL": "無効なURLです",
            "enterTextOrURL": "テキストまたはURLを入力",
            "write": "書き込む",
            "notification": "通知",
            "ok": "OK",
            "cancel": "キャンセル",
            "urlConfirmation": "URLの確認",
            "writeAsURL": "URLとして書き込む",
            "writeAsText": "テキストとして書き込む",
            "multipleTagsDetected": "読み込ませるNFCタグは1枚にしてください",
            "unknownTagStatus": "不明なタグステータスです",
            "nfcNotAvailable": "このデバイスはNFCに対応していません",
            "capacityOverflow": "容量オーバーで書き込めません！\n容量は%@bytesです",
            "payloadCreationFailed": "ペイロードの作成に失敗しました",
            "writeURLConfirmation": "以下のURLを書き込みますか？\n%@"
        ]
    ]
}

// MARK: - Constants
private enum Constants {
    static let adUnitID = "ca-app-pub-1187210314934709/5463627829"
    static let nativeAdUnitID = "ca-app-pub-1187210314934709/1149830919"
    static let validSchemes = ["http", "https"]
    
    enum UserDefaults {
        static let firstLaunchKey = "firstLunch"
    }
}


// MARK: - NFCの書き込みコントローラ
final class ViewController3: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var writeBtn: UIButton!
    @IBOutlet private weak var bannerView: GADBannerView!
    @IBOutlet private weak var mediaView: GADMediaView!
    @IBOutlet private weak var userNameTextField: UITextField! // 新規追加
    @IBOutlet private weak var instagramButton: UIButton!
    @IBOutlet private weak var xButton: UIButton!
    @IBOutlet private weak var youtubeButton: UIButton!
    @IBOutlet private weak var facebookButton: UIButton!
    
    // MARK: - Properties
    private lazy var logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "NFCWrite")
    private var session: NFCNDEFReaderSession?
    private var message: NFCNDEFMessage?
    private var state: NFCState = .standBy
    private var text: String = ""
    private var adLoader: GADAdLoader!
    
    
    
    // MARK: - Lifecycle Methods
    private func setupUI() {
        textFieldSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkFirstLaunch()
    }
    
    private func textFieldSetup() {
        textField.delegate = self
        textField.placeholder = "テキストまたはURLを入力"
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
    }


    // MARK: - 広告の設定
    private func configureAds() {
        bannerView.adUnitID = Constants.adUnitID
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBannerAd()         // バナー広告の初期設定とロード
    }
    
    
    private func validateUserNameInput() -> String? {
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            presentAlert(message: "ユーザー名を入力してください。")
            return nil
        }
        return userName
    }

    // MARK: - User Input Validation
    private func validateTextFieldInput(_ textField: UITextField, errorMessage: String) -> String? {
        guard let text = textField.text, !text.isEmpty else {
            presentAlert(message: errorMessage)
            return nil
        }
        return text
    }

    // MARK: - Writing to NFC with SNS URL
    private func writeSNSURL(baseURL: String, textField: UITextField, requiresHandle: Bool = false) {
        // Validate the input from the provided text field
        guard let userName = validateTextFieldInput(textField, errorMessage: "ユーザー名を入力してください。") else { return }
        
        let completeURL: String
        if requiresHandle {
            completeURL = baseURL + "@\(userName)"
        } else {
            completeURL = baseURL + userName
        }
        
        logger.info("生成されたURL: \(completeURL)")
        
        if let url = URL(string: completeURL), verifyURL(url) {
            text = completeURL
            startNFCSession()
        } else {
            presentAlert(message: LocalizationManager.message(.invalidURL))
        }
    }

    // SNS Button Actions
    @IBAction func writeInstagram(_ sender: UIButton) {
        writeSNSURL(baseURL: "https://www.instagram.com/", textField: userNameTextField) // ②のテキストボックス
    }

    @IBAction func writeX(_ sender: UIButton) {
        writeSNSURL(baseURL: "https://twitter.com/", textField: userNameTextField) // ②のテキストボックス
    }

    @IBAction func writeYouTube(_ sender: UIButton) {
        writeSNSURL(baseURL: "https://www.youtube.com/", textField: userNameTextField, requiresHandle: true) // ②のテキストボックス
    }

    @IBAction func writeFacebook(_ sender: UIButton) {
        writeSNSURL(baseURL: "https://www.facebook.com/", textField: userNameTextField) // ②のテキストボックス
    }
    
    private func configureTextField() {
        textField.delegate = self
        textField.returnKeyType = .done
        textField.placeholder = LocalizationManager.message(.enterTextOrURL)
        textField.keyboardType = .URL
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
    }
    
    private func configureWriteButton() {
        var config = UIButton.Configuration.filled()
        config.title = LocalizationManager.message(.write)
        config.baseBackgroundColor = .systemBlue
        config.cornerStyle = .medium
        config.buttonSize = .large
        writeBtn.configuration = config
        writeBtn.isEnabled = false
    }
    

    private func setupBannerAd() {
        bannerView.adUnitID = Constants.adUnitID
        bannerView.rootViewController = self
        bannerView.delegate = self
        bannerView.load(GADRequest())
    }
    
    private func setupNativeAd() {
        let multipleAdsOptions = GADMultipleAdsAdLoaderOptions()
        multipleAdsOptions.numberOfAds = 5
        
        adLoader = GADAdLoader(adUnitID: Constants.nativeAdUnitID,
                             rootViewController: self,
                             adTypes: [.native],
                             options: [multipleAdsOptions])
        adLoader.delegate = self
        adLoader.load(GADRequest())
    }
    
    
    private func checkFirstLaunch() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: Constants.UserDefaults.firstLaunchKey) {
            defaults.set(false, forKey: Constants.UserDefaults.firstLaunchKey)
            performSegue(withIdentifier: "nfc", sender: nil)
        }
    }
    
    // MARK: - NFC Methods
    private func startNFCSession() {
        guard validateInput() else { return }
        
        session = NFCNDEFReaderSession(delegate: self,
                                     queue: .main,
                                     invalidateAfterFirstRead: false)
        session?.alertMessage = LocalizationManager.message(.writePrompt)
        session?.begin()
    }
    
    private func validateInput() -> Bool {
        guard let inputText = textField.text, !inputText.isEmpty else {
            presentAlert(message: LocalizationManager.message(.emptyText))
            return false
        }
        
        guard NFCNDEFReaderSession.readingAvailable else {
            logger.error("NFCは利用できません")
            presentAlert(message: LocalizationManager.message(.nfcNotAvailable))
            return false
        }
        
        text = inputText
        state = .write
        return true
    }
    
    private func createPayload(from text: String) -> NFCNDEFPayload? {
        if let url = URL(string: text), verifyURL(url) {
            logger.info("URLとして書き込みます: \(url)")
            return NFCNDEFPayload.wellKnownTypeURIPayload(url: url)
        } else {
            logger.info("テキストとして書き込みます: \(text)")
            return NFCNDEFPayload.wellKnownTypeTextPayload(
                string: text,
                locale: .current
            )
        }
    }
    
    private func verifyURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme?.lowercased(),
              Constants.validSchemes.contains(scheme),
              url.host != nil else {
            return false
        }
        return true
    }
    
    private func writeToTag(_ tag: NFCNDEFTag, capacity: Int) {
        guard let payload = createPayload(from: text) else {
            stopSession(error: LocalizationManager.message(.payloadCreationFailed))
            return
        }
        
        let message = NFCNDEFMessage(records: [payload])
        
        guard message.length <= capacity else {
            stopSession(error: String(format: LocalizationManager.message(.capacityOverflow), "\(capacity)"))
            return
        }
        
        writeMessageToTag(message, tag: tag)
    }
    
    private func writeMessageToTag(_ message: NFCNDEFMessage, tag: NFCNDEFTag) {
        tag.writeNDEF(message) { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                self.handleWriteError(error)
            } else {
                self.handleWriteSuccess()
            }
        }
    }
    
    private func handleWriteError(_ error: Error) {
        logger.error("書き込み失敗: \(error.localizedDescription)")
        stopSession(error: LocalizationManager.message(.writeError))
    }
    
    private func handleWriteSuccess() {
        if let url = URL(string: text), verifyURL(url) {
            logger.info("URL書き込み成功: \(url)")
            stopSession(message: LocalizationManager.urlWriteSuccessMessage(url.absoluteString))
        } else {
            logger.info("テキスト書き込み成功: \(self.text)")
            stopSession(message: LocalizationManager.message(.textWriteSuccess))
        }
    }
    
    private func stopSession(message: String? = nil, error: String? = nil) {
        if let error = error {
            session?.invalidate(errorMessage: error)
            logger.error("セッション終了 (エラー): \(error)")
        } else if let message = message {
            session?.alertMessage = message
            session?.invalidate()
            logger.info("セッション終了: \(message)")
        }
        state = .standBy
    }
    
    private func showURLConfirmation(_ url: URL) {
        let alert = UIAlertController(
            title: LocalizationManager.message(.urlConfirmation),
            message: String(format: LocalizationManager.message(.writeURLConfirmation), url.absoluteString),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: LocalizationManager.message(.writeAsURL), style: .default) { [weak self] _ in
            self?.startNFCSession()
        })
        
        alert.addAction(UIAlertAction(title: LocalizationManager.message(.writeAsText), style: .default) { [weak self] _ in
            self?.text = url.absoluteString
            self?.startNFCSession()
        })
        
        alert.addAction(UIAlertAction(title: LocalizationManager.message(.cancel), style: .cancel))
        present(alert, animated: true)
            }
            
            private func presentAlert(message: String) {
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(
                        title: LocalizationManager.message(.notification),
                        message: message,
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: LocalizationManager.message(.ok), style: .default))
                    self?.present(alert, animated: true)
                }
            }
            
            // MARK: - IBActions
            @IBAction func tapScreen(_ sender: Any) {
                textField.resignFirstResponder()
            }
            
            @IBAction func write(_ sender: Any) {
                guard let text = textField.text, !text.isEmpty else {
                        presentAlert(message: LocalizationManager.message(.emptyText))
                        return
                    }

                    if let url = URL(string: text), verifyURL(url) {
                        showURLConfirmation(url)
                    } else {
                        startNFCSession()
                    }
                }
        }

        // MARK: - NFCNDEFReaderSessionDelegate
        extension ViewController3: NFCNDEFReaderSessionDelegate {
            func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
                // 書き込み時は使用しない
            }
            
            func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
                logger.error("NFCセッションエラー: \(error.localizedDescription)")
            }
            
            func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
                guard tags.count == 1, let tag = tags.first else {
                    session.alertMessage = LocalizationManager.message(.multipleTagsDetected)
                    session.restartPolling()
                    return
                }
                
                session.connect(to: tag) { [weak self] error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.logger.error("タグ接続エラー: \(error.localizedDescription)")
                        session.restartPolling()
                        return
                    }
                    
                    self.handleTagConnection(tag, session: session)
                }
            }
            
            private func handleTagConnection(_ tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
                tag.queryNDEFStatus { [weak self] status, capacity, error in
                    guard let self = self else { return }
                    
                    if let error = error {
                        self.stopSession(error: error.localizedDescription)
                        return
                    }
                    
                    switch status {
                    case .notSupported:
                        self.stopSession(error: LocalizationManager.message(.invalidTag))
                    case .readOnly:
                        self.stopSession(error: LocalizationManager.message(.readOnlyError))
                    case .readWrite:
                        self.writeToTag(tag, capacity: capacity)
                    @unknown default:
                        self.stopSession(error: LocalizationManager.message(.unknownTagStatus))
                    }
                }
            }
        }

        // MARK: - UITextFieldDelegate
        extension ViewController3: UITextFieldDelegate {
            func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
                let updatedText = (textField.text as NSString?)?.replacingCharacters(in: range, with: string) ?? string
                writeBtn.isEnabled = !updatedText.isEmpty
                return true
            }
            
            func textFieldDidEndEditing(_ textField: UITextField) {
                if let text = textField.text,
                   let url = URL(string: text),
                   verifyURL(url) {
                    logger.info("有効なURL: \(url)")
                }
            }
            
            func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                textField.resignFirstResponder()
                return true
            }
        }

        // MARK: - 広告関連のデリゲート
        extension ViewController3: GADAdLoaderDelegate {
            func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: Error) {
                logger.error("広告読み込み失敗: \(error.localizedDescription)")
            }
        }

        extension ViewController3: GADNativeAdLoaderDelegate {
            func adLoader(_ adLoader: GADAdLoader, didReceive nativeAd: GADNativeAd) {
                logger.info("ネイティブ広告読み込み成功")
            }
            
            func adLoaderDidFinishLoading(_ adLoader: GADAdLoader) {
                logger.info("広告読み込み完了")
            }
        }

        extension ViewController3: GADBannerViewDelegate {
            func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
                logger.info("バナー広告読み込み成功")
            }
            
            func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
                logger.error("バナー広告読み込み失敗: \(error.localizedDescription)")
            }
            
            func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
                logger.info("バナー広告のインプレッション記録")
            }
            
            func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
                logger.info("バナー広告画面表示開始")
            }
            
            func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
                logger.info("バナー広告画面終了開始")
            }
            
            func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
                logger.info("バナー広告画面終了完了")
            }
        }
