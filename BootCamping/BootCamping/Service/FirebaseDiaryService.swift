//
//  FirebaseService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/01/31.
//

import Combine
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Firebase

struct UserInfoDiary: Hashable {
    var diary: Diary
    var user: User
}
struct LastDocWithDiaryList: Hashable  {
    var userInfoDiarys: [UserInfoDiary]
    var lastDoc: QueryDocumentSnapshot?
}

enum FirebaseDiaryServiceError: Error {
    case badSnapshot
    case createDiaryError
    case updateDiaryError
    case deleteDiaryError
    
    var errorDescription: String? {
        switch self {
        case .badSnapshot:
            return "게시물 가져오기 실패"
        case .createDiaryError:
            return "게시물 작성 실패"
        case .updateDiaryError:
            return "게시물 업데이트 실패"
        case .deleteDiaryError:
            return "게시물 삭제 실패"
        }
    }
}


struct FirebaseDiaryService {
    
    let database = Firestore.firestore()
    
    //MARK: - Read FirebaseDiaryService
    
    func readDiarysService() -> AnyPublisher<[Diary], Error> {
        Future<[Diary], Error> { promise in
            database.collection("Diarys")
                .order(by: "diaryCreatedDate", descending: true)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let snapshot = snapshot else {
                        promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                        return
                    }
                    
                    var diarys = [Diary]()
                    
                    //document 가져오기
                    diarys = snapshot.documents.map { d in
                        return Diary(id: d.documentID,
                                     uid: d["uid"] as? String ?? "",
                                     diaryUserNickName: d["diaryUserNickName"] as? String ?? "",
                                     diaryTitle: d["diaryTitle"] as? String ?? "",
                                     diaryAddress: d["diaryAddress"] as? String ?? "",
                                     diaryContent: d["diaryContent"] as? String ?? "",
                                     diaryImageNames: d["diaryImageNames"] as? [String] ?? [],
                                     diaryImageURLs: d["diaryImageURLs"] as? [String] ?? [],
                                     diaryCreatedDate: d["diaryCreatedDate"] as? Timestamp ?? Timestamp(),
                                     diaryVisitedDate: d["diaryVisitedDate"] as? Date ?? Date(),
                                     diaryLike: d["diaryLike"] as? [String] ?? [],
                                     diaryIsPrivate: d["diaryIsPrivate"] as? Bool ?? false)
                        
                    }
                    promise(.success(diarys))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Create FirebaseDiaryService
    
    func createDiaryService(diary: Diary, images: [Data]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            //첫번째 비동기 통신
            
            var imageNames: [String] = []
            var imageURLs: [String] = []
            
            let myQueue = DispatchQueue(label: "creatework",attributes: .concurrent)
            let group = DispatchGroup()
            
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            for image in images {
                group.enter()
                myQueue.sync {
                    let storageRef = Storage.storage().reference().child("DiaryImages")
                    let imageName = UUID().uuidString
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    let uploadTask = storageRef.child(imageName).putData(image, metadata: metadata)
                    uploadTask.observe(.success) { snapshot in
                        imageNames.append(imageName)
                        group.leave()
                    }
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error as? NSError {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                                print("File doesn't exist")
                            case .unauthorized:
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                                print("User doesn't have permission to access file")
                            case .cancelled:
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                                print("User canceled the upload")
                            case .unknown:
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                                print("Unknown error occurred, inspect the server response")
                            default:
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                                print("A separate error occurred. This is a good place to retry the upload.")
                            }
                        }
                    }
                }
            }
            group.notify(queue: myQueue) {
                
                for imageName in imageNames {
                    group.enter()
                    myQueue.sync {
                        let storageRef = Storage.storage().reference().child("DiaryImages")
                        storageRef.child(imageName).downloadURL { url, error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                            } else {
                                imageURLs.append(url!.absoluteString)
                                group.leave()
                            }
                        }
                    }
                }
                
                group.notify(queue: myQueue) {
                    
                    let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: diary.diaryLike, diaryIsPrivate: diary.diaryIsPrivate)
                    
                    self.database.collection("Diarys").document(diary.id).setData([
                        "id": newDiary.id,
                        "uid": newDiary.uid,
                        "diaryUserNickName": newDiary.diaryUserNickName,
                        "diaryTitle": newDiary.diaryTitle,
                        "diaryAddress": newDiary.diaryAddress,
                        "diaryContent": newDiary.diaryContent,
                        "diaryImageNames": newDiary.diaryImageNames,
                        "diaryImageURLs": newDiary.diaryImageURLs,
                        "diaryCreatedDate": newDiary.diaryCreatedDate,
                        "diaryVisitedDate": newDiary.diaryVisitedDate,
                        "diaryLike": newDiary.diaryLike,
                        "diaryIsPrivate": newDiary.diaryIsPrivate,]) { error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                            } else {
                                promise(.success(()))
                            }
                            
                        }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Update FirebaseDiaryService
    
