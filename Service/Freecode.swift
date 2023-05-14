//public func getData() {
//    db.collection("shops").getDocuments() { (querySnapshot, err) in
//        if let err = err {
//            print("Error getting documents: \(err)")
//        } else {
//            for document in querySnapshot!.documents {
//                let data = document.data()
//                if let nameShop = data["nameShop"] as? String, let description = data["description"] as? String, let imgSrc = data["imgSrc"] as? String, let time = data["time"] as? String {
//                    HomeViewController.shopData.append(nameShop)
//                }
//            }
//        }
//    }
//}
