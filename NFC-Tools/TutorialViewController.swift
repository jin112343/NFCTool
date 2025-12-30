import UIKit
import EAIntroView
import OSLog

class TutorialViewController: UIViewController, EAIntroDelegate {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "Tutorial")

    override func viewDidLoad() {
        super.viewDidLoad()

        checkFirstLaunch()
        let currentLanguage: String
        if #available(iOS 16, *) {
            currentLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        } else {
            currentLanguage = Locale.current.languageCode ?? "en"
        }
        let width = view.bounds.size.width
        
        // チュートリアルページを作成
        let pages = createIntroPages(forLanguage: currentLanguage, width: width)
        
        // チュートリアルビューを設定
        showIntroView(with: pages, language: currentLanguage)
    }
    
    /// アプリの初回起動を確認してフラグを設定
    private func checkFirstLaunch() {
        let userDefaults = UserDefaults.standard
        if !userDefaults.bool(forKey: "launchedBefore") {
            userDefaults.set(true, forKey: "launchedBefore")
            logger.info("初回起動: 初期設定を実行します。")
        }
    }
    
    /// チュートリアルページを作成
    private func createIntroPages(forLanguage language: String, width: CGFloat) -> [EAIntroPage] {
        // 言語別メッセージ
        let messages: [String]
        switch language {
        case "ja":// 日本語
            messages = [
                "このアプリは\nNFCタグなどに使われます。",
                "SNSのアカウントにも\n書き込める",
                "NFCで名刺交換して\nあなたのポートフォリオや\n会社のURLも書き込める",
                "さぁ、はじめよう！"
            ]
        case "ar": // アラビア語
            messages = [
                "هذا التطبيق يستخدم\nعلامات NFC وما إلى ذلك.",
                "حساب SNS أيضًا\nيمكن الكتابة",
                "تبادل بطاقات العمل مع NFC\nلمشاركة محفظتك و\nيمكنك أيضًا كتابة عنوان URL\nلشركتك.",
                "دعونا نبدأ!"
            ]
        case "it": // イタリア語
            messages = [
                "Questa app viene utilizzata\nper tag NFC ecc.",
                "Puoi anche scrivere\ni conteggi SNS.",
                "Puoi scambiare biglietti\nda visita utilizzando NFC e\nscrivere l'URL del tuo\nportafoglio o della tua\nazienda.",
                "Iniziamo!"
            ]
        case "id": // インドネシア語
            messages = [
                "Aplikasi ini digunakan\nuntuk tag NFC dll.",
                "Anda juga dapat menulis\njumlah SNS.",
                "Anda dapat bertukar kartu\nnama menggunakan NFC\ndan menulis URL portofolio\natau perusahaan Anda.",
                "Mari kita mulai!"
            ]
        case "uk": // ウクライナ語
            messages = [
                "Ця програма\nвикористовується\nдля тегів NFC тощо.",
                "Ви також можете\nнаписати кількість SNS.",
                "Ви можете обмінюватися\nвізитними картками за\nдопомогою NFC і писати\nURL-адресу свого\nпортфоліо або компанії.",
                "Давайте почнемо!"
            ]
        case "nl": // オランダ語
            messages = [
                "Deze app wordt gebruikt\nvoor NFC-tags etc.",
                "U kunt ook SNS-aantallen\nschrijven.",
                "Via NFC kunt u\nvisitekaartjes uitwisselen\nen de URL van uw portfolio\nof bedrijf schrijven.",
                "Laten we beginnen!"
            ]
        case "ca": // カタルーニャ語
            messages = [
                "Aquesta aplicació s'utilitza\nper a etiquetes NFC, etc.",
                "També podeu escriure\nrecomptes de SNS.",
                "Podeu intercanviar targetes\nde visita mitjançant NFC i\nescriure l'URL de la vostra\ncartera o empresa.",
                "Comencem!"
            ]
        case "el": // ギリシャ語
            messages = [
                "Αυτή η εφαρμογή\nχρησιμοποιείται για\nετικέτες NFC κ.λπ.",
                "Μπορείτε επίσης να\nγράψετε μετρήσεις SNS.",
                "Μπορείτε να ανταλλάξετε\nεπαγγελματικές κάρτες\nχρησιμοποιώντας NFC και να\nγράψετε τη διεύθυνση URL του\nχαρτοφυλακίου ή της εταιρείας σας.",
                "Ας ξεκινήσουμε!"
            ]
        case "hr": // クロアチア語
            messages = [
                "Ova aplikacija se koristi za\nNFC oznake itd.",
                "Također možete napisati\nbroj SNS-a.",
                "Možete razmjenjivati\n​posjetnice pomoću NFC-a i\nnapisati URL svog portfelja\nili tvrtke.",
                "Započnimo!"
            ]
        case "sv": // スウェーデン語
            messages = [
                "Denna app används för\nNFC-taggar etc.",
                "Du kan också skriva\nSNS-antal.",
                "Du kan byta visitkort med\nNFC och skriva\nwebbadressen till din\nportfölj eller ditt företag.",
                "Låt oss komma igång!"
            ]
        case "es": // スペイン語（スペイン）
            messages = [
                "Esta aplicación se utiliza\npara etiquetas NFC, etc.",
                "También puedes escribir\nrecuentos de SNS.",
                "Podrás intercambiar\ntarjetas de visita mediante\nNFC y escribir la URL de tu\ncartera o empresa.",
                "¡Empecemos!"
            ]
        case "es-MX": // スペイン語（メキシコ）
            messages = [
                "Esta aplicación se utiliza\npara etiquetas NFC, etc.",
                "También puedes escribir\nrecuentos de SNS.",
                "Podrás intercambiar\ntarjetas de visita mediante\nNFC y escribir la URL de tu cartera o empresa.",
                "¡Empecemos!"
            ]
        case "sk": // スロバキア語
            messages = [
                "Táto aplikácia sa používa\npre značky NFC atď.",
                "Môžete napísať\naj počty SNS.",
                "Môžete si vymeniť vizitky\npomocou NFC a napísať\nURL svojho portfólia alebo\nspoločnosti.",
                "Začnime!"
            ]
        case "th": // タイ語
            messages = [
                "แอพนี้ใช้สำหรับแท็ก NFC ฯลฯ",
                "คุณยังสามารถเขียนจำนวน\nSNS ได้อีกด้วย",
                "คุณสามารถแลกเปลี่ยนนามบัตรโ\nดยใช้ NFC และเขียน URL\nของพอร์ตโฟลิโอหรือบริษัทของ\nคุณ",
                "มาเริ่มกันเลย!"
            ]
        case "cs": // チェコ語
            messages = [
                "Tato aplikace se používá\npro značky NFC atd.",
                "Můžete také napsat\npočty SNS.",
                "Můžete si vyměnit vizitky\npomocí NFC a napsat URL\nsvého portfolia neb\nspolečnosti.",
                "Začněme!"
            ]
        case "da": // デンマーク語
            messages = [
                "Denne app bruges\ntil NFC-tags osv.",
                "Du kan også skrive\nSNS-tal.",
                "Du kan udveksle visitkort\nved hjælp af NFC og skrive\nURL'en til din portefølje eller\nvirksomhed.",
                "Lad os komme i gang!"
            ]
        case "de": // ドイツ語
            messages = [
                "Diese App wird für\nNFC-Tags usw.\nverwendet.",
                "Sie können auch\nSNS-Zählungen\nschreiben.",
                "Sie können Visitenkarten\nper NFC austauschen und\ndie URL Ihres Portfolios\noder Unternehmens\nschreiben.",
                "Fangen wir an!"
            ]
        case "tr": // トルコ語
            messages = [
                "Bu uygulama NFC etiketleri\nvb. için kullanılır.",
                "Ayrıca SNS sayımlarını\nda yazabilirsiniz.",
                "NFC'yi kullanarak kartvizit\nalışverişi yapabilir ve\nportföyünüzün veya\nşirketinizin URL'sini\nyazabilirsiniz.",
                "Hadi başlayalım!"
            ]
        case "no": // ノルウェー語
            messages = [
                "Denne appen brukes til\nNFC-tagger etc.",
                "Du kan også skrive\nSNS-tellinger.",
                "Du kan bytte visittkort ved\nå bruke NFC og skrive URL-en\ntil porteføljen eller firmaet\nditt.",
                "La oss komme i gang!"
            ]
        case "hu": // ハンガリー語
            messages = [
                "Ez az alkalmazás\nNFC-címkékhez stb.",
                "SNS-számokat is írhat.",
                "Névjegykártyákat cserélhet\nNFC használatával,és\nbeírhatja portfóliója\nvagy cége URL-jét.",
                "Kezdjük is!"
            ]
        case "hi": // ヒンディー語
            messages = [
                "इस ऐप का इस्तेमाल एनएफसी टैग\nआदि के लिए किया जाता है।",
                "आप एसएनएस गिनती\nभी लिख सकते हैं।",
                "आप एनएफसी का उपयोग\nकरके बिजनेस कार्ड का आदान-प्रदान\nकर सकते हैं और अपने पोर्टफोलियो\nया कंपनी का यूआरएल लिख सकते हैं।",
                "आएँ शुरू करें!"
            ]
        case "fi": // フィンランド語
            messages = [
                "Tätä sovellusta käytetään\nNFC-tunnisteisiin jne.",
                "Voit myös kirjoittaa\nSNS-määrät.",
                "Voit vaihtaa käyntikortteja\nNFC:n avulla ja kirjoittaa\nportfoliosi\ntai yrityksesi URL-osoitteen.",
                "Aloitetaan!"
            ]
        case "fr": // フランス語
            messages = [
                "Cette application est\nutilisée pour les balises\nNFC, etc.",
                "Vous pouvez également\nécrire des comptes SNS.",
                "Vous pouvez échanger des\ncartes de visite via NFC et\nécrire l'URL de votre\nportefeuille ou de votre\nentreprise.",
                "Commençons"
            ]
        case "fr-CA": // フランス語（カナダ）
            messages = [
                "Cette application est\nutilisée pour les balises\nNFC, etc.",
                "Vous pouvez aussi\nécrire des comptes SNS.",
                "Vous pouvez échanger des\ncartes professionnelles via\nNFC et écrire l'URL de votre\nportefeuille ou de votre\nentreprise.",
                "Commençons !"
            ]
        case "vi": // ベトナム語
            messages = [
                "Ứng dụng này được\nsử dụng cho thẻ NFC, v.v.",
                "Bạn cũng có thể viết\nsố lượng SNS.",
                "Bạn có thể trao đổi danh\nthiếp bằng NFC và viết URL\ncủa danh mục đầu tư hoặc\ncông ty của bạn.",
                "Hãy bắt đầu!"
            ]
        case "he": // ヘブライ語
            messages = [
                "אפליקציה זו משמשת לתגי\nNFC וכו'.",
                "אתה יכול גם לכתוב ספירות\nSNS.",
                "אתה יכול להחליף כרטיסי\nביקור באמצעות NFC ולכתוב\nאת כתובת האתר של תיק\nהעבודות או החברה שלך.",
                "בואו נתחיל!"
            ]
        case "pl": // ポーランド語
            messages = [
                "Ta aplikacja służy\ndo tagów NFC itp.",
                "Możesz także\nzapisać liczniki SNS.",
                "Możesz wymieniać\nwizytówki za pomocą NFC\ni wpisać adres URL swojego\nportfolio lub firmy.",
                "Zacznijmy!"
            ]
        case "pt-BR": // ポルトガル語（ブラジル）
            messages = [
                "Este aplicativo é usado\npara tags NFC, etc.",
                "Você também pode\nescrever contagens SNS.",
                "Você pode trocar cartões\nde visita usando NFC e\nescrever a URL do seu\nportfólio ou empresa.",
                "Vamos começar!"
            ]
        case "pt-PT": // ポルトガル語（ポルトガル）
            messages = [
                "Esta aplicação é usada\npara tags NFC, etc.",
                "Também pode escrever\ncontagens SNS.",
                "Pode trocar cartões de\nvisita utilizando o NFC e\nescrever o URL do seu\nportfólio ou empresa.",
                "Vamos começar!"
            ]
        case "ms": // マレー語
            messages = [
                "Aplikasi ini digunakan\nuntuk tag NFC dsb.",
                "Anda juga boleh menulis\nkiraan SNS.",
                "Anda boleh menukar kad\nperniagaan menggunakan\nNFC dan menulis URL\nportfolio atau syarikat anda.",
                "Mari mulakan!"
            ]
        case "ro": // ルーマニア語
            messages = [
                "Această aplicație este\nfolosită pentru etichete NFC etc.",
                "Puteți scrie, de asemenea,\nnumărări SNS.",
                "Puteți schimba cărți de\nvizită folosind NFC și puteți\nscrie adresa URL\na portofoliului\nsaucompaniei dvs.",
                "Să începem!"
            ]
        case "ru": // ロシア語
            messages = [
                "Это приложение\nиспользуется для тегов\nNFC и т. д.",
                "Вы также можете\nзаписать количество\nсоциальных сетей.",
                "Вы можете обмениваться\nвизитками с помощью NFC\nи писать URL-адрес своего\nпортфолио или компании.",
                "Давайте начнем!"
            ]
        case "en": // 英語（アメリカ）
            messages = [
                "This app is used for NFC\ntags and more.",
                "You can write social media\naccounts as well.",
                "Exchange business cards\nvia NFC and write your\nportfolio or company URL.",
                "Let’s get started!"
            ]
        case "en-GB": // 英語（イギリス）
            messages = [
                "This app is used for NFC\ntags and more.",
                "You can also write social\nmedia accounts.",
                "Exchange business cards\nvia NFC and write your\nportfolio or company URL.",
                "Let’s get started!"
            ]
        case "en-AU": // 英語（オーストラリア）
            messages = [
                "This app is used for NFC\ntags and other purposes.",
                "You can also write your\nsocial media accounts.",
                "Exchange business cards\nvia NFC and write your\nportfolio or company URL.",
                "Let’s get started!"
            ]
        case "en-CA": // 英語（カナダ）
            messages = [
                "This app is used for NFC\ntags and more.",
                "You can also write social\nmedia accounts.",
                "Exchange business cards\nvia NFC and write your\nportfolio or company URL.",
                "Let’s get started!"
            ]
        case "ko": // 韓国語
            messages = [
                "이 앱은 NFC 태그\n등에 사용됩니다.",
                "SNS 카운트도 쓸 수 있다",
                "NFC로 명함을 교환하여 포트폴리오\n및 회사 URL을 작성할\n수 있습니다.",
                "자, 시작하자!"
            ]
        case "zh-Hans": // 中国語（簡体字）
            messages = [
                "该应用程序用于 NFC 标签等。",
                "您还可以编写 SNS 计数。",
                "您可以使用 NFC 交换名片并写\n入您的投资组合或公司的\nURL。",
                "让我们开始吧！"
            ]
        case "zh-Hant": // 中国語（繁体字）
            messages = [
                "該應用程式用於 NFC 標籤等。",
                "您也可以編寫 SNS 計數。",
                "您可以使用 NFC 交換名片並寫\n入您的作品集或公司的 URL。",
                "讓我們開始吧！"
            ]
        default: // English
            messages = [
                "This app\nis used for NFC tags.",
                "You can write\nSNS accounts too.",
                "Exchange business cards\nvia NFC and add\nyour portfolio or company URL.",
                "Let's get started!"
            ]
        }
        
        let templateImages = ["1.png", "2.png", "3.png", "4.png"]
        let screenSize = UIScreen.main.bounds.size

        return zip(templateImages, messages).enumerated().compactMap { (index, element) in
            let (imageName, message) = element
            guard let templateImage = UIImage(named: imageName) else {
                logger.error("エラー: \(imageName)が見つかりません。")
                return nil
            }

            // ページごとのY軸オフセット（画面サイズに合わせて調整）
            let additionalYOffset: CGFloat
            switch index {
            case 2: // 3枚目は上寄せ
                additionalYOffset = -20
            case 3: // 4枚目は中央寄せ
                additionalYOffset = 40
            default: // その他はデフォルト値
                additionalYOffset = 10
            }

            let page = EAIntroPage()
            page.bgImage = addTextToImage(
                image: templateImage,
                text: message,
                textColor: .black,
                font: UIFont.systemFont(ofSize: 80),
                yOffset: additionalYOffset,
                screenSize: screenSize
            )
            return page
        }
    }
    
    /// 画像を画面サイズに合わせてリサイズ（アスペクト比を維持）
    private func resizeImageToFitScreen(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let widthRatio = targetSize.width / image.size.width
        let heightRatio = targetSize.height / image.size.height
        let ratio = min(widthRatio, heightRatio)

        let newSize = CGSize(
            width: image.size.width * ratio,
            height: image.size.height * ratio
        )

        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { context in
            // 背景を白で塗りつぶし
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: targetSize))

            // 画像を中央に配置
            let x = (targetSize.width - newSize.width) / 2
            let y = (targetSize.height - newSize.height) / 2
            image.draw(in: CGRect(x: x, y: y, width: newSize.width, height: newSize.height))
        }

        return resizedImage
    }

    /// 画像にテキストを描画
    private func addTextToImage(image: UIImage, text: String, textColor: UIColor, font: UIFont, yOffset: CGFloat, screenSize: CGSize) -> UIImage {
        // 画像を画面サイズに合わせてリサイズ
        let resizedImage = resizeImageToFitScreen(image, targetSize: screenSize)

        let whiteAreaHeight = resizedImage.size.height * 0.3
        let whiteAreaY = resizedImage.size.height - whiteAreaHeight

        // 中央揃えの段落スタイルを設定
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // 画面サイズに応じてフォントサイズを調整
        let adjustedFontSize = min(font.pointSize, screenSize.width / 10)
        let adjustedFont = font.withSize(adjustedFontSize)

        let textAttributes: [NSAttributedString.Key: Any] = [
            .font: adjustedFont,
            .foregroundColor: textColor,
            .paragraphStyle: paragraphStyle
        ]

        let textWidth = resizedImage.size.width * 0.9
        let textHeight = whiteAreaHeight * 0.8
        let textRect = CGRect(
            x: resizedImage.size.width * 0.05,
            y: whiteAreaY + (whiteAreaHeight - textHeight) / 2 + yOffset,
            width: textWidth,
            height: textHeight
        )

        let renderer = UIGraphicsImageRenderer(size: resizedImage.size)
        let newImage = renderer.image { _ in
            resizedImage.draw(in: CGRect(origin: .zero, size: resizedImage.size))
            text.draw(in: textRect, withAttributes: textAttributes)
        }

        return newImage
    }
    
    /// チュートリアルビューを表示
    private func showIntroView(with pages: [EAIntroPage], language: String) {
        guard let introView = EAIntroView(frame: self.view.bounds, andPages: pages) else { return }
        
        // スキップボタンのテキストを言語に応じて設定
        // スキップボタンのテキストを言語に応じて設定
        let skipText: String
        switch language {
        case "ja": // 日本語
            skipText = "スキップ"
        case "ar": // アラビア語
            skipText = "تخطي"
        case "it": // イタリア語
            skipText = "Salta"
        case "id": // インドネシア語
            skipText = "Lewati"
        case "uk": // ウクライナ語
            skipText = "Пропустити"
        case "nl": // オランダ語
            skipText = "Overslaan"
        case "ca": // カタルーニャ語
            skipText = "Saltar"
        case "el": // ギリシャ語
            skipText = "Παράβλεψη"
        case "hr": // クロアチア語
            skipText = "Preskoči"
        case "sv": // スウェーデン語
            skipText = "Hoppa över"
        case "es", "es-MX": // スペイン語
            skipText = "Omitir"
        case "sk": // スロバキア語
            skipText = "Preskočiť"
        case "th": // タイ語
            skipText = "ข้าม"
        case "cs": // チェコ語
            skipText = "Přeskočit"
        case "da": // デンマーク語
            skipText = "Spring over"
        case "de": // ドイツ語
            skipText = "Überspringen"
        case "tr": // トルコ語
            skipText = "Geç"
        case "no": // ノルウェー語
            skipText = "Hopp over"
        case "hu": // ハンガリー語
            skipText = "Kihagyás"
        case "hi": // ヒンディー語
            skipText = "छोड़ें"
        case "fi": // フィンランド語
            skipText = "Ohita"
        case "fr", "fr-CA": // フランス語
            skipText = "Passer"
        case "vi": // ベトナム語
            skipText = "Bỏ qua"
        case "he": // ヘブライ語
            skipText = "דלג"
        case "pl": // ポーランド語
            skipText = "Pomiń"
        case "pt-BR", "pt-PT": // ポルトガル語
            skipText = "Pular"
        case "ms": // マレー語
            skipText = "Langkau"
        case "ro": // ルーマニア語
            skipText = "Omite"
        case "ru": // ロシア語
            skipText = "Пропустить"
        case "en", "en-GB", "en-AU", "en-CA": // 英語
            skipText = "Skip"
        case "ko": // 韓国語
            skipText = "건너뛰기"
        case "zh-Hans": // 中国語（簡体字）
            skipText = "跳过"
        case "zh-Hant": // 中国語（繁体字）
            skipText = "跳過"
        default: // その他
            skipText = "Skip"
        }
        
        introView.skipButton.setTitle(skipText, for: .normal)
        introView.skipButton.setTitleColor(.systemBlue, for: .normal)
        
        // アラビア語の場合、RTLサポートを設定
        if language == "ar" {
            introView.semanticContentAttribute = .forceRightToLeft
            introView.skipButton.semanticContentAttribute = .forceRightToLeft
        }
        
        introView.delegate = self
        introView.show(in: self.view, animateDuration: 1.0)
        
        UserDefaults.standard.set(1, forKey: "Tutorial")
    }
    
    /// チュートリアル完了時の処理
    func introDidFinish(_ introView: EAIntroView!, wasSkipped: Bool) {
        logger.info("チュートリアル完了。スキップ: \(wasSkipped)")
        
        if let mainVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController {
            let nav = UINavigationController(rootViewController: mainVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
}
