//
//  HomeQuestionViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 03/02/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD

class HomeQuestionViewController: UIViewController, StoryboardLoadable {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var questionsCollectionView: UICollectionView!
    @IBOutlet weak var nextButton: MDActionButton!

    var analyticsSessions: [String: Date] = [String: Date]()
    var dataSource: [UserPreference] = [UserPreference]()
    var selectedData: [UserPreference] = Utilities.getUserPreferences()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.loadUserPreferences()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedData = Utilities.getUserPreferences()
        self.questionsCollectionView.reloadData()
    }
    
    fileprivate func setupView() {
        self.nextButton.isEnabled = false
        self.questionsCollectionView.allowsMultipleSelection = true
        self.questionsCollectionView.register(HomeQuestionCollectionViewCell.self)
        let string: NSString = "onboarding_goals_title".localized() as NSString
        self.titleLabel.attributedText = Utilities.attributedTextSplitBy(string, divider: "goals", withSize: 25)
        SVProgressHUD.show()
    }
    
    fileprivate func loadUserPreferences() {
        BackendUtilities.getUserPreferences { (success, preferences) in
            if (success) {
                self.dataSource = preferences
                self.questionsCollectionView.reloadData()
            }
            self.nextButton.isEnabled = true
            SVProgressHUD.dismiss()
        }
    }
    
    fileprivate func savePreferences() {
        Utilities.saveUserPreferences(self.selectedData)
        self.trackSelectedGoals(self.selectedData)
    }

    @IBAction func nextButtonPressed(_ sender: AnyObject) {
        self.savePreferences()
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.kDidFinishWalkthrough), object: self)
    }

    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.savePreferences()
        self.navigationController?.popViewController(animated: true)
    }

}

extension HomeQuestionViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width / 2, height: 106)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let preference = self.dataSource[indexPath.row]
        if (self.selectedData.index(of: preference) == nil) {
            self.selectedData.append(preference)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = self.selectedData.index(of: self.dataSource[indexPath.row]) {
            self.selectedData.remove(at: index)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let preference = self.dataSource[indexPath.row]
        if let _ = self.selectedData.index(of: preference) {
            cell.isSelected = true
            collectionView.selectItem(at: indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
        }
    }

}

extension HomeQuestionViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusable(forIndexPath: indexPath) as HomeQuestionCollectionViewCell
        let preference = self.dataSource[indexPath.row]
        cell.configure(preference)
        
        return cell
    }
    
}

extension HomeQuestionViewController: AnalyticsViewControllerProtocol {
    
    func getAnalyticsProperties() -> [String: Any] {
        return ["type": "user"]
    }
    
    func getAnalyticsScreenName() -> String {
        return "Goals"
    }
    
}
