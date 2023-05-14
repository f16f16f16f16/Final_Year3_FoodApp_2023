//
//  RegisterViewController.swift
//  Final_iOS_Y3_Term2
//
//  Created by Nontaphat Pongpis on 4/4/2566 BE.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    @IBOutlet weak var PasswordTF: UITextField!
    @IBOutlet weak var EmailTF: UITextField!
    @IBOutlet weak var NameTF: UITextField!
    
    @IBOutlet weak var showPasswordButton: UIButton!
    
    var isPasswordHidden = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Set the initial password text field state
        PasswordTF.isSecureTextEntry = isPasswordHidden
        
        // Add a target for the show password button
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
    }
    
    
    @IBAction func RegisterBTN(_ sender: UIButton) {
        guard let name = NameTF.text, !name.isEmpty else {
            showAlert(title: "Error", message: "Please enter your name")
            return
        }
        guard let email = EmailTF.text, !email.isEmpty else {
            showAlert(title: "Error", message: "Please enter your email")
            return
        }
        guard let password = PasswordTF.text, !password.isEmpty else {
            showAlert(title: "Error", message: "Please enter your password")
            return
        }
        
        
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else {
                return
            }
            if let error = error {
                strongSelf.showAlert(title: "Error", message: error.localizedDescription)
                return
            }
            // User is signed in, store the name in the Firestore database
            let db = Firestore.firestore()
            let user = Auth.auth().currentUser
            let userRef = db.collection("users").document(user!.uid)
            
            userRef.setData([
                "name": name
            ]) { err in
                if let err = err {
                    strongSelf.showAlert(title: "Error", message: err.localizedDescription)
                } else {
                    let LoginVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                    self?.navigationController?.setViewControllers([LoginVC], animated: true)
                }
            }
        }
    }
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func showSuccessAlert() {
        let alert = UIAlertController(title: "Success", message: "Your account has been created", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            // Navigate back to the sign-in screen
            self.navigationController?.popViewController(animated: true)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc func togglePasswordVisibility() {
        // Toggle the password text field visibility
        isPasswordHidden.toggle()
        PasswordTF.isSecureTextEntry = isPasswordHidden
        
        // Update the show password button image
        let buttonImage = isPasswordHidden ? UIImage(systemName: "eye.slash.fill") : UIImage(systemName: "eye.fill")
        showPasswordButton.setImage(buttonImage, for: .normal)
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
