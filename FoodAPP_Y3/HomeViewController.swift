//
//  HomeViewController.swift
//  FoodAPP_Y3
//
//  Created by โจ๊กจ้าาาา on 6/5/2566 BE.
//

import UIKit
import FirebaseFirestore

class HomeViewController: UIViewController {
    let db = Firestore.firestore()
    var shopData:[FoodItem] = []
    @IBOutlet weak var btn1: UIButton!
    @IBOutlet weak var btn2: UIButton!
    @IBOutlet weak var btn3: UIButton!
    @IBOutlet weak var btn4: UIButton!
    
    func getItem () {
        db.collection("shops").getDocuments { QuerySnapshot, Error in
            if let Error = Error {
                print("Error getting documents: \(Error)")
            } else {
                for document in QuerySnapshot!.documents {
                    let data = document.data()
//                    print(data)
                    if let shopName = data["nameShop"] as? String,
                       let content = data["description"] as? String, let picShop = data["imgSrc"] as? String, let timeOpen = ["time"] as? String {
                        let newItem = FoodItem(id: document.documentID, nameShop: shopName, description: content, imgSrc: picShop, time: timeOpen)
                        
                        self.shopData.append(newItem)
                    }
                }
            }
        }
    }


    
    override func viewDidLoad() {
        super.viewDidLoad()
        getItem()
        print(shopData)
        
        // Do any additional setup after loading the view.
    }
    
    
            
            // Reload the table view to reflect the updated data
//            self.tableView.reloadData()
        }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

