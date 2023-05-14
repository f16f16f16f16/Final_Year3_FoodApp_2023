//
//  UserViewController.swift
//  IOS_FOOD_Y3
//
//  Created by Nontaphat Pongpis on 5/4/2566 BE.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MessageUI
import FirebaseStorage


class UserViewController: UIViewController {
    
    @IBOutlet weak var UserPic: UIImageView!
    
    @IBOutlet weak var NameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        // Retrieve the current user's UID
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        // Set up a listener to retrieve the user document from Firestore
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(uid)
        
        userRef.addSnapshotListener { documentSnapshot, error in
            guard let document = documentSnapshot else {
                print("Error retrieving user document: \(error!)")
                return
            }
            
            guard let name = document.get("name") as? String else {
                print("Document does not contain a name field")
                return
            }
            
            guard let profilePicUrlString = document.get("profilePicUrl") as? String else {
                print("Document does not contain a profilePicUrl field")
                return
            }
            guard let profilePicUrl = URL(string: profilePicUrlString) else {
                print("Invalid profilePicUrl: \(profilePicUrlString)")
                return
            }
            
            // Update the NameLabel with the retrieved name
            DispatchQueue.main.async {
                self.NameLabel.text = name
            }
            
            // Download the user's profile picture from Firebase Storage
              let storageRef = Storage.storage().reference(forURL: profilePicUrl.absoluteString)
              storageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                  if let error = error {
                      print("Error downloading profile picture: \(error.localizedDescription)")
                      return
                  }
                  
                  guard let data = data else {
                      print("Profile picture data is nil")
                      return
                  }
                  
                  // Update the UserPic with the downloaded image
                  DispatchQueue.main.async {
                      self.UserPic.image = UIImage(data: data)
                  }
              }
        }
    }
    
    
    
    @IBAction func SendMailToDEV(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = self
            mailComposer.setToRecipients(["coding.swu.fj@gmail.com"])
            mailComposer.setSubject("Subject")
            mailComposer.setMessageBody("Message body", isHTML: false)
            present(mailComposer, animated: true, completion: nil)
        } else {
            print("Mail services are not available")
        }
    }
    
    @IBAction func LogoutBTN(_ sender: UIButton) {
        do {
            // Sign out the user
            try Auth.auth().signOut()
            
            // Reset the login state in UserDefaults
            UserDefaults.standard.set(false, forKey: "isLoggedIn")
            
            // Replace this view controller with the login view controller
            let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
            navigationController?.setViewControllers([loginViewController], animated: true)
        } catch {
            // Show an error message if sign out fails
            showAlert(title: "Error", message: error.localizedDescription)
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

extension UserViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
