//
//  StorageManager.swift
//  Messenger
//
//  Created by Артем on 19.10.2021.
//

import Foundation
import FirebaseStorage

/// Перечисление с протоколом Error
public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}

/// Позволяет получать, извлекать и загружать файлы в хранилище firebase.
final class StorageManager {

    static let shared = StorageManager()

    private init() {}

    private let metadata = StorageMetadata()

    private let storage = Storage.storage().reference()

    /// Создаем typealias возвращаемого типа (для удобства). Используется ниже
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    /// Загружает фото профиля в Firebase и возвращает строку с URL-адресом для загрузки
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] _, error in
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                print("Не удалось загрузить данные в Firebase для фотографии")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            strongSelf.storage.child("images/\(fileName)").downloadURL(completion: { url, _ in
                guard let url = url else {
                    print("Не удалось получить URL-адрес загрузки")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("URL-адрес загрузки получен: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Загружает фото, которое будет отправлено сообщением в диалог
    public func uploadMessagePhoto(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("message_images/\(fileName)").putData(data, metadata: nil, completion: { [weak self] _, error in
            guard error == nil else {
                print("Не удалось загрузить данные фото в Firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            self?.storage.child("message_images/\(fileName)").downloadURL(completion: { url, _ in
                guard let url = url else {
                    print("Не удалось получить URL-адрес загрузки")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                let urlString = url.absoluteString
                print("URL-адрес загрузки получен: \(urlString)")
                completion(.success(urlString))
            })
        })
    }

    /// Загружает видео, которое будет отправлено сообщением в диалог
    public func uploadMessageVideo(with fileURL: URL, fileName: String, completion: @escaping UploadPictureCompletion) {
        if let videoData = NSData(contentsOf: fileURL) as Data? {
            storage.child("message_videos/\(fileName)").putData(videoData, metadata: metadata) { [weak self] metadata, error in
                metadata?.contentType = "video/quicktime"
                guard error == nil else {
                    print("Не удалось загрузить данные видео в Firebase")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
                self?.storage.child("message_videos/\(fileName)").downloadURL(completion: { url, _ in
                    guard let url = url else {
                        print("Не удалось получить URL-адрес загрузки")
                        completion(.failure(StorageErrors.failedToGetDownloadUrl))
                        return
                    }
                    let urlString = url.absoluteString
                    print("URL-адрес загрузки получен: \(urlString)")
                    completion(.success(urlString))
                })
            }
        }
    }

    /// Загрузка URL-адреса
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)
        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
}