    func updateDiarysService(diary: Diary, images: [Data]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            var imageNames: [String] = []
            var imageURLs: [String] = []
            
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            let myQueue = DispatchQueue(label: "updatework",attributes: .concurrent)
            
            let group = DispatchGroup()
            
            for image in images {
                group.enter()
                myQueue.sync {
                    let storageRef = Storage.storage().reference().child("DiaryImages")
                    let imageName = UUID().uuidString
                    let metadata = StorageMetadata()
                    metadata.contentType = "image/jpeg"
                    let uploadTask = storageRef.child(imageName).putData(image, metadata: metadata)
                    uploadTask.observe(.success) { snapshot in
                        imageNames.append(imageName)
                        group.leave()
                    }
                    uploadTask.observe(.failure) { snapshot in
                        if let error = snapshot.error as? NSError {
                            switch (StorageErrorCode(rawValue: error.code)!) {
                            case .objectNotFound:
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                                print("File doesn't exist")
                            case .unauthorized:
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                                print("User doesn't have permission to access file")
                            case .cancelled:
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                                print("User canceled the upload")
                            case .unknown:
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                                print("Unknown error occurred, inspect the server response")
                            default:
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                                print("A separate error occurred. This is a good place to retry the upload.")
                            }
                        }
                    }
                }
            }
            group.notify(queue: myQueue) {
                
                for imageName in imageNames {
                    group.enter()
                    myQueue.sync {
                        let storageRef = Storage.storage().reference().child("DiaryImages")
                        storageRef.child(imageName).downloadURL { url, error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                            } else {
                                imageURLs.append(url!.absoluteString)
                                group.leave()
                            }
                        }
                    }
                }
                group.notify(queue: myQueue) {
                    
                    let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: diary.diaryLike, diaryIsPrivate: diary.diaryIsPrivate)
                    
                    self.database.collection("Diarys").document(diary.id).setData([
                        "id": newDiary.id,
                        "uid": newDiary.uid,
                        "diaryUserNickName": newDiary.diaryUserNickName,
                        "diaryTitle": newDiary.diaryTitle,
                        "diaryAddress": newDiary.diaryAddress,
                        "diaryContent": newDiary.diaryContent,
                        "diaryImageNames": newDiary.diaryImageNames,
                        "diaryImageURLs": newDiary.diaryImageURLs,
                        "diaryCreatedDate": newDiary.diaryCreatedDate,
                        "diaryVisitedDate": newDiary.diaryVisitedDate,
                        "diaryLike": newDiary.diaryLike,
                        "diaryIsPrivate": newDiary.diaryIsPrivate,]) { error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                            } else {
                                promise(.success(()))
                            }
                            
                        }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 다이어리 공개 여부만 Update하는 함수
    func updateIsPrivateDiaryService(diaryId: String, isPrivate: Bool) -> AnyPublisher<Void, Error> {
        Future<Void, Error>  { promise in
            database
                .collection("Diarys")
                .document(diaryId)
                .updateData([
                    "diaryIsPrivate" : isPrivate
                ]) { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                    } else {
                        promise(.success(()))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    
    //MARK: - Delete FirebaseDiaryService
    
    func deleteDiaryService(diary: Diary) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let storageRef = Storage.storage().reference().child("DiaryImages")
            
            let myQueue = DispatchQueue(label: "updatework",attributes: .concurrent)
            let group = DispatchGroup()
            
            for diaryImage in diary.diaryImageNames {
                group.enter()
                myQueue.sync {
                    storageRef.child(diaryImage).delete { error in
                        if let error = error {
                            print("Error removing image from storage: \(error.localizedDescription)")
                            promise(.failure(FirebaseDiaryServiceError.deleteDiaryError))
                        } else {
                            group.leave()
                        }
                    }
                }
            }
            group.notify(queue: myQueue) {
                
                self.database.collection("Diarys")
                    .document(diary.id).delete() { error in
                        if let error = error {
                            print(error)
                            promise(.failure(FirebaseDiaryServiceError.deleteDiaryError))
                        } else {
                            promise(.success(()))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func firstGetDiaryService() -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys").order(by: "diaryCreatedDate", descending: true).limit(to: 5).getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                }
                guard let snapshot = snapshot else {
                    return
                }
                
                let group = DispatchGroup()
                
                var userInfoDiarys = [UserInfoDiary]()
                
                for document in snapshot.documents {
                    group.enter()
                    
                    let docData = document.data()
                    
                    let id: String = docData["id"] as? String ?? ""
                    let uid: String = docData["uid"] as? String ?? ""
                    let diaryUserNickName: String = docData["diaryUserNickName"] as? String ?? ""
                    let diaryTitle: String = docData["diaryTitle"] as? String ?? ""
                    let diaryAddress: String = docData["diaryAddress"] as? String ?? ""
                    let diaryContent: String = docData["diaryContent"] as? String ?? ""
                    let diaryImageNames: [String] = docData["diaryImageNames"] as? [String] ?? []
                    let diaryImageURLs: [String] = docData["diaryImageURLs"] as? [String] ?? []
                    let diaryCreatedDate: Timestamp = docData["diaryCreatedDate"] as? Timestamp ?? Timestamp()
                    let diaryVisitedDate: Date = docData["diaryVisitedDate"] as? Date ?? Date()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: diaryVisitedDate, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
                    database.collection("UserList").document(uid).getDocument { document, error in
                        if let error = error {
                            print(error)
                            return
                        }
                        guard let document = document else { return }
                        
                        let docData = document.data()
                        
                        let id: String = docData?["id"] as? String ?? ""
                        let profileImageName: String = docData?["profileImageName"] as? String ?? ""
                        let profileImageURL: String = docData?["profileImageURL"] as? String ?? ""
                        let nickName: String = docData?["nickName"] as? String ?? ""
                        let userEmail: String = docData?["userEmail"] as? String ?? ""
                        let bookMarkedDiaries: [String] = docData?["bookMarkedDiaries"] as? [String] ?? []
                        let bookMarkedSpot: [String] = docData?["bookMarkedSpot"] as? [String] ?? []
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .global()) {
                    if snapshot.documents.count > 0 {
                        let sortedDiarys = userInfoDiarys.sorted(by: { $0.diary.diaryCreatedDate.compare($1.diary.diaryCreatedDate) == .orderedDescending })
                        let lastDocWithDiaryList: LastDocWithDiaryList = LastDocWithDiaryList(userInfoDiarys: sortedDiarys, lastDoc: snapshot.documents.last!)
                        promise(.success(lastDocWithDiaryList))
                    } else {
                        promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func nextGetDiaryService(lastDoc: QueryDocumentSnapshot?) -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .order(by: "diaryCreatedDate", descending: true)
                .start(afterDocument: lastDoc!)
                .limit(to: 5)
                .getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                }
                guard let snapshot = snapshot else {
                    return
                }
                
                let group = DispatchGroup()
                
                var userInfoDiarys = [UserInfoDiary]()
                
                for document in snapshot.documents {
                    group.enter()
                    
                    let docData = document.data()
                    
                    let id: String = docData["id"] as? String ?? ""
                    let uid: String = docData["uid"] as? String ?? ""
                    let diaryUserNickName: String = docData["diaryUserNickName"] as? String ?? ""
                    let diaryTitle: String = docData["diaryTitle"] as? String ?? ""
                    let diaryAddress: String = docData["diaryAddress"] as? String ?? ""
                    let diaryContent: String = docData["diaryContent"] as? String ?? ""
                    let diaryImageNames: [String] = docData["diaryImageNames"] as? [String] ?? []
                    let diaryImageURLs: [String] = docData["diaryImageURLs"] as? [String] ?? []
                    let diaryCreatedDate: Timestamp = docData["diaryCreatedDate"] as? Timestamp ?? Timestamp()
                    let diaryVisitedDate: Date = docData["diaryVisitedDate"] as? Date ?? Date()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: diaryVisitedDate, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
                    database.collection("UserList").document(uid).getDocument { document, error in
                        if let error = error {
                            print(error)
                            return
                        }
                        guard let document = document else { return }
                        
                        let docData = document.data()
                        
                        let id: String = docData?["id"] as? String ?? ""
                        let profileImageName: String = docData?["profileImageName"] as? String ?? ""
                        let profileImageURL: String = docData?["profileImageURL"] as? String ?? ""
                        let nickName: String = docData?["nickName"] as? String ?? ""
                        let userEmail: String = docData?["userEmail"] as? String ?? ""
                        let bookMarkedDiaries: [String] = docData?["bookMarkedDiaries"] as? [String] ?? []
                        let bookMarkedSpot: [String] = docData?["bookMarkedSpot"] as? [String] ?? []
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .global()) {
                    if snapshot.documents.count > 0 {
                        let sortedDiarys = userInfoDiarys.sorted(by: { $0.diary.diaryCreatedDate.compare($1.diary.diaryCreatedDate) == .orderedDescending })
                        let lastDocWithDiaryList: LastDocWithDiaryList = LastDocWithDiaryList(userInfoDiarys: sortedDiarys, lastDoc: snapshot.documents.last!)
                        promise(.success(lastDocWithDiaryList))
                    } else {
                        promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
//    database.collection("CampingSpotList")
//        .whereField("contentId", isEqualTo: String(readDocument.campingSpotContenId))
//        .order(by: "contentId", descending: false)
//        .start(afterDocument: readDocument.lastDoc!)
//        .limit(to: 10)
//        .getDocuments { snapshot, error in
}

