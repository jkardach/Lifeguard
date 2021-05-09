//
//  WorkerListTVC.swift
//  Lifeguard
//
//  Created by jim kardach on 5/5/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import UIKit

class WorkerListTVC: UITableViewController {
    var workerList: Lifeguards!
    var selectedRow = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    // if returning from LifeguardDetailTVC, then check if onduty lifeguard
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if selectedRow >= 0 {
            if workerList.lifeguard {
                let returningLifeguard = workerList.members[selectedRow]
                // if onDuty, then update the returningLifeguard
                if returningLifeguard.onDuty {
                    workerList.updateOnDutyLifeguard(lifeguard: returningLifeguard)
                }
            }
            selectedRow = -1    // set sentinal 
        }
        tableView.reloadData()  // update table incase onduty lifeguard appeared
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return workerList.members.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if workerList.lifeguard {
            // this uses the basic cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
            cell.textLabel?.font = UIFont(name:"System", size: 18.0)
            cell.textLabel?.text = workerList.members[indexPath.row].firstName + " " + workerList.members[indexPath.row].lastName
            cell.textLabel?.textColor = UIColor.black
            cell.imageView?.image = UIImage(named: workerList.icon)
            // mark the on-duty lifeguard
            if workerList.lifeguard {
                if workerList.members[indexPath.row] == workerList.onDuty {
                    cell.textLabel!.text! += " (On-Duty)"
                    cell.textLabel?.textColor = UIColor.systemRed
                }
            }
            return cell
        } else {
            // this uses cell with sms/email buttons
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as? DirTVCell
            cell?.name?.font = UIFont(name:"System", size: 18.0)
            cell?.name.text = workerList.members[indexPath.row].firstName + " " + workerList.members[indexPath.row].lastName
            cell!.name?.textColor = UIColor.black
            cell!.title.text = workerList.members[indexPath.row].title
            cell!.title?.textColor = UIColor.black
            cell!.icon.image = UIImage(named: workerList.icon)
            cell?.smsButton.tag = indexPath.row
            cell?.emailButton.tag = indexPath.row
            return cell!
        }

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
        if(workerList.lifeguard) {
            performSegue(withIdentifier: "LifeguardDetail", sender: self) // perform the segue pointed to by row
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // one of the checklists
        selectedRow = tableView.indexPathForSelectedRow!.row  // the lifeguard to view
        let lifeguard = workerList.members[selectedRow]
        let vc = segue.destination as! LifeguardDetailTVC
        vc.title = lifeguard.firstName + " " + lifeguard.lastName
        vc.lifeguard = lifeguard
    }

    
    
    @IBAction func smsButtonPressed(_ sender: UIButton) {
        let worker = workerList.members[sender.tag]
        worker.sendSMS(vc: self)
        print("SMS Button pressed", sender.tag)
    }
    @IBAction func emailButtonPressed(_ sender: UIButton) {
        let worker = workerList.members[sender.tag]
        worker.sendEmail(vc: self, subject: "Hey")
        print("Email Button Pressed", sender.tag)
    }
    
}
