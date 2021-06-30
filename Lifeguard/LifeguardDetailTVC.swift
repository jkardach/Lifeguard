//
//  LifeguardDetailTVC.swift
//  Lifeguard
//
//  Created by jim kardach on 5/8/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//
/*
 0 On Duty
 1 phone/email
 2 Red Cross Experiration
 3 DOB
 4 Age
 5 Cert ID
 6 School
 7 Grade
 8 Major
 */

import UIKit

class LifeguardDetailTVC: UITableViewController {
    var lifeguard: LifeGuard!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 9
    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
     
        let row = indexPath.row
        if row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell2", for: indexPath) as? DirTVCell
            cell?.name?.font = UIFont(name:"System", size: 18.0)
            cell!.name.text = lifeguard.firstName + " " + lifeguard.lastName
            cell!.title.text = "Lifeguard"
            if let icon = lifeguard.icon {
                cell!.imageView!.image = UIImage(named: icon)
            } else {
                cell!.imageView!.image = UIImage(systemName: "Person.fill")
            }
            
            return cell!
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell1", for: indexPath)
        cell.textLabel?.font = UIFont(name:"System", size: 18.0)
        switch row {
        case 0:
            cell.textLabel!.text = "On-Duty Lifeguard"
            if lifeguard.onDuty {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .detailButton
            }
        case 2:
            cell.textLabel!.text = "Red Cross Certification Expiration: " + lifeguard.redCrossExp
        case 3:
            cell.textLabel!.text = "Birthday: " + lifeguard.birthDay
        case 4:
            cell.textLabel!.text = "Age: " + lifeguard.age
        case 5:
            cell.textLabel!.text = "Certification ID: " + lifeguard.certID
        case 6:
            cell.textLabel!.text = "School: " + lifeguard.school
        case 7:
            cell.textLabel!.text = "Grade: " + lifeguard.grade
        case 8:
            cell.textLabel!.text = "Major: " + lifeguard.major
        default:
            cell.textLabel!.text = "Error, should never reach here"
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
        if indexPath.row == 0 {
            lifeguard.onDuty = !lifeguard.onDuty    // flip the onDuty bool
            tableView.reloadData()
        }
    }

/*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
