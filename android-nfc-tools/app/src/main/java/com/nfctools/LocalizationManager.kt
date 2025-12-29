package com.nfctools

import java.util.*

object LocalizationManager {

    private val localizedMessages = mapOf(
        "ja" to mapOf(
            "nfc_not_supported" to "このNFCは使えません",
            "nfc_bring_closer" to "NFCタグをスマートフォン背面に近づけてください",
            "nfc_tag_not_supported" to "このNFCタグは対応していません",
            "nfc_remove_alert" to "下記の情報を削除します\nNFCタグを動かないでください \n\n %s",
            "nfc_read_only" to "このNFCタグには書き込みできません",
            "nfc_payload_fail" to "ペイロードの作成に失敗しました",
            "nfc_over_capacity" to "容量オーバーで書き込めません！\n容量は%sbyteです",
            "nfc_deleted" to "削除しました",
            "writePrompt" to "NFCタグをスマートフォン背面に近づけてください",
            "writeSuccess" to "書き込みが完了しました",
            "urlWriteSuccess" to "URLを書き込みました",
            "textWriteSuccess" to "テキストを書き込みました",
            "emptyText" to "テキストを入力してください",
            "writeError" to "書き込みに失敗しました",
            "readOnlyError" to "このタグは読み取り専用です",
            "enterTextOrURL" to "テキストまたはURLを入力",
            "write" to "書き込む",
            "cancel" to "キャンセル",
            "urlConfirmation" to "URLの確認",
            "writeAsURL" to "URLとして書き込む",
            "writeAsText" to "テキストとして書き込む",
            "writeURLConfirmation" to "以下のURLを書き込みますか？\n%s",
            "capacityOverflow" to "容量オーバーで書き込めません！\n容量は%sbyteです"
        ),
        "ar" to mapOf(
            "nfc_not_supported" to "لا يمكن استخدام NFC هذا",
            "nfc_bring_closer" to "قرب علامة NFC إلى الجزء الخلفي من الهاتف الذكي",
            "nfc_tag_not_supported" to "علامة NFC هذه غير مدعومة",
            "nfc_remove_alert" to "سيتم حذف المعلومات التالية\nيرجى عدم تحريك علامة NFC \n\n %s",
            "nfc_read_only" to "علامة NFC هذه للقراءة فقط",
            "nfc_payload_fail" to "فشل إنشاء الحمولة",
            "nfc_over_capacity" to "لا يمكن الكتابة بسبب تجاوز السعة!\nالسعة هي %s بايت",
            "nfc_deleted" to "تم الحذف بنجاح"
        ),
        "it" to mapOf(
            "nfc_not_supported" to "Questo NFC non può essere utilizzato",
            "nfc_bring_closer" to "Avvicina il tag NFC al retro dello smartphone",
            "nfc_tag_not_supported" to "Questo tag NFC non è supportato",
            "nfc_remove_alert" to "Le seguenti informazioni saranno eliminate\nNon spostare il tag NFC \n\n %s",
            "nfc_read_only" to "Questo tag NFC è solo in lettura",
            "nfc_payload_fail" to "Creazione del payload non riuscita",
            "nfc_over_capacity" to "Impossibile scrivere a causa del superamento della capacità!\nLa capacità è di %s byte",
            "nfc_deleted" to "Eliminato con successo"
        ),
        "en" to mapOf(
            "nfc_not_supported" to "This NFC cannot be used",
            "nfc_bring_closer" to "Bring the NFC tag closer to the back of your smartphone",
            "nfc_tag_not_supported" to "This NFC tag is not supported",
            "nfc_remove_alert" to "The following information will be deleted\nDo not move the NFC tag \n\n %s",
            "nfc_read_only" to "This NFC tag is read-only",
            "nfc_payload_fail" to "Failed to create payload",
            "nfc_over_capacity" to "Cannot write due to capacity exceeded!\nCapacity is %s bytes",
            "nfc_deleted" to "Successfully deleted",
            "writePrompt" to "Please hold your device near the NFC tag",
            "writeSuccess" to "Writing completed",
            "urlWriteSuccess" to "URL has been written",
            "textWriteSuccess" to "Text has been written",
            "emptyText" to "Please enter text",
            "writeError" to "Writing failed",
            "readOnlyError" to "This tag is read-only",
            "enterTextOrURL" to "Enter text or URL",
            "write" to "Write",
            "cancel" to "Cancel",
            "urlConfirmation" to "URL Confirmation",
            "writeAsURL" to "Write as URL",
            "writeAsText" to "Write as Text",
            "writeURLConfirmation" to "Do you want to write the following URL?\n%s",
            "capacityOverflow" to "Cannot write. Capacity is %s bytes"
        ),
        "ko" to mapOf(
            "nfc_not_supported" to "이 NFC는 사용할 수 없습니다",
            "nfc_bring_closer" to "NFC 태그를 스마트폰 뒷면으로 가까이 가져오세요",
            "nfc_tag_not_supported" to "이 NFC 태그는 지원되지 않습니다",
            "nfc_remove_alert" to "다음 정보가 삭제됩니다\nNFC 태그를 움직이지 마세요 \n\n %s",
            "nfc_read_only" to "이 NFC 태그는 읽기 전용입니다",
            "nfc_payload_fail" to "페이로드 생성에 실패했습니다",
            "nfc_over_capacity" to "용량 초과로 인해 쓸 수 없습니다!\n용량은 %s 바이트입니다",
            "nfc_deleted" to "성공적으로 삭제되었습니다"
        ),
        "zh" to mapOf(
            "nfc_not_supported" to "此NFC无法使用",
            "nfc_bring_closer" to "将NFC标签靠近智能手机背面",
            "nfc_tag_not_supported" to "此NFC标签不支持",
            "nfc_remove_alert" to "以下信息将被删除\n请勿移动NFC标签 \n\n %s",
            "nfc_read_only" to "此NFC标签为只读",
            "nfc_payload_fail" to "创建有效负载失败",
            "nfc_over_capacity" to "由于容量超限，无法写入！\n容量为%s字节",
            "nfc_deleted" to "删除成功"
        ),
        "zh-Hant" to mapOf(
            "nfc_not_supported" to "此NFC無法使用",
            "nfc_bring_closer" to "將NFC標籤靠近智慧手機背面",
            "nfc_tag_not_supported" to "此NFC標籤不支援",
            "nfc_remove_alert" to "以下資訊將被刪除\n請勿移動NFC標籤 \n\n %s",
            "nfc_read_only" to "此NFC標籤為唯讀",
            "nfc_payload_fail" to "建立有效負載失敗",
            "nfc_over_capacity" to "由於容量超限，無法寫入！\n容量為%s字節",
            "nfc_deleted" to "刪除成功"
        ),
        "fr" to mapOf(
            "nfc_not_supported" to "Ce NFC ne peut pas être utilisé",
            "nfc_bring_closer" to "Approchez l'étiquette NFC du dos du smartphone",
            "nfc_tag_not_supported" to "Cette étiquette NFC n'est pas prise en charge",
            "nfc_remove_alert" to "Les informations suivantes seront supprimées\nNe déplacez pas l'étiquette NFC \n\n %s",
            "nfc_read_only" to "Cette étiquette NFC est en lecture seule",
            "nfc_payload_fail" to "Échec de la création de la charge utile",
            "nfc_over_capacity" to "Impossible d'écrire en raison de la surcharge de capacité !\nLa capacité est de %s octets",
            "nfc_deleted" to "Supprimé avec succès"
        ),
        "de" to mapOf(
            "nfc_not_supported" to "Dieses NFC kann nicht verwendet werden",
            "nfc_bring_closer" to "Halten Sie das NFC-Tag näher an die Rückseite des Smartphones",
            "nfc_tag_not_supported" to "Dieses NFC-Tag wird nicht unterstützt",
            "nfc_remove_alert" to "Die folgenden Informationen werden gelöscht\nBewegen Sie das NFC-Tag nicht \n\n %s",
            "nfc_read_only" to "Dieses NFC-Tag ist schreibgeschützt",
            "nfc_payload_fail" to "Erstellung der Nutzlast fehlgeschlagen",
            "nfc_over_capacity" to "Schreiben aufgrund von Überkapazität nicht möglich!\nKapazität beträgt %s Bytes",
            "nfc_deleted" to "Erfolgreich gelöscht"
        ),
        "es" to mapOf(
            "nfc_not_supported" to "Este NFC no se puede usar",
            "nfc_bring_closer" to "Acerca la etiqueta NFC a la parte trasera del smartphone",
            "nfc_tag_not_supported" to "Esta etiqueta NFC no es compatible",
            "nfc_remove_alert" to "La siguiente información será eliminada\nNo muevas la etiqueta NFC \n\n %s",
            "nfc_read_only" to "Esta etiqueta NFC es de solo lectura",
            "nfc_payload_fail" to "Error al crear la carga útil",
            "nfc_over_capacity" to "No se puede escribir debido a la sobrecarga de capacidad!\nLa capacidad es %s bytes",
            "nfc_deleted" to "Eliminado con éxito"
        ),
        "pt-BR" to mapOf(
            "nfc_not_supported" to "Este NFC não pode ser usado",
            "nfc_bring_closer" to "Aproxime a etiqueta NFC da parte traseira do smartphone",
            "nfc_tag_not_supported" to "Esta etiqueta NFC não é suportada",
            "nfc_remove_alert" to "As seguintes informações serão excluídas\nNão mova a etiqueta NFC \n\n %s",
            "nfc_read_only" to "Esta etiqueta NFC é apenas leitura",
            "nfc_payload_fail" to "Falha ao criar carga útil",
            "nfc_over_capacity" to "Não é possível gravar devido à sobrecarga de capacidade!\nA capacidade é de %s bytes",
            "nfc_deleted" to "Excluído com sucesso"
        ),
        "ru" to mapOf(
            "nfc_not_supported" to "Этот NFC не может быть использован",
            "nfc_bring_closer" to "Поднесите метку NFC к задней части смартфона",
            "nfc_tag_not_supported" to "Эта метка NFC не поддерживается",
            "nfc_remove_alert" to "Следующая информация будет удалена\nНе двигайте метку NFC \n\n %s",
            "nfc_read_only" to "Эта метка NFC доступна только для чтения",
            "nfc_payload_fail" to "Не удалось создать полезную нагрузку",
            "nfc_over_capacity" to "Невозможно записать из-за превышения емкости!\nЕмкость %s байт",
            "nfc_deleted" to "Успешно удалено"
        )
    )

    fun getLocalizedMessage(key: String): String {
        val currentLanguage = Locale.getDefault().language
        println("Current Language Code: $currentLanguage")

        return localizedMessages[currentLanguage]?.get(key)
            ?: localizedMessages["en"]?.get(key)
            ?: "Message not available"
    }
}