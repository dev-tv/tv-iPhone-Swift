//
//  LoginViewController.swift
//  Menud
//
//  Created by Guilherme Hayashi on 20/03/2017.
//  Copyright © 2017 Macbook Pro. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController, StoryboardLoadable {
    
    @IBOutlet weak var signInView: UIView!
    @IBOutlet weak var createAccountView: UIView!

    @IBOutlet weak var signErrorMessageLabel: UILabel!
    @IBOutlet weak var signErrorView: UIView!
    @IBOutlet weak var signEmailTextField: UITextField!
    @IBOutlet weak var signPasswordTextField: UITextField!
    @IBOutlet weak var signPasswordProceedView: UIButton!


    @IBOutlet weak var createErrorMessageLabel: UILabel!
    @IBOutlet weak var createErrorView: UIView!
    @IBOutlet weak var createEmailTextField: UITextField!
    @IBOutlet weak var createPasswordTextField: UITextField!
    @IBOutlet weak var createPasswordConfirmTextField: UITextField!
    @IBOutlet weak var createPasswordProceedView: UIButton!
    
    var typingTimer: Timer?
    var analyticsSessions: [String: Date] = [String: Date]()
    var goToSignInGesture: UIGestureRecognizer!
    var hasAccount: Bool = false
    var shouldDismissController = true
    let disabledButtonColor:UIColor = UIColor(red: 162/255, green: 206/255, blue: 227/255, alpha: 1)

    var creatNewUser:Bool = false
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.startTracking()
        NotificationCenter.default.addObserver(self, selector: #selector(userHasLoggedIn), name: NSNotification.Name(rawValue: Constant.kUserHasLoggedIn), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.endTracking()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.goToSignInGesture = UITapGestureRecognizer(target: self, action: #selector(self.showSignIn))
        self.showSignScreen()
        self.signPasswordTextField.delegate = self
        self.createPasswordConfirmTextField.delegate = self
        self.createPasswordTextField.delegate = self
        self.createEmailTextField.delegate = self
        self.signEmailTextField.delegate = self
        configureUI()
    }
    
    
    fileprivate func showSignScreen() {
        self.typingTimer?.invalidate()
        self.typingTimer = nil
        self.signPasswordTextField.text = ""
        self.signPasswordProceedView.isHidden = false
        self.createPasswordTextField.text = ""
        self.createPasswordConfirmTextField.text = ""
        self.createPasswordProceedView.isHidden = false
        self.signInView.isHidden = !self.hasAccount
        self.createAccountView.isHidden = self.hasAccount
        self.createErrorView.isHidden = true


    }
    
    fileprivate func setProceedView() {
        if let pw = self.signPasswordTextField.text as String?, pw != "" && !self.signInView.isHidden {
            self.signPasswordProceedView.isEnabled = true
        } else {
            self.signPasswordProceedView.isEnabled = false
        }
        if let pw = self.createPasswordTextField.text as String?, pw != "" && !self.createAccountView.isHidden {
            if let cpw = self.createPasswordConfirmTextField.text as String?, pw != cpw {
                 self.createPasswordProceedView.isEnabled = false
            }
            else{
                 self.createPasswordProceedView.isEnabled = true
            }
           
        } else {
            self.createPasswordProceedView.isEnabled = false
        }
    }
    
    @objc func setProceed(_ timer: Timer) {
        self.setProceedView()
    }
    
    func setLoadingState(isLoading: Bool) {
        if (isLoading) {
            self.signErrorView.isHidden = true
            self.signErrorMessageLabel.text = ""
            self.signPasswordProceedView.setTitle("sign_loading".localized(), for: .normal)
            self.signPasswordProceedView.isEnabled = false
            self.createErrorView.isHidden = true
            self.createErrorMessageLabel.text = ""
            self.createPasswordProceedView.setTitle("create_loading".localized(), for: .normal)
            self.createPasswordProceedView.isEnabled = false
        } else {
            self.signPasswordProceedView.setTitle("sign_in_text".localized(), for: .normal)
            self.signPasswordProceedView.isEnabled = true
            self.createPasswordProceedView.setTitle("sign_up_text".localized(), for: .normal)
            self.createPasswordProceedView.isEnabled = true
        }
    }
    
    @objc func showSignIn() {
        self.hasAccount = true
        self.shouldDismissController = false
        self.signEmailTextField.text = self.createEmailTextField.text
        self.showSignScreen()
    }
    
    @IBAction func alreadyHaveAccountAction(_ sender: Any) {
        self.showSignIn()
    }
   
    
    
    func setError(message: NSAttributedString) {
        if (self.hasAccount) {
            self.signErrorView.isHidden = false
            self.signErrorMessageLabel.attributedText = message
        } else {
            self.createErrorView.isHidden = false
            self.createErrorMessageLabel.attributedText = message
            if (message.string.contains("please_sign_in_text".localized())) {
                self.createErrorView.addGestureRecognizer(self.goToSignInGesture)
            } else {
                self.createErrorView.removeGestureRecognizer(self.goToSignInGesture)
            }
        }
    }
    
    func signUpWithCreds() {
        let email = self.createEmailTextField.text!
        let password = self.createPasswordTextField.text!
       
        self.setLoadingState(isLoading: true)
        BackendUtilities.signUp(email, username: email, password: password) { (success, accessToken, profile, error) in
            if let accessToken = accessToken, let profile = profile {
                let userId = accessToken["userId"] as! NSNumber
                let token = accessToken["id"] as! String
                let profileId = profile["id"] as! NSNumber
                self.trackSignUp(userId)
                AppStorage.shared.createNewUser(userId, username: email, accessToken: token, profileId: profileId)
            } else {
                if let errorMessage = try! error?.parseLoginError() as NSAttributedString? {
                    self.setError(message: errorMessage)
                }
                self.trackLoginError(error)
            }
            self.setLoadingState(isLoading: false)
        }
    }
    
    func signInWithCreds() {
        let email = self.signEmailTextField.text!
        let password = self.signPasswordTextField.text!
        self.setLoadingState(isLoading: true)
        BackendUtilities.signIn(email, password: password) { (success, accessToken, profile, error) in
            if  let accessToken = accessToken, let profile = profile, let token = accessToken["id"] as? String {
                let user = User(accessToken: token,  profileJson: profile, email:email)
                self.trackSignIn(user.uid!)
                AppStorage.shared.setCurrentUser(user)
                AppStorage.shared.updateToken(accessToken: token)
            } else {
                if let errorMessage = try! error?.parseLoginError() as NSAttributedString? {
                    self.setError(message: errorMessage)
                }
                self.trackLoginError(error)
            }
            self.setLoadingState(isLoading: false)
        }
    }
    
  
    
    @objc func userHasLoggedIn() {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.post(name: Notification.Name(rawValue: Constant.kDidFinishWalkthrough), object: self)
    }
    
    @IBAction func goBack(_ sender: Any) {
        if (self.shouldDismissController) {
            if creatNewUser {
                self.dismiss(animated: true , completion: nil)
            }else {
                self.navigationController?.popViewController(animated: true)
            }
        } else {
            self.shouldDismissController = !self.shouldDismissController
            self.hasAccount = !self.hasAccount
            self.showSignScreen()
        }
    }

    @IBAction func createProceedClicked(_ sender: AnyObject) {
        self.signUpWithCreds()
    }

    @IBAction func signProceedClicked(_ sender: AnyObject) {
        self.signInWithCreds()
    }

    @IBAction func forgotPasswordAction(_ sender: Any) {
        let ForgotPasswordViewController = UIStoryboard.loadInitialViewController() as ForgotPasswordViewController
        self.navigationController?.pushViewController(ForgotPasswordViewController, animated: true)
    }
    
    @IBAction func newToMenudAction(_ sender: Any) {
        if (self.shouldDismissController) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.shouldDismissController = !self.shouldDismissController
            self.hasAccount = !self.hasAccount
            self.showSignScreen()
        }
        
    }
    
    
    func configureUI() {
        self.createAccountView.backgroundColor = UIColor(patternImage: UIImage(named: "login-background")!)
        self.signInView.backgroundColor = UIColor(patternImage: UIImage(named: "login-background")!)

        showGrayBorder(self.createEmailTextField)
        self.createEmailTextField.autocorrectionType = .no

        showGrayBorder(self.signEmailTextField)
        self.signEmailTextField.autocorrectionType = .no

        showGrayBorder(self.createPasswordTextField)
        showGrayBorder(self.signPasswordTextField)
        showGrayBorder(self.createPasswordConfirmTextField)
        
        configureButtons()
    }
    
    func configureButtons() {
        self.createPasswordProceedView.setBackgroundColor(color: disabledButtonColor, forUIControlState: .disabled)
        self.createPasswordProceedView.layer.cornerRadius = 3
        self.createPasswordProceedView.isEnabled = false
        self.createPasswordProceedView.clipsToBounds = true
        
        self.createErrorView.layer.cornerRadius = 4
        self.signErrorView.layer.cornerRadius = 4
        
        self.signPasswordProceedView.setBackgroundColor(color: disabledButtonColor, forUIControlState: .disabled)
        self.signPasswordProceedView.layer.cornerRadius = 3
        self.signPasswordProceedView.isEnabled = false
        self.signPasswordProceedView.clipsToBounds = true
    }
}

