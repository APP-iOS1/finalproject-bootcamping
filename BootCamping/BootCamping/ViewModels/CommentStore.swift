//
//  CommentStore.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/19.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import FirebaseStorage
import Combine

// MARK: - 댓글 정보를 가지고 있는 스토어

class CommentStore: ObservableObject {
    
    @Published var commentList: [Comment] = []
    
    @Published var firebaseCommentServiceError: FirebaseCommentServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    @Published var currnetCommentInfo: Comment?
    
    let database = Firestore.firestore()
    private var cancellables = Set<AnyCancellable>()
    
    
    //MARK: - Create Comment Combine
    
    func createCommentCombine(diaryId: String, comment: Comment) {
        FirebaseCommentService().createCommentService(diaryId: diaryId, comment: comment)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Create Comment")
                    self.firebaseCommentServiceError = .createCommentError
                    self.showErrorAlertMessage = self.firebaseCommentServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished Create Comment")
                    self.readCommentsCombine(diaryId: diaryId)
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Read Comment Combine
    func readCommentsCombine(diaryId: String) {
        FirebaseCommentService().readCommentsService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get Comments")
                    self.firebaseCommentServiceError = .badSnapshot
                    self.showErrorAlertMessage = self.firebaseCommentServiceError.errorDescription!
                        return
                case .finished:
                    print("Finished get Comments")
                    return
                }
            } receiveValue: { [weak self] commentsValue in
                self?.commentList = commentsValue
            }
            .store(in: &cancellables)
    }

    
    //MARK: - Delete Comment Combine
    
    func deleteCommentCombine(diaryId:String, comment: Comment) {
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
