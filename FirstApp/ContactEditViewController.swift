//
//  ContactEditViewController.swift
//  FirstApp
//
//  Created by user on 31.10.2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit

class ContactEditViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak var contactImageView: UIImageView!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var contactSecondNameTextField: UITextField!
    @IBOutlet weak var contactPhoneNumberTextField: UITextField!
    @IBOutlet weak var contactEmailTextField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    //MARK: Variables
    weak var dataToEdit: Contact!
    
    //MARK: functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contactImageView.image = UIImage(systemName: "person")
        contactImageView.layer.cornerRadius = contactImageView.frame.height / 2
        
        loadData()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset = .zero
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case contactNameTextField:
            contactNameTextField.resignFirstResponder()
            contactSecondNameTextField.becomeFirstResponder()
        case contactSecondNameTextField:
            contactSecondNameTextField.resignFirstResponder()
            contactPhoneNumberTextField.becomeFirstResponder()
        case contactPhoneNumberTextField:
            contactPhoneNumberTextField.resignFirstResponder()
            contactEmailTextField.becomeFirstResponder()
        case contactEmailTextField:
            contactEmailTextField.resignFirstResponder()
            onDone()
        default:
            print("not intended textfield")
        }
        
        return true
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        contactImageView.image = selectedImage
        
        setButtonEnabledOfFields()
        
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: Private functions
    private func checkFields() -> Bool {
        if contactNameTextField.text != ""
            || contactSecondNameTextField.text != ""
            || contactPhoneNumberTextField.text != ""
            || contactEmailTextField.text != ""
            || contactImageView.image != UIImage(systemName: "person"){
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
    
    private func loadData() {
        contactNameTextField.text = dataToEdit.name
        contactSecondNameTextField.text = dataToEdit.secondName
        contactPhoneNumberTextField.text = dataToEdit.phoneNumber
        contactEmailTextField.text = dataToEdit.email
        contactImageView.image = dataToEdit.image
    }

    private func onDone() {
        if checkFields() {
            if changesCheck() {
                dataToEdit.name = contactNameTextField.text ?? ""
                dataToEdit.secondName = contactSecondNameTextField.text ?? ""
                dataToEdit.phoneNumber = contactPhoneNumberTextField.text ?? ""
                dataToEdit.email = contactEmailTextField.text ?? ""
                dataToEdit.image = contactImageView.image ?? UIImage(systemName: "person")!
                
                NotificationCenter.default.post(name: Notification.Name("didChangeData"), object: nil, userInfo: ["contact": dataToEdit!])
            }
            
            navigationController?.popViewController(animated: true)
            dismiss(animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message:
                "Can not change contact because no field wes filled or missing photo.", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            present(alertController, animated: true, completion: nil)
        }
        
    }
            
    private func changesCheck() -> Bool {
        return dataToEdit.name != contactNameTextField.text ?? "" ||
                dataToEdit.secondName != contactSecondNameTextField.text ?? "" ||
                dataToEdit.phoneNumber != contactPhoneNumberTextField.text ?? "" ||
                dataToEdit.email != contactEmailTextField.text ?? "" ||
                dataToEdit.image != contactImageView.image ?? UIImage(systemName: "person")!
    }
    
    //MARK: Actions
    @IBAction func nameFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    
    @IBAction func contactSecondNameFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    
    @IBAction func contactPhoneNumberFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    
    @IBAction func contactEmailFieldChanged(_ sender: UITextField) {
        setButtonEnabledOfFields()
    }
    
    @IBAction func changeContactImageButtonPressed(_ sender: UIButton) {
        contactNameTextField.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func tapOnEmpty(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        let alert = UIAlertController(title: "Do you really want to delete this contact?", message: "He will really miss you 😭", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { action in
            NotificationCenter.default.post(name: .didDeleteData, object: nil, userInfo: ["contact":self.dataToEdit!])
            
            self.navigationController?.popToRootViewController(animated: true)
            self.dismiss(animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }
    
    @IBAction func doneButtonPressed(_ sender: UIButton) {
        onDone()
    }
}