extension LoginViewController: UITextFieldDelegate {
    
    func showEditing(_ textField: UITextField){
        textField.layer.borderColor = UIColor.oldMenudBlueColor().cgColor
        textField.layer.borderWidth = 2
        textField.layer.cornerRadius = 3
    }
    
    func showGrayBorder(_ textField: UITextField) {
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 3
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        self.typingTimer?.invalidate()
        self.typingTimer = nil
        self.typingTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(setProceed(_:)), userInfo: nil, repeats: false)

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
       
        if (textField == self.signPasswordTextField) {
            showGrayBorder(signEmailTextField)
        }
        else if (textField == self.createPasswordTextField) {
            showGrayBorder(createEmailTextField)
            showGrayBorder(createPasswordConfirmTextField)
        }
        else if (textField == self.createPasswordConfirmTextField) {
            showGrayBorder(createEmailTextField)
            showGrayBorder(createPasswordTextField)
            
        }
        
         showEditing(textField)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        showGrayBorder(textField)
        self.setProceedView()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let username = self.signEmailTextField.text, username != "" && textField == self.signPasswordTextField {
            self.signInWithCreds()
        }
        if let username = self.createEmailTextField.text, username != "" && textField == self.createPasswordTextField {
            
            self.signUpWithCreds()
        }

        textField.resignFirstResponder()
        return true
    }
}

extension LoginViewController: AnalyticsViewControllerProtocol {
    
    func getAnalyticsProperties() -> [String: Any] {
        return ["type": "user"]
    }
    
    func getAnalyticsScreenName() -> String {
        return "Login"
    }
    
}
