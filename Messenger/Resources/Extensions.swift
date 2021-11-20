//
//  Extensions.swift
//  Messenger
//
//  Created by Артем on 28.09.2021.
//

import UIKit

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }
}

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
