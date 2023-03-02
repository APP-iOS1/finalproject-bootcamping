//
//  FirebaseCommentService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/01.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseAuth
import Firebase

//MARK: - 댓글 서비스 에러 처리
enum FirebaseCommentServiceError: Error {
    case badSnapshot
    case createCommentError
    case updateCommentError
    case deleteCommentError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "댓글 가져오기 실패"
        case .createCommentError:
            return "댓글 작성 실패"
        case .updateCommentError:
            return "좋아요 실패"
        case .deleteCommentError:
            return "댓글 삭제 실패"
        }
    }
}

//MARK: - 댓글 서비스 CRUD 구현

struct FirebaseCommentService {
    
    let database = Firestore.firestore()
    
    //MARK: - Read FirebaseCommentService
    func readCommentsService(diaryId: String) -> AnyPublisher<[Comment], Error> {
        Future<[Comment], Error> { promise in
            database.collection("Diarys")
                .document(diaryId)
                .collection("Comment")
                .order(by: "commentCreatedDate", descending: false)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseCommentServiceError.badSnapshot))
                        return
                    }
                    
                    var comments = [Comment]()
                    
                    //comments 가져오기
                    comments = snapshot.documents.map { d in
                        return Comment(id: d.documentID,
                                       diaryId: d["diaryId"] as? String ?? "",
                                       uid: d["uid"] as? String ?? "",
                                       nickName: d["nickName"] as? String ?? "",
                                       profileImage: d["profileImage"] as? String ?? "",
                                       commentContent: d["commentContent"] as? String ?? "",
                                       commentCreatedDate: d["commentCreatedDate"] as? Timestamp ?? Timestamp()
//                                       ,commentLike: d["commentLike"] as? [String] ?? []
                                       
                        )}
                    promise(.success(comments))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Create FirebaseCommentService
    func createCommentService(diaryId: String, comment: Comment) -> AnyPublisher<Void, Error> {
       
        Future<Void, Error> { promise in

            self.database.collection("Diarys")
                .document(diaryId)
                .collection("Comment").document(comment.id).setData([
                "diaryId": comment.diaryId,
                "uid": comment.uid,
                "nickName": comment.nickName,
                "profileImage": comment.profileImage,
                "commentContent": comment.commentContent,
                "commentCreatedDate": comment.commentCreatedDate,
//                "commentLike": comment.commentLike,
            ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseCommentServiceError.createCommentError))

                    } else {
                        promise(.success(()))
                    }
                    
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Delete FirebaseCommentService
    func deleteCommentService(diaryId: String, comment: Comment) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.database.collection("Diarys")
                .document(diaryId)
                .collection("Comment").document(comment.id).delete()
            { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseCommentServiceError.deleteCommentError))
                } else {
                    promise(.success(()))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
}
