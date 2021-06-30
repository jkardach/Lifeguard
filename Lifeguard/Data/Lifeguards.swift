//
//  Lifeguards.swift
//  Lifeguard
//
//  Created by jim kardach on 5/5/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//
/*
 This creates an array of lifeguards or board members as read from the
 Lifeguard rooster sheet.  if lifeguard = true, then its a lifeguard roster.
 if lifeguard = false, it is a board roster.  default is lifeguard.
 
 The readDB method will read the record from the lifeguard sheet roster.  This
 is an asynch method, calls delegate didUpdateLifeguard when finished
 */


import UIKit

public protocol UpdateLifeguardsDelegate {
    // lifeguard is lifeguard member or board members, final indicates last one
    func didUpdateLifeguard(lifeguard: Bool, finished: [Bool])

}
class Lifeguards: NSObject {
    enum ActiveList {
        case open
        case close
    }
    var activeList = ActiveList.open
    var onDuty: LifeGuard?          // this is the onduty lifeguard
    var members = [LifeGuard]()
    private var open = [CheckList]()
    private var close = [CheckList]()
    var list: [CheckList]
    var lifeguard: Bool    // indicates if lifeguards or board members
    var ready = false;
    var delegate: UpdateLifeguardsDelegate?
    var icon = "LifeguardRing"
    var sheetService: GTLRSheetsService!
    
    override init() {
        lifeguard = true
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        sheetService = appDelegate.sheetService
        list = open
    }
    init(lifeguard: Bool) {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        sheetService = appDelegate.sheetService
        self.lifeguard = lifeguard
        list = open
        if !lifeguard {
            icon = "Person"
        }
    }
    
    func setActiveList(list: ActiveList) {
        if list == .open {
            self.list = open
        } else if list == .close {
            self.list = close
        }
    }
    
    // swaps the lists
    func switchList() {
        if activeList == .close {
            list = open
        } else {
            list = close
        }
    }
    
    func allChecked() -> Bool {
        var allChecked = true
        for item in list {
            if !item.checked {
                allChecked = false
                break
            }
        }
        return allChecked
    }
    
    // clears the list
    func clearLists() {
        for item in list {
            item.checked = false
        }
    }
    
    // this function replaces the current OndutyLifeguard with lifeguard
    func updateOnDutyLifeguard(lifeguard: LifeGuard) {
        onDuty?.onDuty = false  // set current onduty lifeguard to false
        onDuty = lifeguard      // update new onduty lifeguard to lifeguard
        
    }
    // reads members, then lifeguard lists
    func readDB(vc: UIViewController) {
        readMembers(vc: vc)
        // if lifeguard, also get the checklists
        if lifeguard {
            self.getList(vc: vc, final: [false, true, false])  // get checklists
            self.switchList()
            self.getList(vc: vc, final: [false, false, true])  // get other checklist
            self.switchList()          // switch back to original list
        }
    }

    private func readMembers(vc: UIViewController) {
        let query: GTLRSheetsQuery_SpreadsheetsValuesGet!
        if lifeguard {
            query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: LIFEGUARD_SSHEET_ID,
                                                                range: "Sheet1!A3:K18")
        } else {
            query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: LIFEGUARD_SSHEET_ID,
                                                                range: "Sheet1!A21:E30")
        }
        sheetService.executeQuery(query) { (ticket:GTLRServiceTicket,
                                            result:Any?,
                                            error:Error?) in
            if let error = error {
                let alert = UIAlertController(title: "Error readLog",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                let ok = UIAlertAction.init(title: "OK",
                                            style: UIAlertAction.Style.default) {
                    (action: UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                vc.present(alert, animated: true, completion: nil)
            } else {
                let data = result as? GTLRSheets_ValueRange
                let rows = data?.values as? [[String]] ?? [[""]]
                if rows.count > 0 {
                    self.members.removeAll()  // empty the array
                    var arrayRow = 0;
                    for row in rows {
                        if(row.count > 1) {
                            let rec = LifeGuard.convertToRec(member: row, lifeguard: self.lifeguard)
                            if let rec = rec {
                                self.members.append(rec)
                            }
                        }
                        arrayRow += 1;
                    }
                }
            }
            // sort the array
            self.members.sort(by: { $0.lastName < $1.lastName})
            // lifeguard needs to get members and two lists, board just members
            if(self.lifeguard) {
                self.delegate?.didUpdateLifeguard(lifeguard: self.lifeguard, finished: [true, false, false])
            } else {
                self.delegate?.didUpdateLifeguard(lifeguard: self.lifeguard, finished: [true])
            }
        }
    }
    
    func getList(vc: UIViewController, final: [Bool]) {
        let query: GTLRSheetsQuery_SpreadsheetsValuesGet
        if activeList == .open {
            query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: CHK_SSHEET_ID,
                                                                        range: "OpenRules!A1:A")
        } else {
            query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: CHK_SSHEET_ID,
                                                                        range: "CloseRules!A1:A")
        }
        sheetService.executeQuery(query) { (ticket:GTLRServiceTicket,
                                            result:Any?,
                                            error:Error?) in
            if let error = error {
                let alert = UIAlertController(title: "Error readLog",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                let ok = UIAlertAction.init(title: "OK",
                                            style: UIAlertAction.Style.default) {
                    (action: UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                vc.present(alert, animated: true, completion: nil)
            } else {
                let data = result as? GTLRSheets_ValueRange
                let rows = data?.values as? [[String?]] ?? [[""]]
                if rows.count > 0 {
                    self.list.removeAll()  // empty the array
                    var indent = false
                    for row in rows {
                        if row.count > 0 {
                            if row[0] != "" {
                                let item = CheckList()
                                let itemVal = row[0]
                                if itemVal == "[Indent]" {
                                    indent = true
                                    continue
                                }
                                if itemVal == "[/Indent]" {
                                    indent = false
                                    continue
                                }
                                item.listItem = itemVal ?? " "
                                item.checked = false
                                item.indent = indent
                                self.list.append(item)
                            }
                        }
                    }
                }
            }
            self.delegate?.didUpdateLifeguard(lifeguard: self.lifeguard, finished: final)
        }
    }
    
    // this function appends the log to the log record
    func logList(vc: UIViewController) {
        // create the row to append to the log file
        let type = activeList == .open ? "open" : "close"
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyy hh:mm"
        let now = df.string(from: Date())
        let row = [[now, onDuty!.lastName + ", " + onDuty!.firstName, type]]
        
        let value = GTLRSheets_ValueRange()
        value.values = row
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: value,
                                                                   spreadsheetId: CHK_SSHEET_ID,
                                                                   range: "CheckLogs!A1")
        query.valueInputOption = "USER_ENTERED"
        sheetService.executeQuery(query) { (ticket:GTLRServiceTicket, result:Any?, error:Error?) in
            if let error = error {
                let alert = UIAlertController(title: "Error appendRow",
                                              message: error.localizedDescription,
                                              preferredStyle: .alert)
                let ok = UIAlertAction.init(title: "OK",
                                            style: UIAlertAction.Style.default) {
                (action: UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }
                alert.addAction(ok)
                vc.present(alert, animated: true, completion: nil)
            } else {
                print("append sheet successful")
            }
        }
    }
}
