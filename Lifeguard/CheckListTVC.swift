//
//  CheckListTVC.swift
//  Lifeguard
//
//  Created by jim kardach on 5/5/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//
/*
 This displays Lifeguard's check  list.  It has two sections.  The first section
 allows the on-duty lifeguard to check-in, it is always 1 row.  If there is a
 onduty lifeguard, then it is displayed, else displays blank or "no lifeguard selected"
 
 The 2nd section shows the checklist
 */

import UIKit

class CheckListTVC: UITableViewController {
    var lifeguards: Lifeguards!
    var list: [CheckList]!
    //var open: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log",
//                                                                 style: .plain,
//                                                                 target: self,
//                                                                 action: #selector(logCheckList))
        
        lifeguards.clearLists() // clears the bools, all unchecked
        list = lifeguards.getActiveList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // execute if pressed backbutton
        if self.isMovingFromParent {
            
        }
    }
    
    @objc func logCheckList() {
        // make sure everything is checked
//        var list = lifeguards.getActiveList()
        var allChecked = true
        for item in list {
            if !item.checked {
                allChecked = false
//                // have not checked everything
//                let alert = UIAlertController(title: "Finish Checking Items",
//                                              message: "Have you checked all items on the list?",
//                                              preferredStyle: .alert)
//                let ok = UIAlertAction.init(title: "OK",
//                                            style: UIAlertAction.Style.default) {
//                    (action: UIAlertAction) in
//                    alert.dismiss(animated: true, completion: nil)
//                }
//                alert.addAction(ok)
//                self.present(alert, animated: true, completion: nil)
//                return
            }
        }
        if lifeguards.onDuty == nil {
            let alert = UIAlertController(title: "Have not selected an On-Duty Lifeguard",
                                          message: "Click the 'No on-duty lifeguard selected' and pick one",
                                          preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK",
                                        style: UIAlertAction.Style.default) {
                (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
        if allChecked {
            lifeguards.logList(vc: self)  // write log
        }
//        lifeguards.logList(vc: self)  // write log
//        self.navigationController?.popViewController(animated: true) // exit screen
    }
    
    // if coming back reloadData as a new on-duty lifeguard might be selected
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    // first section selects the lifeguard
    // second section shows the checklist (open if open, else close)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return 1
        } else {
            var list = lifeguards.getActiveList()
            return list.count
        }
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.textLabel?.font = UIFont(name:"System", size: 18.0)
        cell.indentationLevel = 0;
        
        if indexPath.section == 0 {
            cell.accessoryType = .disclosureIndicator
            if lifeguards.onDuty != nil {
                cell.textLabel!.text = lifeguards.onDuty!.firstName + " " + lifeguards.onDuty!.lastName
                cell.imageView?.image = UIImage(named: lifeguards.onDuty!.icon ?? "lifeguardRing")
            } else {
                cell.textLabel!.text = "No on-duty lifeguard selected"
                cell.imageView?.image = nil
            }
            cell.textLabel?.textColor = UIColor.systemRed
        } else {
            cell.imageView?.image = nil
            cell.textLabel?.textColor = UIColor.label
                cell.textLabel!.text = list[indexPath.row].listItem
                if list[indexPath.row].indent {
                    cell.indentationLevel = 1;
                } else {
                    cell.indentationLevel = 0;
                }
                if list[indexPath.row].checked {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            
        }
        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            performSegue(withIdentifier: "Lifeguards", sender: self)
        } else {
            if !list[indexPath.row].header {
                list[indexPath.row].checked = !list[indexPath.row].checked
                self.tableView.reloadData()
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // one of the checklists
        if segue.identifier == "Lifeguards" {
            let vc = segue.destination as! WorkerListTVC
            vc.title = "Lifeguards"
            vc.workerList = lifeguards
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}
