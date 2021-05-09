//
//  DirTVCell.swift
//  Lifeguard
//
//  Created by jim kardach on 5/5/21.
//  Copyright © 2021 Forkbeardlabs. All rights reserved.
//

import UIKit

class DirTVCell: UITableViewCell {


    @IBOutlet var icon: UIImageView!
    @IBOutlet var name: UILabel!
    @IBOutlet var title: UILabel!
    @IBOutlet var smsButton: UIButton!
    @IBOutlet var emailButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
