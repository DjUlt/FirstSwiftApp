//
//  AddContactViewController.swift
//  FirstApp
//
//  Created by user on 29.10.2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class AddContactViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    //MARK: Outlets
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Variables
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactImage.image = UIImage(systemName: "person")
        contactImage.layer.cornerRadius = contactImage.frame.height / 2
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).cgColor
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameTextField:
            nameTextField.resignFirstResponder()
            secondNameTextField.becomeFirstResponder()
        case secondNameTextField:
            secondNameTextField.resignFirstResponder()
            phoneNumberTextField.becomeFirstResponder()
        case phoneNumberTextField:
            phoneNumberTextField.resignFirstResponder()
            emailTextField.becomeFirstResponder()
        case emailTextField:
            emailTextField.resignFirstResponder()
            returnToTable()
        default:
            print("not intended textfield")
        }
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        contactImage.image = selectedImage
        
        setButtonEnabledOfFields()
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private functions
    private func checkFields() -> Bool {
        if nameTextField.text != ""
            || secondNameTextField.text != ""
            || phoneNumberTextField.text != ""
            || emailTextField.text != ""
            || contactImage.image != UIImage(systemName: "person"){
                return true
        }
        return false
    }
    
    private func setButtonEnabledOfFields() {
        if checkFields() {
            doneButton.isEnabled = true
            return
        }
        doneButton.isEnabled = false
    }
    
    private func sendData() {
        NotificationCenter.default.post(name: Notification.Name("didAddData"), object: nil,
                                        userInfo: ["contact": Contact(name: nameTextField.text!,
                                                                    secondName: secondNameTextField.text!,
                                                                    phoneNumber: phoneNumberTextField.text!,
                                                                    email: emailTextField.text!,
                                                                    image: contactImage.image!)])
    }
    
    private func returnToTable() {
        if checkFields() {
            sendData()
            dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message:
                "Can not add contact because no field wes filled or missing photo.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    //MARK: Actions
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
        nameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        returnToTable()
    }
    
    @IBAction func tappedOnEmpty(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    @IBAction func secondNameFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    @IBAction func phoneNumberFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    @IBAction func emailFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
}
