

import UIKit

public protocol showPickerViewDelegate: class {
     func openPickerForMonthYear()
}

protocol MonthViewDelegate: class {
    func didChangeMonth(monthIndex: Int, year: Int)
   
}

class MonthView: UIView {
     var monthsArr = ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    var currentMonthIndex = 0
    var currentYear: Int = 0
    var delegate: MonthViewDelegate?
    var pickerDelgate : showPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor=UIColor.clear
        setupViews()
        
       
    }
    
     func changeMonthAction(sender: Int) {
        if sender == 1 {
            currentMonthIndex += 1
            if currentMonthIndex > 11 {
                currentMonthIndex = 0
                currentYear += 1
            }
        } else {
            currentMonthIndex -= 1
            if currentMonthIndex < 0 {
                currentMonthIndex = 11
                currentYear -= 1
            }
        }
        let someTxt="\(monthsArr[currentMonthIndex]) \(currentYear)"
        lblName.text = String(someTxt).capitalized
        delegate?.didChangeMonth(monthIndex: currentMonthIndex, year: currentYear)
    }
    
    func setupViews() {
        self.addSubview(lblName)
        lblName.topAnchor.constraint(equalTo: topAnchor).isActive=true
        lblName.centerXAnchor.constraint(equalTo: centerXAnchor).isActive=true
        lblName.widthAnchor.constraint(equalToConstant: 200).isActive=true
        lblName.heightAnchor.constraint(equalTo: heightAnchor).isActive=true
        let someTxt="\(monthsArr[currentMonthIndex]) \(currentYear)"
        lblName.text = String(someTxt).capitalized
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        lblName.isUserInteractionEnabled = true
        lblName.addGestureRecognizer(gestureRecognizer)
        if UIDevice.current.modelName == "iPhone 5" {
          lblName.font = lblName.font.withSize(20)
        }else{
          lblName.font = lblName.font.withSize(25)
        }
        
    }
    
    let lblName: UILabel = {
        let lbl=UILabel()
        lbl.text="Default Month Year text"
        lbl.textColor = UIColor(red: 35/255, green: 81/255, blue: 152/255, alpha: 1.0)
        lbl.textAlignment = .center
        lbl.font=UIFont.boldSystemFont(ofSize: 25.0)
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
   
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func tapAction(_ sender: UITapGestureRecognizer) -> Void {
        print("get action")
        self.pickerDelgate?.openPickerForMonthYear()
        
    }
}

