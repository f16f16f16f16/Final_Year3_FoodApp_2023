//
//  UserInfoViewController.swift
//  IOS_FOOD_Y3
//
//  Created by Nontaphat Pongpis on 14/4/2566 BE.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class UserInfoViewController: UIViewController {
    
    @IBOutlet var NameBTN: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add authentication state change listener
        Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
            if user == nil {
                // User is signed out, navigate to login screen or perform any other necessary action
                print("User is signed out")
            } else {
                // Retrieve the current user's UID
                guard let uid = user?.uid else { return }
                
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
                    
                    // Update the NameBTN with the retrieved name
                    DispatchQueue.main.async {
                        if let nameButton = self?.NameBTN as? UIButton {
                            let attributedString = NSMutableAttributedString(string: name)
                            attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 22), range: NSRange(location: 0, length: name.count))
                            nameButton.setAttributedTitle(attributedString, for: .normal)
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func NameBTN(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Change Name", message: "Enter a new name", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "New Name"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] (_) in
            if let newName = alertController.textFields?[0].text {
                // Update the user's name in Firestore
                let db = Firestore.firestore()
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let userRef = db.collection("users").document(uid)
                userRef.updateData([
                    "name": newName
                ]) { (error) in
                    if let error = error {
                        print("Error updating user name: \(error.localizedDescription)")
                    } else {
                        print("User name updated successfully")
                        // Update the NameBTN with the new name
                        DispatchQueue.main.async {
                            if let nameButton = self?.NameBTN as? UIButton {
                                let attributedString = NSMutableAttributedString(string: newName)
                                attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 22), range: NSRange(location: 0, length: newName.count))
                                nameButton.setAttributedTitle(attributedString, for: .normal)
                            }
                        }
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func ChangePic(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()
           imagePicker.delegate = self
           imagePicker.allowsEditing = true
           imagePicker.sourceType = .photoLibrary
           
           present(imagePicker, animated: true, completion: nil)
    }
    
    
    
    @IBAction func DeleteAccountBTN(_ sender: UIButton) {
        // Get a reference to the current user's document in Firestore
        let currentUserDocRef = Firestore.firestore().collection("users").document(Auth.auth().currentUser!.uid)
        
        // Delete the document from Firestore
        currentUserDocRef.delete() { error in
            if let error = error {
                // An error occurred while deleting the document
                print("Error deleting document: \(error.localizedDescription)")
            } else {
                // Document deleted successfully
                print("Document deleted successfully.")
            }
            
            // Delete the user's account from Firebase Auth
            Auth.auth().currentUser?.delete() { error in
                if let error = error {
                    // An error occurred while deleting the user's account
                    print("Error deleting account: \(error.localizedDescription)")
                } else {
                    // Account deleted successfully
                    print("Account deleted successfully.")
                    
                    // Set the "isLoggedIn" flag to false
                    UserDefaults.standard.set(false, forKey: "isLoggedIn")
                    
                    // Return to the login screen
                    let loginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginViewController")
                    self.navigationController?.setViewControllers([loginViewController], animated: true)
                }
            }
        }
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


extension UserInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.editedImage] as? UIImage {
            let storageRef = Storage.storage().reference()
            let profilePicRef = storageRef.child("profilePics/\(Auth.auth().currentUser!.uid).jpg")
            
            if let uploadData = pickedImage.jpegData(compressionQuality: 0.5) {
                profilePicRef.putData(uploadData, metadata: nil) { (metadata, error) in
                    if let error = error {
                        print("Error uploading profile picture: \(error.localizedDescription)")
                        return
                    }
                    
                    // Update the user's document with the new profile picture URL
                    profilePicRef.downloadURL { (url, error) in
                        if let error = error {
                            print("Error getting profile picture download URL: \(error.localizedDescription)")
                            return
                        }
                        
                        guard let url = url else {
                            print("Profile picture URL is nil")
                            return
                        }
                        
                        let db = Firestore.firestore()
                        let userRef = db.collection("users").document(Auth.auth().currentUser!.uid)
                        userRef.updateData(["profilePicUrl": url.absoluteString]) { (error) in
                            if let error = error {
                                print("Error updating profile picture URL in Firestore: \(error.localizedDescription)")
                                return
                            }
                            
                            print("Profile picture updated successfully")
                        }
                    }
                }
            }
        }
        
        dismiss(animated: true, completion: nil)
    }
}
