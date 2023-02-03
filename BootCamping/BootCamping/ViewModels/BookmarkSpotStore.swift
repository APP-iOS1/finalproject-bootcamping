//
//  BookmarkSpotStore.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/01.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import FirebaseStorage
import Combine

class BookmarkSpotStore: ObservableObject {
    
    @Published var bookmarkSpot: [BookmarkSpot] = []
    @Published var item: [Item] = []

    
    let database = Firestore.firestore()
    var bookmarkId: String = ""
    

    // MARK: Fetch Bookmark
    func fetchBookmarkSpot() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        database.collection("UserList")
            .document(userUID).collection("BookmarkSpot")
            .getDocuments { (snapshot, error) in
                self.bookmarkSpot.removeAll()
                
                if let snapshot {
                    for document in snapshot.documents {
                        let docData = document.data()
                        let id: String = docData["id"] as? String ?? ""
                        let campingSpot: String = docData["campingSpot"] as? String ?? ""
                        let item: BookmarkSpot = BookmarkSpot(id: id, campingSpot: campingSpot)
                        
                        self.bookmarkSpot.append(item)
 
                    }
                }
            }
    }
    
    
    // MARK: Add Bookmark
    func addBookmark(_ item: Item) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        database.collection("UserList")
            .document(userUID).collection("BookmarkSpot")
            .addDocument(data: ["id": item.contentId,
                      "campingSpot": item.facltNm // 임시
                     ])
        
        fetchBookmarkSpot()
    }
    
    
    // MARK: Remove Bookmark
    func removeBookmark(_ item: Item) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        database.collection("UserList")
            .document(userUID).collection("BookmarkSpot")
            .document(userUID).delete()
        fetchBookmarkSpot()
    }

}
