//
//  MenuRoundedOptionTableViewCell.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

class MenuRoundedOptionTableViewCell : UITableViewCell {
    
    @IBOutlet weak var roundedBackgroundView: UIView!
    @IBOutlet weak var optionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = UIColor.clear
        self.roundedBackgroundView.backgroundColor = UIColor.clear
        self.roundedBackgroundView.layer.borderColor = UIColor.menudBlueColor().cgColor
        self.roundedBackgroundView.layer.borderWidth = 1
        self.roundedBackgroundView.layer.cornerRadius = 8
        self.roundedBackgroundView.clipsToBounds = false
    }    
}
