//
//  Extensions.swift
//  Messenger
//
//  Created by Артем on 28.09.2021.
//

import UIKit

extension String {
    
    /// Изменение символов для корректного сохранения id в Firebase
    func makeFirebaseString() -> String {
        let arrayCharacterToReplace = ["@", ".", "#", "$", "[", "]"]
        var finalString = self
        for character in arrayCharacterToReplace {
            finalString = finalString.replacingOccurrences(of: character, with: "-")
        }
        return finalString
    }
}

extension Notification.Name {
    
    /// Уведомление при входе пользователя в систему
    static let didLogInNotification = Notification.Name("didLogInNotification")
}
