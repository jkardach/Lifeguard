//
//  LifeGuard.swift
//  Lifeguard
//
//  Created by jim kardach on 5/3/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import UIKit


class LifeGuard: PhoneEmail {
    var firstName = ""
    var lastName = ""
    var phone = ""
    var email = ""
    var redCrossExp = ""
    var birthDay = ""
    var age = ""
    var certID = ""
    var school = ""
    var grade = ""
    var major = ""
    var ext120Day = ""
    var work2021 = ""
    var x = ""
    var lifeguard = true
    var title = ""
    var onDuty = false
    
    var icon: String {
        get {
            if lifeguard {
                return "LifeguardRing"
            } else {
                return "Person"
            }
        }
    }

    static let keyPaths = [\LifeGuard.firstName, \.lastName, \.phone,
                           \.email, \.redCrossExp, \.birthDay, \.age, \.certID,
                           \.school, \.grade, \.major]
    
    static let propertyLabels = ["first Name: ", "Last Name: ", "Phone: ",
                                 "Email: ", "Red Cross Exp: ", "Birthday: ",
                                 "Age: ", "Certificate ID: ", "School: ",
                                 "Grade: ", "Major: "]
    // keys used for boardmembers
    static let bKeyPaths = [\LifeGuard.firstName, \.lastName, \.phone,
                            \.email, \.title]
    
    static let bPropertyLabels = ["first Name: ", "Last Name: ", "Phone: ",
                                 "Email: ", "Title: "]

    // define constructor
    override init() {
        super.init()
        lifeguard = true;

    }
    
    // define constructor with argument.  Either lifeguard (true) or coordinator
    init(lifeguard: Bool) {
        super.init()
        self.lifeguard = lifeguard
    }
    

    
    // converts lifeGuard rooster to record
    static func convertToRec(member: [String], lifeguard: Bool) -> LifeGuard? {
        if  member[0] == "LName" ||
            member[0] == "Swim Club Board" ||
            member[0] == "" ||
            member[0] == " " {
            return nil  // skip these guys -> remove
        }
        

        let rec = LifeGuard(lifeguard: lifeguard)
        for i in 0..<member.count {
            //rec[keyPath: Members.keyPaths[i]] = member[i]
            if lifeguard {
                rec[keyPath: keyPaths[i]] = member[i]   // lifeguards
            } else {
                rec[keyPath: bKeyPaths[i]] = member[i]  // board members
            }
        }
        return rec
    }
    
    
    // extesions for sending SMS, calling and sending emails
    
    func sendSMS(vc: UIViewController) {
        sendSMS(vc: vc, phone: phone)
    }
    
    func call(vc: UIViewController) {
        call(vc: vc, phone: phone)
    }
    
    func sendEmail(vc: UIViewController, subject: String) {
        sendEmail(vc: vc, subject: subject, email: email)
    }
    
}

