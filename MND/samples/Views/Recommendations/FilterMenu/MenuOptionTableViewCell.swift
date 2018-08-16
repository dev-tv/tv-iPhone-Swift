//
//  MenuOptionTableViewCell.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

class MenuOptionTableViewCell : UITableViewCell {
    
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkboxImageView: UIImageView!
    var hasSelected: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.hasSelected = false
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if (selected) {
            checkboxImageView.image = UIImage.init(named: "menuOptionCheckboxMarked")
        } else {
            checkboxImageView.image = UIImage.init(named: "menuOptionCheckbox")
        }
    }
}
