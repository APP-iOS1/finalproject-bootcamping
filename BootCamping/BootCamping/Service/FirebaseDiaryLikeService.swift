//
//  DiaryLikeService.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/08.
//


import Combine
import Firebase

enum FirebaseDiaryLikeServiceError: Error {
    case badSnapshot
    case addDiaryLikeError
    case removeDiaryLikeError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "좋아요한 다이어리 가져오기 실패"
        case .addDiaryLikeError:
            return "다이어리 좋아요 추가 실패"
        case .removeDiaryLikeError:
            return "다이어리 좋아요 삭제 실패"
        }
    }
}


struct FirebaseDiaryLikeService {
    let database = Firestore.firestore()
    
    //MARK: - Read diaryLikeService
    func readDiaryLikeService(diaryId: String) -> AnyPublisher<[String], Error> {
        Future<[String], Error> { promise in
            database.collection("Diarys")
                .document(diaryId)
                .getDocument { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseDiaryLikeServiceError.badSnapshot))
                        return
                    }
                    
                    guard let docData = snapshot.data() else { return }
                    //document 가져오기
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    var diaryLikes = diaryLike

                    promise(.success(diaryLikes))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Add diaryLikeService
    func addDiaryLikeService(diaryId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("Diarys")
                .document(diaryId)
                .updateData([
                    "diaryLike" : FieldValue.arrayUnion([uid])
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryLikeServiceError.addDiaryLikeError))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Remove BookmarkDiaryService
    func removeDiaryLikeService(diaryId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let uid = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("Diarys")
                .document(diaryId)
                .updateData([
                    "diaryLike" : FieldValue.arrayRemove([uid])
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryLikeServiceError.removeDiaryLikeError))
                    } else {
                        promise(.success(()))
                    }
                }
            
        }
        .eraseToAnyPublisher()
    }
    
}
