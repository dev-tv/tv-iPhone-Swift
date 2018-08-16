//
//  MenuOptionButtonsTableViewCell.swift
//  Menud
//
//  Created by Guilherme Hayashi on 24/10/2016.
//  Copyright © 2016 Macbook Pro. All rights reserved.
//

protocol MenuOptionsButtonsTableViewDelegate {
    func didClickButtonAtIndex(_ section: Int, index: Int, isSame: Bool)
}

class MenuOptionButtonsTableViewCell : UITableViewCell {
    
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var button3: UIButton!
    var lastSelectedIndex: Int = -1
    var isButtonSelected: Bool = false
    var inSection: Int?
    var buttonsArray: [UIButton]?
    var buttonsDelegate: MenuOptionsButtonsTableViewDelegate?
    var menuDelegate: MainMenuViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.buttonsArray = [self.button1, self.button2, self.button3]
        for button in self.buttonsArray! {
            button.layer.borderColor = UIColor.menudBlueColor().cgColor
            button.layer.borderWidth = 1
            button.layer.cornerRadius = 8
            button.titleLabel?.lineBreakMode = .byWordWrapping;
            button.titleLabel?.textAlignment = .center;
            button.addTarget(self, action: #selector(buttonClicked(_:)), for: UIControlEvents.touchUpInside)
            self.setupNormalState(button)
        }
    }
    
    @objc func buttonClicked(_ sender: UIButton) {
        let index = self.buttonsArray?.index(of: sender) ?? 0
        self.deselectAllButtons()
        var isSame = false
        if (index != self.lastSelectedIndex || !self.isButtonSelected) {
            self.setupHighlightState(sender)
        } else if (self.isButtonSelected) {
            isSame = true
            self.setupNormalState(sender)
        }
        self.lastSelectedIndex = index
        self.isButtonSelected = !self.isButtonSelected
        self.buttonsDelegate?.didClickButtonAtIndex(self.inSection!, index: index, isSame: isSame)
    }
    
    func setupNormalState(_ button: UIButton) {
        button.backgroundColor = UIColor.white
        button.setTitleColor(UIColor.menudBlueColor(), for: UIControlState())
    }
    
    func setupHighlightState(_ button: UIButton) {
        button.backgroundColor = UIColor.menudBlueColor()
        button.setTitleColor(UIColor.white, for: UIControlState())
    }
    
    func setupButtonLabels(_ labels: NSArray) {
        if (self.buttonsArray!.count == labels.count) {
            for i in 0..<self.buttonsArray!.count {
                self.buttonsArray![i].setTitle(labels[i] as? String, for: UIControlState())
            }
        }
    }
    
    func deselectAllButtons() {
        for i in 0..<self.buttonsArray!.count {
            self.setupNormalState(self.buttonsArray![i])
        }
    }

    func setSelectedButton(_ index: Int) {
        self.setupHighlightState(self.buttonsArray![index])
    }

}
