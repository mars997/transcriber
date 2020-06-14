//
//  RecordCell.swift
//  transcriber
//
//  Created by Hamed Ansari on 6/12/20.
//  Copyright © 2020 exoptima. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {

    @IBOutlet weak var titleText: UITextField!
    
    
    @IBOutlet weak var transcribeButton: UIButton!
   
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        titleText.layer.cornerRadius = titleText.frame.height/5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
