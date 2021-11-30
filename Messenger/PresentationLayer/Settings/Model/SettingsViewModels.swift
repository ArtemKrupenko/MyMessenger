import UIKit

struct Section {
    let title: String
    let options: [SettingViewModel]
}

struct SettingViewModel {
    let viewModelType: SettingViewModelType
    let title: String
    let icon: UIImage?
    let iconBackgroundColor: UIColor
    let handler: (() -> Void)?
}

enum SettingViewModelType {
    case info
    case logout
}
