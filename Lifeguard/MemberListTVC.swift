//
//  MemberListTVC.swift
//  Lifeguard
//
//  Created by jim kardach on 4/28/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import UIKit


var members = [Members]()     // all members will be in an array of members
var sheetService: GTLRSheetsService!

class MemberListTVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        sheetService = appDelegate.sheetService
        readSheet();
    }
    
    func readSheet() {
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: ACT_SSHEET_ID,
                                                                range: "Members!A2:V")
        
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
                self.present(alert, animated: true, completion: nil)
            } else {
                print("readLog successful")
                let data = result as? GTLRSheets_ValueRange
                let rows = data?.values as? [[String]] ?? [[""]]
                if rows.count > 0 {
                    members.removeAll()  // empty the array
                    var arrayRow = 0;
                    for row in rows {
                        if(row.count > 1) {
                            let rec = Members.convertToRec(member: row)
                            if let rec = rec {
                                members.append(rec)
                            }
                        }
                        arrayRow += 1;
                    }
                }
            }
            members.sort(by: { $0.lastName < $1.lastName})
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return members.count
    }
    
//     set height of headers in tableview
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }



    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let tvWidth = tableView.frame.size.width - 10;
        let headerView = UIView.init(frame: CGRect(x: 5, y: 0, width: tvWidth, height: 50))
        headerView.backgroundColor = UIColor.systemGray // hex to uicolor extension

        let headerTxt = UILabel.init(frame: CGRect(x: 5, y: 15, width: tvWidth, height: 22))
        headerTxt.textAlignment = NSTextAlignment.left
        headerTxt.font = UIFont(name: "Arial-BoldMT", size: 18)
        headerTxt.textColor = UIColor.label
        headerTxt.text = "Family(type, ID)"
        
        headerView.addSubview(headerTxt)
        return headerView
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BasicCell", for: indexPath)
        let member = members[indexPath.row]
        cell.textLabel!.text = member.lastName + "(" + member.type + ", " + member.id + ")"
        cell.textLabel?.textColor = UIColor.black
        cell.textLabel?.font = UIFont(name: "System", size: 18)
        cell.accessoryView = UIImageView(image: UIImage(systemName: "chevron.right"))
        cell.imageView?.image = UIImage(named: "SwimClub10mm")
        
        if indexPath.row % 2 == 0 {
            let color = UIColor.init(hex: "#1cc5dc") // light blue
            cell.backgroundColor = color
        } else {
            cell.backgroundColor = UIColor.white
        }
        return cell
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        if segue.identifier == "Show" {
            let indexpath = tableView.indexPathForSelectedRow
            let mdTVC = segue.destination as! MemberDetailTVC
            mdTVC.member = members[indexpath!.row]
            mdTVC.title = mdTVC.member.lastName
        }
    }
}

// converts a hex color to a UIColor, must be "#RRGGBB" hexidecimal
extension UIColor {
    public convenience init?(hex: String) {
        let r, g, b: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 6 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 16) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 8) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 4) / 255

                    self.init(red: r, green: g, blue: b, alpha: 1.0)
                    return
                }
            }
        }
        return nil
    }
}
