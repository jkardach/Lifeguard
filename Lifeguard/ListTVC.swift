//
//  ListTVC.swift
//  Lifeguard
//
//  Created by jim kardach on 5/4/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//
/*
 This will get a list of lifeguards and coordinators and store them in two
 arrays (lifeguards and coordinators).
 
 This comes from the google sheet lifeguard contact sheet which is embedded
 in the lifeguard's website.
 
 When calling a checklist, the array of lifeguards is passed to it so the lifeguard
 can select their name as doing the checklist.
 
 When calling Lifeguards, lifeguards is passed
 
 When calling Coordinators, coordinators is passed.
 
 */

import UIKit

class ListTVC: UITableViewController {
    
    let list = ["Opening Checklist", "Closing Checklist", "Parties", "Nanny",
                "Rules", "Emergency", "Lifeguards", "Board Members"]
    let readySegueIds = ["CheckList", "CheckList", "Parties", "Nanny", "Rules",
                    "Emergency", "WorkerList", "WorkerList"]
    let notReadySegueIDs = [nil, nil, "Parties", "Nanny", "Rules",
                            "Emergency", nil, nil]
    var segueIds: [String?]!
    let readyIcons = ["list.bullet.rectangle", "list.bullet.rectangle", "gift.fill", "person.2.fill", "list.number",
                      "exclamationmark.triangle.fill", "LifeguardRing", "person.fill"]
    let notReadyIcons = ["clock.arrow.circlepath", "clock.arrow.circlepath", "gift.fill", "person.2.fill", "list.number",
                         "exclamationmark.triangle.fill", "clock.arrow.circlepath", "clock.arrow.circlepath"]
    var icons:[String]!
    
    let readyColors = [UIColor.systemBlue, UIColor.systemBlue, UIColor.systemBlue, UIColor.systemBlue, UIColor.systemBlue,
                                 UIColor.systemRed, nil, UIColor.systemBlue]
    let notReadyColors = [UIColor.systemRed, UIColor.systemRed, UIColor.systemBlue, UIColor.systemBlue, UIColor.systemBlue,
                          UIColor.systemRed, nil, UIColor.systemRed]
    var iconColors: [UIColor?]!
    
    var lifeguards = Lifeguards()                   // creates the lifeguard object
    var boardMembers = Lifeguards(lifeguard: false) // creates the boardMember Object
    var readyLifeguard = false         // indicates if the lifeguards or boardMembers ready to read
    var readyBoard = false
    var boardListFinished = [false]
    var lifeguardListFinished = [false, false, false]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        lifeguards.delegate = self;                 // set delegate
        boardMembers.delegate = self;                 // set delegate
        readLifeguards()                            // read the database
    }

    func readLifeguards() {
        segueIds = notReadySegueIDs                 // set segues to not ready
        icons = notReadyIcons                       // set icons to not ready
        iconColors = notReadyColors                 // set icon colors to not ready
        readyLifeguard = false
        readyBoard = false
        lifeguards.readDB(vc: self)                 // start reading database
        boardMembers.readDB(vc: self)               // start reading database
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.font = UIFont(name:"System", size: 18.0)
        cell.textLabel!.text = list[indexPath.row]
        
        // imageView will come from system icons, unless nil, the image
        if let iconColor = iconColors[indexPath.row] {
            // this is a system icon
            cell.imageView!.image = UIImage(systemName: icons[indexPath.row],
                                            withConfiguration: UIImage.SymbolConfiguration(weight: .regular))?
                .withTintColor(iconColor,
                               renderingMode: .alwaysOriginal)
        } else {
            cell.imageView!.image = UIImage(named: icons[indexPath.row])
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: segueIds[indexPath.row]!, sender: self) // perform the segue pointed to by row
    }


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // one of the checklists
        let row = tableView.indexPathForSelectedRow!.row
        if row == 0 || row == 1 {
            let vc = segue.destination as! CheckListTVC
            if row == 0 {
                lifeguards.activeList = .open   // set active list to open
                vc.title = "Opening Checklist"
            } else {
                lifeguards.activeList = .close // set active list to close
                vc.title = "Closing Checklist"
            }
            vc.lifeguards = lifeguards
        } else if row >= 2 && row <= 5 {
            let vc: UIViewController!
            if row == 2 {
                vc = segue.destination as! PartyTVC
                vc.title = "Parties"
            } else if row == 3 {
                vc = segue.destination as! NannyTVC
                vc.title = "Nanny"
            } else if row == 4 {
                vc = segue.destination as! RulesVC
                vc.title = "Rules"
            } else if row == 5 {
                vc = segue.destination as! EmergVC
                vc.title = "Emergency"
            }
        } else if row == 6 || row == 7 {
            let vc = segue.destination as! WorkerListTVC
            if row == 6 {
                vc.title = "Lifeguards"
                vc.workerList = lifeguards
            } else {
                vc.title = "Board Members"
                vc.workerList = boardMembers
            }
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }

}

// delegate for reading lifeguard roster sheet, refresh tableView when both are ready
// if lifeguard, then bools in array indicate different lists finishing
//
extension ListTVC: UpdateLifeguardsDelegate {
    func didUpdateLifeguard(lifeguard: Bool, finished: [Bool]) {
        if lifeguard {
            // first update the array with which list finished (0, 1 or 2)
            for i in 0..<finished.count {
                if finished[i] {
                    lifeguardListFinished[i] = true
                }
            }
            readyLifeguard = true
            for ready in lifeguardListFinished {
                if !ready {
                    readyLifeguard = false
                }
            }
        } else {
            if finished[0] {
                readyBoard = true
            }
        }
        if readyLifeguard && readyBoard {
            segueIds = readySegueIds    // set segues to ready segues
            icons = readyIcons      // set icon set to readyIcons
            iconColors = readyColors  // set colors to readyColors
            tableView.reloadData()
        }
    }
}
