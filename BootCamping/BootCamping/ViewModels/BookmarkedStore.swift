//
//  BookmarkedStore.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/01.
//

import Foundation
import FirebaseFirestore

class BookmarkedStore: ObservableObject {
    @Published var bookmarkSpot: [Places] = []
    @Published var myPost: [Places] = []
    
    let database = Firestore.firestore()
    var bookmarkedId: String = ""
    
    func fetchBookmarkSpot(userid: String) {
        database.collection("UserList")
            .document(userid).collection("bookmarkSpot")
            .getDocuments { (snapshot, error) in
                self.bookmarkSpot.removeAll()
                
                if let snapshot {
                    for document in snapshot.documents {
                        let contentId: String = document.documentID
                        

              //          data.append()
             //           self.favoriteid = id
                        
//                        self.favorites.append(post)
//
//                        self.currentFavorites = post
                        
                    }
                }
            }
    }
    
}
