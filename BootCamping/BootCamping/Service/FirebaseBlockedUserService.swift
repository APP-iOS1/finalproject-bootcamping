//
//  FirebaseBlockedUserService.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import Combine
import Firebase

enum FirebaseBlockedUserServiceError: Error {
    case badSnapshot
    case addBlockedUserError
    case removeBlockedUserError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "차단한 이용자 가져오기 실패"
        case .addBlockedUserError:
            return "차단한 이용자 추가 실패"
        case .removeBlockedUserError:
            return "차단한 이용자 삭제 실패"
        }
    }
}


struct FirebaseBlockedUserService {
    let database = Firestore.firestore()
    
    //MARK: - Add BlockedUserService
    func addBlockedUserService(blockedUserId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                    "blockedUser" : FieldValue.arrayUnion([blockedUserId])
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseBlockedUserServiceError.addBlockedUserError))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Remove BlockedUserService
    func removeBlockedUserService(blockedUserId: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            self.database
                .collection("UserList")
                .document(userUID)
                .updateData([
                    "blockedUser" : FieldValue.arrayRemove([blockedUserId])
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseBlockedUserServiceError.removeBlockedUserError))
                    } else {
                        promise(.success(()))
                    }
                }
            
        }
        .eraseToAnyPublisher()
    }
}
