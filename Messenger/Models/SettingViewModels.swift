//
//  SettingViewModels.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import UIKit

enum SettingViewModelType {
    case info
    case logout
}

struct Section {
    public let title: String
    public let options: [SettingViewModel]
}

struct SettingViewModel {
    public let viewModelType: SettingViewModelType
    public let title: String
    public let icon: UIImage?
    public let iconBackgroundColor: UIColor
    public let handler: (() -> Void)?
}
