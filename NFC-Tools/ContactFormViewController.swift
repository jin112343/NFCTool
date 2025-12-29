//
//  ContactFormViewController.swift
//  NFC-Tools
//
//  Copyright © 2024 Jin Mizoi. All rights reserved.
//

import UIKit
import FirebaseFirestore
import OSLog

final class ContactFormViewController: UIViewController {

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.nfctools", category: "Contact")

    // MARK: - Localization

    private struct LocalizedStrings {
        let navTitle: String
        let title: String
        let description: String
        let categoryLabel: String
        let categories: [String]
        let messageLabel: String
        let sendButton: String
        let errorTitle: String
        let errorEmptyMessage: String
        let errorSendFailed: String
        let successTitle: String
        let successMessage: String

        static func forCurrentLanguage() -> LocalizedStrings {
            let languageCode: String
            if #available(iOS 16, *) {
                languageCode = Locale.current.language.languageCode?.identifier ?? "en"
            } else {
                languageCode = Locale.current.languageCode ?? "en"
            }

            switch languageCode {
            case "ja":
                return LocalizedStrings(
                    navTitle: "お問い合わせ",
                    title: "匿名でお問い合わせ",
                    description: "メールアドレスなしで匿名でフィードバックを送信できます",
                    categoryLabel: "カテゴリ",
                    categories: ["バグ報告", "機能要望", "その他"],
                    messageLabel: "メッセージ",
                    sendButton: "送信",
                    errorTitle: "エラー",
                    errorEmptyMessage: "メッセージを入力してください",
                    errorSendFailed: "送信に失敗しました。後でもう一度お試しください。",
                    successTitle: "送信完了",
                    successMessage: "フィードバックをお送りいただきありがとうございます！"
                )
            case "ko":
                return LocalizedStrings(
                    navTitle: "문의하기",
                    title: "익명 문의",
                    description: "이메일 주소 없이 익명으로 피드백을 보낼 수 있습니다",
                    categoryLabel: "카테고리",
                    categories: ["버그 신고", "기능 요청", "기타"],
                    messageLabel: "메시지",
                    sendButton: "보내기",
                    errorTitle: "오류",
                    errorEmptyMessage: "메시지를 입력해주세요",
                    errorSendFailed: "전송에 실패했습니다. 나중에 다시 시도해주세요.",
                    successTitle: "전송 완료",
                    successMessage: "피드백을 보내주셔서 감사합니다!"
                )
            case "zh":
                return LocalizedStrings(
                    navTitle: "联系我们",
                    title: "匿名反馈",
                    description: "无需电子邮件地址即可匿名发送反馈",
                    categoryLabel: "类别",
                    categories: ["错误报告", "功能请求", "其他"],
                    messageLabel: "消息",
                    sendButton: "发送",
                    errorTitle: "错误",
                    errorEmptyMessage: "请输入消息",
                    errorSendFailed: "发送失败，请稍后重试。",
                    successTitle: "发送成功",
                    successMessage: "感谢您的反馈！"
                )
            case "de":
                return LocalizedStrings(
                    navTitle: "Kontakt",
                    title: "Anonymes Feedback",
                    description: "Senden Sie Feedback anonym ohne E-Mail-Adresse",
                    categoryLabel: "Kategorie",
                    categories: ["Fehlerbericht", "Funktionswunsch", "Sonstiges"],
                    messageLabel: "Nachricht",
                    sendButton: "Senden",
                    errorTitle: "Fehler",
                    errorEmptyMessage: "Bitte geben Sie eine Nachricht ein",
                    errorSendFailed: "Senden fehlgeschlagen. Bitte versuchen Sie es später erneut.",
                    successTitle: "Gesendet",
                    successMessage: "Vielen Dank für Ihr Feedback!"
                )
            case "fr":
                return LocalizedStrings(
                    navTitle: "Contact",
                    title: "Commentaire anonyme",
                    description: "Envoyez vos commentaires de manière anonyme sans adresse e-mail",
                    categoryLabel: "Catégorie",
                    categories: ["Rapport de bug", "Demande de fonctionnalité", "Autre"],
                    messageLabel: "Message",
                    sendButton: "Envoyer",
                    errorTitle: "Erreur",
                    errorEmptyMessage: "Veuillez saisir un message",
                    errorSendFailed: "Échec de l'envoi. Veuillez réessayer plus tard.",
                    successTitle: "Envoyé",
                    successMessage: "Merci pour vos commentaires!"
                )
            case "es":
                return LocalizedStrings(
                    navTitle: "Contacto",
                    title: "Comentario anónimo",
                    description: "Envía comentarios de forma anónima sin dirección de correo",
                    categoryLabel: "Categoría",
                    categories: ["Reporte de error", "Solicitud de función", "Otro"],
                    messageLabel: "Mensaje",
                    sendButton: "Enviar",
                    errorTitle: "Error",
                    errorEmptyMessage: "Por favor ingresa un mensaje",
                    errorSendFailed: "Error al enviar. Por favor intenta de nuevo más tarde.",
                    successTitle: "Enviado",
                    successMessage: "¡Gracias por tu comentario!"
                )
            default:
                return LocalizedStrings(
                    navTitle: "Contact",
                    title: "Anonymous Feedback",
                    description: "Send feedback anonymously without an email address",
                    categoryLabel: "Category",
                    categories: ["Bug Report", "Feature Request", "Other"],
                    messageLabel: "Message",
                    sendButton: "Send",
                    errorTitle: "Error",
                    errorEmptyMessage: "Please enter a message",
                    errorSendFailed: "Failed to send. Please try again later.",
                    successTitle: "Sent",
                    successMessage: "Thank you for your feedback!"
                )
            }
        }
    }

    private let strings = LocalizedStrings.forCurrentLanguage()

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = strings.title
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = strings.description
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.text = strings.categoryLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var categorySegment: UISegmentedControl = {
        let segment = UISegmentedControl(items: strings.categories)
        segment.selectedSegmentIndex = 0
        segment.translatesAutoresizingMaskIntoConstraints = false
        return segment
    }()

    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.text = strings.messageLabel
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let messageTextView: UITextView = {
        let tv = UITextView()
        tv.font = UIFont.systemFont(ofSize: 16)
        tv.layer.borderColor = UIColor.systemGray4.cgColor
        tv.layer.borderWidth = 1
        tv.layer.cornerRadius = 8
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()

    private lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(strings.sendButton, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        indicator.color = .white
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = strings.navTitle

        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        contentView.addSubview(titleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(categoryLabel)
        contentView.addSubview(categorySegment)
        contentView.addSubview(messageLabel)
        contentView.addSubview(messageTextView)
        contentView.addSubview(sendButton)
        sendButton.addSubview(activityIndicator)

        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            categoryLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            categoryLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            categorySegment.topAnchor.constraint(equalTo: categoryLabel.bottomAnchor, constant: 8),
            categorySegment.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            categorySegment.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),

            messageLabel.topAnchor.constraint(equalTo: categorySegment.bottomAnchor, constant: 24),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),

            messageTextView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            messageTextView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageTextView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            messageTextView.heightAnchor.constraint(equalToConstant: 200),

            sendButton.topAnchor.constraint(equalTo: messageTextView.bottomAnchor, constant: 32),
            sendButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            sendButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            sendButton.heightAnchor.constraint(equalToConstant: 50),
            sendButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -40),

            activityIndicator.centerXAnchor.constraint(equalTo: sendButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor)
        ])
    }

    private func setupKeyboardHandling() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    // MARK: - Actions

    @objc private func closeTapped() {
        dismiss(animated: true)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        scrollView.contentInset.bottom = keyboardFrame.height
        scrollView.verticalScrollIndicatorInsets.bottom = keyboardFrame.height
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func sendTapped() {
        guard let message = messageTextView.text,
              !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            showAlert(title: strings.errorTitle, message: strings.errorEmptyMessage)
            return
        }

        sendFeedback(message: message)
    }

    // MARK: - Firestore

    private func sendFeedback(message: String) {
        setLoading(true)

        let categories = ["bug", "feature", "other"]
        let selectedCategory = categories[categorySegment.selectedSegmentIndex]

        let feedbackData: [String: Any] = [
            "category": selectedCategory,
            "message": message,
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown",
            "deviceModel": UIDevice.current.model,
            "systemVersion": UIDevice.current.systemVersion,
            "locale": Locale.current.identifier,
            "timestamp": FieldValue.serverTimestamp()
        ]

        let db = Firestore.firestore()
        db.collection("feedbacks").addDocument(data: feedbackData) { [weak self] error in
            guard let self = self else { return }

            self.setLoading(false)

            if let error = error {
                self.logger.error("Firestore送信エラー: \(error.localizedDescription)")
                self.showAlert(title: self.strings.errorTitle, message: self.strings.errorSendFailed)
            } else {
                self.logger.info("フィードバック送信成功")
                self.showAlert(title: self.strings.successTitle, message: self.strings.successMessage) { [weak self] in
                    self?.dismiss(animated: true)
                }
            }
        }
    }

    // MARK: - Helpers

    private func setLoading(_ loading: Bool) {
        sendButton.isEnabled = !loading
        sendButton.setTitle(loading ? "" : strings.sendButton, for: .normal)

        if loading {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }

    private func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        present(alert, animated: true)
    }
}
