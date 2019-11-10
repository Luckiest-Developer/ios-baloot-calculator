//
//  ScoreCell.swift
//  BalootCalculator
//
//  Created by the Luckiest on 8/1/17.
//  Copyright © 2017 the Luckiest. All rights reserved.
//

import UIKit

class ScoreCell: UITableViewCell {

    @IBOutlet weak var lahmLbl: UILabel!
    @IBOutlet weak var lanaLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(score:Score) {
        lahmLbl.text = "\(score.lahm)"
        lanaLbl.text = "\(score.lana)"
    }
    
}
