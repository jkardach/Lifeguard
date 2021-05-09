//
//  Members.swift
//  Lifeguard
//
//  Created by jim kardach on 4/28/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import Foundation

class Members: NSObject {
    var start = "A2"
    var lastName = ""
    var id = ""
    var type = ""
    var salutation = ""
    var address = ""
    var cityState = ""
    var zip = ""
    var cellphone1 = ""
    var cellphone2 = ""
    var email = ""
    var email2 = ""
    var dirName = ""
    var dirEmail = ""
    var dirPhone = ""
    var dontUse = ""
    var kidsNames = ""
    var numMembers = ""
    var oweMoney = ""
    var x = "x"
    var landlinePhone = ""
    var firstName1 = ""
    var firstName2 = ""
    var infoUpdated = ""
    var eligable = false
    let end = "v140"
    
    // using keypaths
    static let keyPaths = [\.lastName, \.id, \.type,
                          \.salutation, \.address,
                          \.cityState, \.zip, \.cellphone1,
                          \Members.cellphone2,
                          \.email, \.email2, \.x,
                          \.x, \.x, \.x,
                          \.kidsNames, \.numMembers, \.oweMoney,
                          \.x, \.landlinePhone,
                          \.firstName1, \.firstName2]
    
    static let memKeys = ["lastName", "id", "type",
                          "salutation", "address",
                          "cityState", "zip", "cellphone1",
                          "cellphone2",
                          "email", "email2", "",
                          "", "", "",
                          "kidsNames", "numMembers", "oweMoney",
                          "", "landlinePhone",
                          "firstName1", "firstName2"]
    
    static let memberKeyPath = [\.lastName, \.id, \.type,
                                \.salutation, \.address,
                                \.cityState, \.zip, \.cellphone1,
                                \.cellphone2,
                                \.email, \.email2,
                                \.kidsNames, \.numMembers, \.oweMoney,
                                \.landlinePhone,
                                \.firstName1, \Members.firstName2]
    
    static let memberKeys = ["lastName", "id", "type",
                             "salutation", "address",
                             "cityState", "zip", "cellphone1",
                             "cellphone2", "email", "email2",
                             "kidsNames", "numMembers", "oweMoney",
                             "landlinePhone","firstName1", "firstName2"]
    
    // converts memSheet to record
    static func convertToRec(member: [String]) -> Members? {
        if  member[0] == "Last Name" ||
            member[0] == "" ||
            member[0] == "zzExtLeaseA" ||
            member[0] == "Test Row" ||
            member[0] == "Test row" ||
            member[0] == "Test" ||
            member[0] == "Lease" ||
            member[0] == "Sold" ||
            member[0] == "Trial" ||
            member[2] == "" ||
            member[2] == "CO" ||
            member[2] == "SL" {
            return nil  // skip these guys -> remove
        }
        let rec = Members()
        for i in 0..<member.count {
            if Members.keyPaths[i] == \Members.x {   // skip blank lines
            //if Members.memKeys[i] == "" {
                continue;
            }
            rec.eligable = true
            if i == 17 {
                let owesMoney: String = member[17]
                if owesMoney == "x" ||
                    rec.type == "PL" {
                    rec.eligable = false
                }
                if rec.type == "BD" || rec.type == "BE" {
                    rec.eligable = true
                }
            } else {
                rec[keyPath: Members.keyPaths[i]] = member[i]
                //rec.setValue(member[i], forKey: memKeys[i])
            }
        }
        // if record is in checkedInToday, then use this record
        return rec
    }
}
