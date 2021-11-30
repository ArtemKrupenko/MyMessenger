//
//  ChatViewController.swift
//  Messenger
//
//  Created by Артем on 15.10.2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit
import CoreLocation

final class ChatViewController: MessagesViewController {

    private var senderPhotoURL: URL?
    private var otherUserPhotoURL: URL?

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = Locale.init(identifier: "en_US")
        return formatter
    }()

    public let otherUserEmail: String
    public var isNewConversation = false
    private var conversationId: String?
    private var messages = [Message]()
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "Я")
    }

    init(with email: String, id: String?) {
        self.conversationId = id
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) не был выполнен")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId, shouldScrollToBottom: true)
        }
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

    private func listenForMessages(id: String, shouldScrollToBottom: Bool) {
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let messageId = createMessageId(),
              let conversationId = conversationId,
              let name = self.title,
              let selfSender = selfSender else {
            return
        }
        if let image = info[.editedImage] as? UIImage, let imageData = image.pngData() {
            let fileName = "photo_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".png"
            // Загрузка изображения
            StorageManager.shared.uploadMessagePhoto(with: imageData, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case let .success(urlString):
                    // Отправка фотосообщения
                    guard let url = URL(string: urlString) else {
                        return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: Images.imagePlaceHolder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .photo(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        if success {
                            print("Отправлено фотосообщение")
                        } else {
                            print("Не удалось отправить фотосообщение")
                        }
                    })
                    print("Изображение загружено в сообщение: \(urlString)")
                case let .failure(error):
                    print("Не удалось загрузить изображение: \(error)")
                }
            })
        } else if let videoUrl = info[.mediaURL] as? URL {
            let fileName = "video_message_" + messageId.replacingOccurrences(of: " ", with: "-") + ".mov"
            // Загрузка видео
            StorageManager.shared.uploadMessageVideo(with: videoUrl, fileName: fileName, completion: { [weak self] result in
                guard let strongSelf = self else {
                    return
                }
                switch result {
                case let .success(urlString):
                    // Отправка видеосообщения
                    guard let url = URL(string: urlString) else {   // - TODO: изменить placeholder на отображение видео
                        return
                    }
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: Images.imagePlaceHolder,
                                      size: .zero)
                    let message = Message(sender: selfSender,
                                          messageId: messageId,
                                          sentDate: Date(),
                                          kind: .video(media))
                    DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: strongSelf.otherUserEmail, name: name, newMessage: message, completion: { success in
                        if success {
                            print("Отправлено видеосообщение")
                        } else {
                            print("Не удалось отправить видеосообщение")
                        }
                    })
                    print("Видео загружено в сообщение: \(urlString)")
                case let .failure(error):
                    print("Не удалось загрузить видео: \(error)")
                }
            })
        }
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        print("Отправка: \(text)")
        let message = Message(sender: selfSender,
                              messageId: messageId,
                              sentDate: Date(),
                              kind: .text(text))
        // Отправка сообщения
        if isNewConversation {
            // Создаем диалог в database
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "Пользователь", firstMessage: message, completion: { [weak self] success in
                if success {
                    print("Сообщение отправлено")
                    self?.isNewConversation = false
                    let newConversationId = "conversation_\(message.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMessages(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                } else {
                    print("Не удалось отправить")
                }
            })
        } else {
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            // Присоединяемся к существующему диалогу
            DatabaseManager.shared.sendMessage(to: conversationId, otherUserEmail: otherUserEmail, name: name, newMessage: message, completion: { [weak self] success in
                if success {
                    self?.messageInputBar.inputTextView.text = nil
                    print("Сообщение отправлено")
                } else {
                    print("Не удалось отправить")
                }
            })
        }
    }

    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        let dateString = Self.dateFormatter.string(from: Date()).makeFirebaseString()
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {

    /// Тип отправителя новых сообщений в MessagesCollectionView (необходимая функция)
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Если Sender равен nil, письмо должно быть кэшировано")
    }

    /// Сообщение, которое будет использоваться для MessageCollectionViewCell  (необходимая функция)
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    /// Количество секций, которые будут отображаться в MessagesCollectionView (необходимая функция)
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    /// Используется для настройки UIImageView ячейки MediaMessageCell
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        switch message.kind {
        case let .photo(media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        // - TODO: изменить placeholder на отображение видео
        case let .video(media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, placeholderImage: Images.imagePlaceHolder)
        default:
            break
        }
    }

    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // наше сообщение, которое мы отправили
            return UIColor(named: "ColorLogo")!
        }
        return .secondarySystemBackground
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == selfSender?.senderId {
            // показывает изображение пользователя
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            } else {
                guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
                    return
                }
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                // получение url
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case let .success(url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case let .failure(error):
                        print("\(error)")
                    }
                })
            }
        } else {
            // изображение другого пользователя
            if let otherUserPhotoURL = self.otherUserPhotoURL {
                avatarView.sd_setImage(with: otherUserPhotoURL, completed: nil)
            } else {
                let email = self.otherUserEmail
                let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
                let path = "images/\(safeEmail)_profile_picture.png"
                // получение url
                StorageManager.shared.downloadURL(for: path, completion: { [weak self] result in
                    switch result {
                    case let .success(url):
                        self?.otherUserPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case let .failure(error):
                        print("\(error)")
                    }
                })
            }
        }
    }
}

extension ChatViewController: MessageCellDelegate {

    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case let .location(locationData):
            let coordinates = locationData.location.coordinate
            let viewController = LocationPickerViewController(coordinates: coordinates)
            viewController.title = "Местоположение"
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        default:
            break
        }
    }

    /// Переход на экран фото или видео
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else {
            return
        }
        let message = messages[indexPath.section]
        switch message.kind {
        case let .photo(media):
            guard let imageUrl = media.url else {
                return
            }
            let viewController = PhotoViewerViewController(with: imageUrl)
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        case let .video(media):
            guard let videoUrl = media.url else {
                return
            }
            let viewController = AVPlayerViewController()
            viewController.player = AVPlayer(url: videoUrl)
            viewController.player?.play()
            present(viewController, animated: true)
        default:
            break
        }
    }
}
