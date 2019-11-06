//
//  ContactDataViewController.swift
//  FirstApp
//
//  Created by user on 29.10.2019.
//  Copyright © 2019 user. All rights reserved.
//

import UIKit
import MessageUI

class ContactDataViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    //MARK: Outlets
    @IBOutlet weak private var contactPhotoImageView: UIImageView!
    @IBOutlet weak private var contactNameLabel: UILabel!
    @IBOutlet weak private var sendMailButton: UIButton!
    @IBOutlet weak private var sendMessageButton: UIButton!
    @IBOutlet weak private var contactPhoneNumberLabel: UILabel!
    @IBOutlet weak private var contactEmailLabel: UILabel!
    
    weak var gottenContactData: Contact!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactPhotoImageView.layer.cornerRadius = contactPhotoImageView.frame.height / 2
        
        loadData()
    }
    
    //MARK: Functions
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if navigationController?.topViewController == self {
            loadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toContactEditViewController" {
            let secondVC: ContactEditViewController = segue.destination as! ContactEditViewController
            secondVC.dataToEdit = gottenContactData
        }
    }
    
    //MARK: Private functions
    
    private func sendEmail(recepient: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([recepient])
            mail.setMessageBody("", isHTML: false)

            present(mail, animated: true, completion: nil)
        } else {
            let alertController = UIAlertController(title: "Error", message: "Cannot send mail", preferredStyle: .alert)
            
            alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))

            present(alertController, animated: true, completion: nil)
        }
    }
    
    private func loadData() {
        contactPhotoImageView.image = gottenContactData.image
        contactNameLabel.text = gottenContactData.name + " " + gottenContactData.secondName
        contactPhoneNumberLabel.text = "Phone number: " + gottenContactData.phoneNumber
        contactEmailLabel.text = "Email: " + gottenContactData.email
    }

    //MARK: Actions
    @IBAction func sendMessageButtonPressed(_ sender: UIButton) {
        sendEmail(recepient: String( contactEmailLabel.text!.suffix(contactEmailLabel.text!.count - 7)) )
    }
}
