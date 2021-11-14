//
//  ProfileViewModels.swift
//  Messenger
//
//  Created by Артем on 12.11.2021.
//

import Foundation

enum ProfileViewModelType {
    case info, logout
}

struct ProfileViewModel {
    public let viewModelType: ProfileViewModelType
    public let title: String
    public let handler: (() -> Void)?
}
