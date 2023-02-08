//
//  CommentStore.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/19.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseAnalytics
import Foundation
import SwiftUI
import FirebaseStorage
import Combine

class CommentStore: ObservableObject {
    
    @Published var commentList: [Comment] = []
    @Published var firebaseCommentServiceError: FirebaseCommentServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    @Published var currnetCommentInfo: Comment?
    
    let database = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    
    // MARK: Add Comment
    func addCommentCombine(comment: Comment, diaryId: String) {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        database.collection("Diarys")
            .document(diaryId)
            .collection("Comment")
            .addDocument(data: ["diaryId": comment.diaryId,
                                "uid": comment.uid,
                                "nickName": comment.nickName,
                                "profileImage": comment.profileImage,
                                "commentContent": comment.commentContent,
                                "commentCreatedDate": comment.commentCreatedDate
                               ])
        readCommentsCombine(diaryId: diaryId)
    }
    // MARK: fetch Comment
    func readCommentsCombine(diaryId: String)  {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        
        database.collection("Diarys")
            .document(diaryId)
            .collection("Comment")
            .getDocuments { (snapshot, error) in
                self.commentList.removeAll()
                if let snapshot {
                    for document in snapshot.documents {
                        
                        let id: String = document.documentID
                        
                        let docData = document.data()
                        
                        let diaryId: String = docData["diaryId"] as? String ?? ""
                        let uid: String = docData["uid"] as? String ?? ""
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let commentContent: String = docData["commentContent"] as? String ?? ""
                        let commentCreatedDate: Timestamp = docData["commentCreatedDate"] as? Timestamp ?? Timestamp(date: Date())
                        
                        let comment: Comment = Comment(id: id, diaryId: diaryId, uid: uid,  nickName: nickName, profileImage: profileImage, commentContent: commentContent, commentCreatedDate: commentCreatedDate)
                        
                        self.commentList.append(comment)
                    }
                }
            }
    }
    
    //MARK: Delete Comment Combine
    
    func deleteCommentCombine(comment: Comment, diaryId: String) {
        FirebaseCommentService().deleteCommentService(diaryId: diaryId, comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Delete Comment")
                    self.firebaseCommentServiceError = .deleteCommentError
                    self.showErrorAlertMessage = self.firebaseCommentServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished Delete Comment")
                    self.readCommentsCombine(diaryId: diaryId)
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}
