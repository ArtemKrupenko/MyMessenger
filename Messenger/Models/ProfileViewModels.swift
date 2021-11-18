//
//  ProfileViewModels.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import UIKit

enum ProfileViewModelType {
    case info
    case logout
}

struct Section {
    public let title: String
    public let options: [ProfileViewModel]
}

struct ProfileViewModel {
    public let viewModelType: ProfileViewModelType
    public let title: String
    public let icon: UIImage?
    public let iconBackgroundColor: UIColor
    public let handler: (() -> Void)?
}
