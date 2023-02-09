//
//  FirebaseUserListService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/03.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import Combine

enum FirebaseUserServiceError: Error {
    case badSnapshot
    case createUserListError
    case updateUserListError
    case deleteUserListError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "유저리스트 가져오기 실패"
        case .createUserListError:
            return "유저정보 추가 실패"
        case .updateUserListError:
            return "유저정보 업데이트 실패"
        case .deleteUserListError:
            return "유저정보 삭제 실패"
        }
    }
}

struct FirebaseUserService {
    
    let database = Firestore.firestore()
    
    //MARK: - Read FirebaseUserService
    func readUserListService() -> AnyPublisher<[User], Error> {
        Future<[User], Error> { promise in
            database.collection("UserList")
                .getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseUserServiceError.badSnapshot))
                        return
                        
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseUserServiceError.badSnapshot))
                        return
                    }
                    var users = [User]()
                    
                    
                    users = snapshot.documents.map { d in
                        return User(id: d.documentID,
                                    profileImageName: d["profileImage"] as? String ?? "",
                                    profileImageURL: d["profileImage"] as? String ?? "",
                                    nickName: d["nickName"] as? String ?? "",
                                    userEmail: d["userEmail"] as? String ?? "",
                                    bookMarkedDiaries: d["bookMarkedDiaries"] as? [String] ?? [],
                                    bookMarkedSpot: d["bookMarkedSpot"] as? [String] ?? [],
                                    blockedUser: d["blockedUser"] as? [String] ?? []
                        )}
                    
                    promise(.success(users))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Read MyAuthInformation
    func readMyInfoService(user: User) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            database.collection("UserList")
                .document(user.id)
                .getDocument { (snapshot, error) in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseUserServiceError.badSnapshot))
                        return
                        
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseUserServiceError.badSnapshot))
                        return
                    }
                    let docData = snapshot.data()!
                    
                    let id: String = docData["id"] as? String ?? ""
                    let profileImageName: String = docData["profileImageName"] as? String ?? ""
                    let profileImageURL: String = docData["profileImageURL"] as? String ?? ""
                    let nickName: String = docData["nickName"] as? String ?? ""
                    let userEmail: String = docData["userEmail"] as? String ?? ""
                    let bookMarkedDiaries: [String] = docData["bookMarkedDiaries"] as? [String] ?? []
                    let bookMarkedSpot: [String] = docData["bookMarkedSpot"] as? [String] ?? []
                    let blockedUser: [String] = docData["blockedUser"] as? [String] ?? []
                        
                    let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                    
                    promise(.success(user))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Create FirebaseUserService

    func createUserService(user: User) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.database.collection("UserList").document(user.id).setData([
                "id": user.id,
                "profileImageName": user.profileImageName,
                "profileImageURL": user.profileImageURL,
                "nickName": user.nickName,
                "userEmail": user.userEmail,
                "bookMarkedDiaries": user.bookMarkedDiaries,
                "bookMarkedSpot": user.bookMarkedSpot,
                "blockedUser": user.blockedUser
            ]) { error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseUserServiceError.createUserListError))
                } else {
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Update FirebaseUserService

    func updateUserService(image: Data?, user: User) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            if let image = image {
                let imageName = UUID().uuidString
                var imageURS: String = ""
                
                let myQueue = DispatchQueue(label: "updatework",attributes: .concurrent)
                let group = DispatchGroup()
                
                group.enter()
                myQueue.sync {
                    let storageRef = Storage.storage().reference().child("UserImages")
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    let uploadTask = storageRef.child(imageName).putData(image, metadata: metadata)
                    uploadTask.observe(.success) { snapshot in
                        group.leave()
                    }
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error as? NSError {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                                print("File doesn't exist")
                            case .unauthorized:
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                                print("User doesn't have permission to access file")
                            case .cancelled:
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                                print("User canceled the upload")
                            case .unknown:
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                                print("Unknown error occurred, inspect the server response")
                            default:
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                                print("A separate error occurred. This is a good place to retry the upload.")
                            }
                        }
                    }
                }
                group.notify(queue: myQueue) {
                    group.enter()
                    myQueue.sync {
                        let storageRef = Storage.storage().reference().child("UserImages")
                        storageRef.child(imageName).downloadURL { url, error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                            } else {
                                imageURS = url!.absoluteString
                                group.leave()
                            }
                        }
                    }
                    group.notify(queue: myQueue) {
                        self.database.collection("UserList").document(user.id).setData([
                            "id": user.id,
                            "profileImageName": imageName,
                            "profileImageURL": imageURS,
                            "nickName": user.nickName,
                            "userEmail": user.userEmail,
                            "bookMarkedDiaries": user.bookMarkedDiaries,
                            "bookMarkedSpot": user.bookMarkedSpot,
                            "blockedUser": user.blockedUser,
                        ]) { error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseUserServiceError.updateUserListError))
                            } else {
                                promise(.success(()))
                            }
                        }
                    }
                }
            } else {
                self.database.collection("UserList").document(user.id).setData([
                    "id": user.id,
                    "profileImageName": user.profileImageName,
                    "profileImageURL": user.profileImageURL,
                    "nickName": user.nickName,
                    "userEmail": user.userEmail,
                    "bookMarkedDiaries": user.bookMarkedDiaries,
                    "bookMarkedSpot": user.bookMarkedSpot,
                    "blockedUser": user.blockedUser,
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseUserServiceError.updateUserListError))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Delete FirebaseUserService
    
    func deleteUserService(user: User) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let storageRef = Storage.storage().reference().child("UserImages")
            
            let myQueue = DispatchQueue(label: "deletework",attributes: .concurrent)
            let group = DispatchGroup()
            
            group.enter()
            myQueue.sync {
                storageRef.child(user.profileImageName).delete { error in
                    if let error = error {
                        print("Error removing image from storage: \(error.localizedDescription)")
                        promise(.failure(FirebaseUserServiceError.deleteUserListError))
                    } else {
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: myQueue) {
                
                self.database.collection("UserList")
                    .document(user.id).delete() { error in
                        if let error = error {
                            print(error)
                        promise(.failure(FirebaseUserServiceError.deleteUserListError))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

