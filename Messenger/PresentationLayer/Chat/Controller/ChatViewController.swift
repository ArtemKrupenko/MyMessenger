import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

final class ChatViewController: MessagesViewController {

    // MARK: - Properties
    public var senderPhotoURL: URL?
    public var otherUserPhotoURL: URL?

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale.init(identifier: "en_US")
        return formatter
    }()
    
    public var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Я")
    }
    
    public let otherUserEmail: String
    public var isNewConversation = false
    public var conversationId: String?
    public var messages = [Message]()
    public let сhatView = ChatView()
    
    // MARK: - Dependencies
    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - VC Lifecycle
    override func loadView() {
        view = сhatView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    // MARK: - Functions
    private func setupView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        navigationItem.backBarButtonItem  = UIBarButtonItem(title: "Назад", style: .plain, target: nil, action: nil)
        let gesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(gesture)
    }

    private func setupInputButton() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(ImagesSystem.paperclip, for: .normal)
        button.onTouchUpInside { [weak self] _ in
            self?.presentInputActionSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }

    private func presentInputActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Фото или видео", style: .default, handler: { [weak self] _ in
            self?.presentPhotoVideoInputActionSheet()
        }))
        actionSheet.addAction(UIAlertAction(title: "Местоположение", style: .default, handler: { [weak self] _ in
            self?.presentLocationPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

    private func presentLocationPicker() {
        let viewController = LocationPickerViewController(coordinates: nil)
        viewController.title = "Выберите местоположение"
        viewController.hidesBottomBarWhenPushed = true
        viewController.navigationItem.largeTitleDisplayMode = .never
        viewController.completion = { [weak self] selectedCoordinates in
            guard let strongSelf = self else {
                return
            }
            guard let messageId = strongSelf.createMessageId(),
                let conversationId = strongSelf.conversationId,
                let name = strongSelf.title,
                let selfSender = strongSelf.selfSender else {
                    return
            }
            let latitude: Double = selectedCoordinates.latitude
            let longitude: Double = selectedCoordinates.longitude
            print("Долгота = \(longitude) | Широта = \(latitude)")
            let location = Location(location: CLLocation(latitude: latitude, longitude: longitude), size: .zero)
            let message = Message(sender: selfSender,
                                  messageId: messageId,
                                  sentDate: Date(),
                                  kind: .location(location))
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                if success {
                    print("Отправлено сообщение о местоположении")
                } else {
                    print("Не удалось отправить сообщение о местоположении")
                }
            })
        }
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func presentPhotoVideoInputActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Камера", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Фото", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Видео", style: .default, handler: { [weak self] _ in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            picker.mediaTypes = ["public.movie"]
            picker.videoExportPreset = AVAssetExportPresetHEVCHighestQuality
            self?.present(picker, animated: true)
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
        present(actionSheet, animated: true)
    }

    private func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image", "public.movie"]
            picker.videoExportPreset = AVAssetExportPresetHEVCHighestQuality
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        } else {
            let alertController = UIAlertController(title: "Внимание",
                                                    message: "У вас нет камеры",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }

    public func listenForMessages(id: String, shouldScrollToBottom: Bool) {
        DatabaseManager.shared.getAllMessagesForConversation(with: id, completion: { [weak self] result in
            switch result {
            case let .success(messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset() // здесь точно .reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem(at: .bottom, animated: false)
                    }
                }
            case let .failure(error):
                print("Не удалось получить сообщения: \(error)")
            }
        })
    }
}
