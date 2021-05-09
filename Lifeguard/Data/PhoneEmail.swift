//
//  PhoneEmail.swift
//  Lifeguards
//
//  Created by jim kardach on 5/3/21.
//

import UIKit
import MessageUI

class PhoneEmail: NSObject, MFMessageComposeViewControllerDelegate,
                  MFMailComposeViewControllerDelegate {
    
    var vc: UIViewController!
    
    // sends an SMS to an array of phone numbers with body text
    func sendSMS(vc: UIViewController, toPhones: [String], withBody: String) {
        self.vc = vc                                        // save the view Controller
        let messageVC = MFMessageComposeViewController()
        messageVC.body = withBody;
        messageVC.recipients = toPhones
        messageVC.messageComposeDelegate = self     // delegate method is here
        vc.present(messageVC, animated: true, completion: nil) // present at calling
    }
    
    // sends an SMS to this instances phone1 (phone = 1), phone2 (phone = 2) or opt phone
    func sendSMS(vc: UIViewController, phone: String) {
        // make an SMS
        let phoneNum = phone.trimmingCharacters(in: .whitespaces)
        sendSMS(vc: vc, toPhones: [phoneNum], withBody: "Important message from Saratoga Swim Club!  ")
    }
    
    // if supports phone call make phone call, else SMS
    func call(vc: UIViewController, phone: String) {
        self.vc = vc
        let phoneNum = phone.trimmingCharacters(in: .whitespaces)
        
        // make a phone call, if you can't then make SMS
        if UIApplication.shared.canOpenURL(URL(string: "tel://")!) {
            if let url = URL(string: "tel://\(phoneNum)"),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else if (MFMessageComposeViewController.canSendText()){
            sendSMS(vc: vc, phone: phoneNum)
        }
    }
    
    // this is the delegate method called after the SMS was sent.
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
        switch (result) {
        case .cancelled:
            print("Message was cancelled")
        case .failed:
            print("Message failed")
        case .sent:
            print("Message was sent")
        default:
            return
        }
        vc.dismiss(animated: true, completion: nil)
    }
    
    
    // this sends an email
    func sendEmail(vc: UIViewController,
                   subject: String,
                   body: String,
                   toEmails: [String]) {
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(toEmails)
            mail.setMessageBody(body, isHTML: false)
            
            vc.present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    // sends a single email
    func sendEmail(vc: UIViewController,
                   subject: String,
                   email: String) {
        sendEmail(vc: vc, subject: subject, body: "", toEmails: [email])
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result:
                                MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
