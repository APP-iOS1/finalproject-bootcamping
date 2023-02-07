//
//  FirebaseBookmarkService.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/03.
//

import Combine
import Firebase

enum FirebaseBookmarkDiaryServiceError: Error {
    case badSnapshot
    case addBookmarkDiaryError
    case removeBookmarkDiaryError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "북마크한 다이어리 가져오기 실패"
        case .addBookmarkDiaryError:
            return "다이어리 북마크 추가 실패"
        case .removeBookmarkDiaryError:
            return "다이어리 북마크 삭제 실패"
        }
    }
}

enum FirebaseBookmarkSpotServiceError: Error {
    case badSnapshot
    case addBookmarkSpotError
    case removeBookmarkSpotError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "즐겨찾기한 캠핑장 가져오기 실패"
        case .addBookmarkSpotError:
            return "캠핑장 즐겨찾기 추가 실패"
        case .removeBookmarkSpotError:
            return "캠핑장 즐겨찾기 삭제 실패"
        }
    }
}


struct FirebaseBookmarkService {
    let database = Firestore.firestore()
    
    //MARK: - Add BookmarkDiaryService
    func addBookmarkDiaryService(diaryId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                "bookMarkedDiaries" : FieldValue.arrayUnion([diaryId])
            ]) { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseBookmarkDiaryServiceError.addBookmarkDiaryError))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Remove BookmarkDiaryService
    func removeBookmarkDiaryService(diaryId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                "bookMarkedDiaries" : FieldValue.arrayRemove([diaryId])
            ]) { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseBookmarkDiaryServiceError.removeBookmarkDiaryError))
                } else {
                    promise(.success(()))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Add BookmarkCampingSpotService
    func addBookmarkSpotService(campingSpotId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                "bookMarkedSpot" : FieldValue.arrayUnion([campingSpotId])
            ]) { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseBookmarkSpotServiceError.addBookmarkSpotError))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Remove BookmarkCampingSpotService
    func removeBookmarkSpotService(campingSpotId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                "bookMarkedSpot" : FieldValue.arrayRemove([campingSpotId])
            ]) { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseBookmarkSpotServiceError.removeBookmarkSpotError))
                } else {
                    promise(.success(()))
                }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
}
