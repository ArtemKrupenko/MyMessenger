import UIKit

// MARK: - TextField
extension RegisterViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == registerView.emailField {
            registerView.passwordField.becomeFirstResponder()
        } else if textField == registerView.passwordField {
            registerButtonTapped()
        }
        return true
    }
}

// MARK: - ImagePicker
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cделать фото", style: .default, handler: { [weak self] _ in
            self?.presentCamera()
        }))
        actionSheet.addAction(UIAlertAction(title: "Выбрать фото", style: .default, handler: { [weak self] _ in
            self?.presentPhotoPicker()
        }))
        actionSheet.addAction(UIAlertAction(title: "Отмена", style: .destructive, handler: nil))
        present(actionSheet, animated: true)
    }

    func presentCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            present(picker, animated: true)
        } else {
            let alertController = UIAlertController(title: "Внимание!",
                                                    message: "Камера отсутствует",
                                                    preferredStyle: .alert)
            let okAction = UIAlertAction(title: "ОК", style: .cancel)
            alertController.addAction(okAction)
            present(alertController, animated: true)
        }
    }

    func presentPhotoPicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.registerView.imageView.image = selectedImage
        self.registerView.imageView.layer.masksToBounds = true
        self.registerView.imageView.layer.borderWidth = 2
        self.registerView.imageView.layer.borderColor = UIColor.lightGray.cgColor
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
