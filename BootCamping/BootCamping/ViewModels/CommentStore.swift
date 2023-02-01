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
import Combine

class CommentStore: ObservableObject {
    @Published var comments: [Comment] = []
    
    let database = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()

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
                        let uid: String = docData["uid"] as? String ?? ""
                        let nickName: String = docData["nickName"] as? String ?? ""
                        let profileImage: String = docData["profileImage"] as? String ?? ""
                        let commentContent: String = docData["commentContent"] as? String ?? ""
                        let commentCreatedDate: Timestamp = docData["commentCreatedDate"] as? Timestamp ?? Timestamp(date: Date())
                        let commentLike: [String] = docData["commentLike"] as? [String] ?? []
                        
                        let comment: Comment = Comment(id: id, diaryId: diaryId, uid: uid,  nickName: nickName, profileImage: profileImage, commentContent: commentContent, commentCreatedDate: commentCreatedDate, commentLike: commentLike)
                        
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
                      "uid": comment.uid,
                      "nickName": comment.nickName,
                      "profileImage": comment.profileImage,
                      "commentContent": comment.commentContent,
                      "commentCreatedDate": comment.commentCreatedDate,
                      "commentLike": comment.commentLike,
                     ])
        fetchComment()
    }
    
    
    // MARK: 댓글 좋아요 update 함수
    func updateCommentLike(_ comment: Comment) {
        database.collection("Comment")
            .document(comment.id)
            .updateData([
                "commentLike": FieldValue.arrayUnion([comment.uid])
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
    
    //MARK: Read Comment Combine
    
    func getComments() {
        FirebaseCommentService().getCommentsService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get Comments")
                        return
                case .finished:
                    print("Finished get Comments")
                    return
                }
            } receiveValue: { [weak self] commentsValue in
                self?.comments = commentsValue
            }
            .store(in: &cancellables)
    }
    
    //MARK: Create Comment Combine
    
    func createComment(comment: Comment) {
        FirebaseCommentService().createCommentService(comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Create Comment")
                    return
                case .finished:
                    print("Finished Create Comment")
                    self.getComments()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: Update CommentLike Combine
    
    func updateCommentLike(comment: Comment) {
        FirebaseCommentService().updateCommentLikeService(comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Update CommentLike")
                    return
                case .finished:
                    print("Finished Update CommentLike")
                    self.getComments()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }

    //MARK: Delete Comment Combine
    
    func deleteComment(comment: Comment) {
        FirebaseCommentService().deleteCommentService(comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Delete Comment")
                    return
                case .finished:
                    print("Finished Delete Comment")
                    self.getComments()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}
