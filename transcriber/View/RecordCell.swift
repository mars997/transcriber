//
//  RecordCell.swift
//  transcriber
//
//  Created by Hamed Ansari on 6/12/20.
//  Copyright © 2020 exoptima. All rights reserved.
//

import UIKit

protocol RecordCellDelegate {
    func playButtonPressed(id: Int, sender: Any)
    func transcribeButtonPressed(id: Int, sender: Any)
    func titleFieldChanged(id: Int, sender: Any)
}

class RecordCell: UITableViewCell {
    
    
    var cellDelegate: RecordCellDelegate?
    //    var id: Int?
    
    static var recorderModel = RecorderModel()
    
    @IBOutlet weak var titleText: UITextField!
    @IBOutlet weak var transcribeButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    @IBAction func playPressed(_ sender: Any) {
        cellDelegate?.playButtonPressed(id: (sender as AnyObject).tag, sender: sender)
    }
    
    @IBAction func transcribePressed(_ sender: Any) {
        cellDelegate?.transcribeButtonPressed(id: (sender as AnyObject).tag, sender: sender)
    }
    
    @IBAction func titleChanged(_ sender: Any) {
        
        cellDelegate?.titleFieldChanged(id: (sender as AnyObject).tag, sender: sender)
        
    }
    
    
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
