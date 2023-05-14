//
//  ForgotPasswordViewController.swift
//  Final_iOS_Y3_Term2
//
//  Created by Nontaphat Pongpis on 5/4/2566 BE.
//

import UIKit
import FirebaseAuth

class ForgotPasswordViewController: UIViewController {
    
    @IBOutlet weak var EmailTF: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func ResetPass(_ sender: UIButton) {
        guard let email = EmailTF.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }
        // Send reset password email using Firebase Auth
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            // Password reset email sent successfully
            strongSelf.showAlert(title: "Password Reset", message: "A password reset email has been sent to your email address")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
