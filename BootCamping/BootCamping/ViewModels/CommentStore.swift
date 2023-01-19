//
//  CommentStore.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/19.
//

import Foundation
import FirebaseFirestore
import Firebase
import SwiftUI

class CommentStore: ObservableObject {
    @Published var comments: [Comment] = []
    
    let database = Firestore.firestore()
    
    init(){
        comments = []
    }
    
    // MARK: fetch 함수
    func fetchComment()  {
        database.collection("Comment")
            .order(by: "commentCreatedDate", descending: false)
            .getDocuments { (snapshot, error) in
                self.comments.removeAll()
                if let snapshot {
                    for document in snapshot.documents {
                        let id: String = document.documentID
                        
                        let docData = document.data()
                        
                        let diaryId: String = docData["diaryId"] as? String ?? ""
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let commentContent: String = docData["commentContent"] as? String ?? ""
                        let commentCreatedDate: Timestamp = docData["commentCreatedDate"] as? Timestamp ?? Timestamp(date: Date())
                        let commentLike: [String] = docData["commentLike"] as? [String] ?? []
                        
                        let comment: Comment = Comment(id: id, diaryId: diaryId, nickName: nickName, profileImage: profileImage, commentContent: commentContent, commentCreatedDate: commentCreatedDate, commentLike: commentLike)
                        
                        self.comments.append(comment)
                        
                    }
                }
            }
    }
    
    // MARK: 댓글 Add 함수
    func addComment(_ comment: Comment) {
        database.collection("Comment")
            .document(comment.id)
            .setData(["diaryId": comment.diaryId,
                      "nickName": comment.nickName,
                      "profileImage": comment.profileImage,
                      "commentContent": comment.commentContent,
                      "commentCreatedDate": comment.commentCreatedDate,
//                      "commentLike": comment.commentLike,
                     ])
        fetchComment()
    }
    
    
    // MARK: 댓글 좋아요 Add 함수
    func addCommentLike(_ comment: Comment) {
        database.collection("Comment")
            .document(comment.id)
            .setData([
                      "commentLike": comment.commentLike,
                     ])
        fetchComment()
    }
    
    
    // MARK: Remove 함수
    func removeComment(_ comment: Comment)  async throws {
        do {
            
            try await database.collection("Comment")
                .document(comment.id).delete()
             fetchComment()
        }
        catch {
            print(error)
        }
    }
    
}
