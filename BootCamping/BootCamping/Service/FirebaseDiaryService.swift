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

//MARK: - 다이어리 정보와 유저정보를 함께 담을 구조체
struct UserInfoDiary: Hashable {
    var diary: Diary
    var user: User
}

//MARK: - 다이어리 정보와 유저정보, 파이어베이스의 마지막 도큐먼트 스냅샷을 저장하기 위한 구조체
struct LastDocWithDiaryList: Hashable  {
    var userInfoDiarys: [UserInfoDiary]
    var lastDoc: QueryDocumentSnapshot?
}

//MARK: - 다이어리 서비스 에러 처리

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

//MARK: - 다이어리 서비스 CRUD 구현

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
            var imageNamesURLs: [Int: String] = [:]
            
            // DispatchGroup 선언, 비동기 함수들의 작업 완료됨에 따라 동시성 프로그래밍 역할을 맡는다.
            
            let group = DispatchGroup()
            
            guard let userUID = Auth.auth().currentUser?.uid else { return }
            
            for image in images {
                group.enter()
                let storageRef = Storage.storage().reference().child("DiaryImages")
                let imageName = UUID().uuidString
                imageNames.append(imageName)
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
            group.notify(queue: .global(qos: .userInteractive)) {
                // 두번째 비동기 통신
                for (index,imageName) in imageNames.enumerated() {
                    
                    
                    group.enter()
                    let storageRef = Storage.storage().reference().child("DiaryImages")
                    storageRef.child(imageName).downloadURL { url, error in
                        if let error = error {
                            print(error)
                            promise(.failure(FirebaseDiaryServiceError.createDiaryError))
                        } else {
                            imageNamesURLs.updateValue(url!.absoluteString, forKey: index)
                            group.leave()
                        }
     
                    }
                }
                
                group.notify(queue: .main) {
                    // 마지막 비동기 통신
                    let sortedImageNamesURLs = imageNamesURLs.sorted { $0.0 < $1.0 }
                    for i in sortedImageNamesURLs {
                        imageURLs.append(i.value)
                    }
                    
                    let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: diary.diaryVisitedDate, diaryLike: diary.diaryLike, diaryIsPrivate: diary.diaryIsPrivate)
                    
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
    
    func updateDiarysService(diary: Diary) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.database.collection("Diarys").document(diary.id).updateData([
                "diaryTitle": diary.diaryTitle,
                "diaryAddress": diary.diaryAddress,
                "diaryContent": diary.diaryContent,
                "diaryVisitedDate": diary.diaryVisitedDate,
                "diaryIsPrivate": diary.diaryIsPrivate,]) { error in
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
    
    //MARK: - 프로필 업데이트할때 작성한 다이어리의 유저이름 바꿔주는 함수
    
    func updateDiarysNickNameService(userUID: String, nickName: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            self.database.collection("Diarys").whereField("uid", isEqualTo: userUID).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let snapshot = snapshot else {
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                    return
                }
                
                let group = DispatchGroup()
                
                var diaryIds: [String] = []
                
                for document in snapshot.documents {
                    let docData = document.data()
                    
                    let id: String = docData["id"] as? String ?? ""
                    diaryIds.append(id)
                }
                
                
                for diaryId in diaryIds {
                    group.enter()
                    database
                        .collection("Diarys")
                        .document(diaryId)
                        .updateData([
                            "diaryUserNickName" : nickName
                        ]) { error in
                            if let error = error {
                                print(error)
                                promise(.failure(FirebaseDiaryServiceError.updateDiaryError))
                            } else {
                                group.leave()
                            }
                        }
                }
                group.notify(queue: .main) {
                    promise(.success(()))
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
            
            
            for diaryImage in diary.diaryImageNames {
                storageRef.child(diaryImage).delete { error in
                    if let error = error {
                        print("Error removing image from storage: \(error.localizedDescription)")
                    } else {
                        
                    }
                }
            }
            
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
        .eraseToAnyPublisher()
    }
    
    //MARK: - 내 다이어리 뷰 페이지네이션 다이어리 읽기 서비스
    
    func firstGetMyDiaryService() -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .whereField("uid", isEqualTo: Auth.auth().currentUser!.uid).order(by: "diaryCreatedDate", descending: true).limit(to: 5).getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))

                }
                guard let snapshot = snapshot else {
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))
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
                    let diaryVisitedDate: Timestamp = docData["diaryVisitedDate"] as? Timestamp ?? Timestamp()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let date = diaryVisitedDate.dateValue()
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: date, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
                    database.collection("UserList").document(uid).getDocument { document, error in
                        if let error = error {
                            promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                            print(error)
                            return
                        }
                        guard let document = document else {
                            promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                            return }
                        
                        let docData = document.data()
                        
                        let id: String = docData?["id"] as? String ?? ""
                        let profileImageName: String = docData?["profileImageName"] as? String ?? ""
                        let profileImageURL: String = docData?["profileImageURL"] as? String ?? ""
                        let nickName: String = docData?["nickName"] as? String ?? ""
                        let userEmail: String = docData?["userEmail"] as? String ?? ""
                        let bookMarkedDiaries: [String] = docData?["bookMarkedDiaries"] as? [String] ?? []
                        let bookMarkedSpot: [String] = docData?["bookMarkedSpot"] as? [String] ?? []
                        let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .main) {
                    if snapshot.documents.count > 0 {
                        let sortedDiarys = userInfoDiarys.sorted(by: { $0.diary.diaryCreatedDate.compare($1.diary.diaryCreatedDate) == .orderedDescending })
                        let lastDocWithDiaryList: LastDocWithDiaryList = LastDocWithDiaryList(userInfoDiarys: sortedDiarys, lastDoc: snapshot.documents.last!)
                        promise(.success(lastDocWithDiaryList))
                    } else {
                        promise(.success(LastDocWithDiaryList(userInfoDiarys: [], lastDoc: nil)))

                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK:  내 다이어리 페이지 네이션을 할 경우 작동

    func nextGetMyDiaryService(lastDoc: QueryDocumentSnapshot?) -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .whereField("uid", isEqualTo: Auth.auth().currentUser!.uid)
                .order(by: "diaryCreatedDate", descending: true)
                .start(afterDocument: lastDoc!)
                .limit(to: 5)
                .getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                    print(error)
                }
                guard let snapshot = snapshot else {
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))
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
                    let diaryVisitedDate: Timestamp = docData["diaryVisitedDate"] as? Timestamp ?? Timestamp()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let date = diaryVisitedDate.dateValue()
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: date, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
                    database.collection("UserList").document(uid).getDocument { document, error in
                        if let error = error {
                            promise(.failure(FirebaseDiaryServiceError.badSnapshot))
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
                        let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                        
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .main) {
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
    
    //MARK: - 실시간 다이어리 뷰 페이지네이션 다이어리 읽기 서비스
    func firstGetRealTimeDiaryService() -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .whereField("diaryIsPrivate", isEqualTo: false).order(by: "diaryCreatedDate", descending: true).limit(to: 5).getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(FirebaseDiaryServiceError.badSnapshot))
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
                    let diaryVisitedDate: Timestamp = docData["diaryVisitedDate"] as? Timestamp ?? Timestamp()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let date = diaryVisitedDate.dateValue()
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: date, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
                    
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
                        let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .main) {
                    if snapshot.documents.count > 0 {
                        let sortedDiarys = userInfoDiarys.sorted(by: { $0.diary.diaryCreatedDate.compare($1.diary.diaryCreatedDate) == .orderedDescending })
                        let lastDocWithDiaryList: LastDocWithDiaryList = LastDocWithDiaryList(userInfoDiarys: sortedDiarys, lastDoc: snapshot.documents.last!)
                        promise(.success(lastDocWithDiaryList))
                    } else {
                        promise(.success(LastDocWithDiaryList(userInfoDiarys: [], lastDoc: nil)))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK:  실시간 다이어리 페이지 네이션을 할 경우 작동

    func nextGetRealTimeDiaryService(lastDoc: QueryDocumentSnapshot?) -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .whereField("diaryIsPrivate", isEqualTo: false)
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
                    let diaryVisitedDate: Timestamp = docData["diaryVisitedDate"] as? Timestamp ?? Timestamp()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let date = diaryVisitedDate.dateValue()
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: date, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    
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
                        let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                        
                        let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                        
                        userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                        group.leave()
                        
                    }
                }
                
                group.notify(queue: .main) {
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
    
    //MARK: - 위클리 인기 다이어리정보 읽기 서비스

    func mostLikedGetDiarysService() -> AnyPublisher<[UserInfoDiary], Error> {
        Future<[UserInfoDiary], Error> { promise in
            database.collection("Diarys").whereField("diaryIsPrivate", isEqualTo: false).whereField("diaryCreatedDate", isGreaterThan: Timestamp(date: Date(timeIntervalSinceNow: -365 * 24 * 60 * 60))).getDocuments { snapshot, error in
                if let error = error {
                    print(error)
                }
                guard let snapshot = snapshot else {
                    return
                }
                
                let group = DispatchGroup()
                
                var diarys = [Diary]()
                
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
                    let diaryVisitedDate: Timestamp = docData["diaryVisitedDate"] as? Timestamp ?? Timestamp()
                    let diaryLike: [String] = docData["diaryLike"] as? [String] ?? []
                    let diaryIsPrivate: Bool = docData["diaryIsPrivate"] as? Bool ?? false
                    
                    let date = diaryVisitedDate.dateValue()
                    
                    let diary = Diary(id: id, uid: uid, diaryUserNickName: diaryUserNickName, diaryTitle: diaryTitle, diaryAddress: diaryAddress, diaryContent: diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: diaryCreatedDate, diaryVisitedDate: date, diaryLike: diaryLike, diaryIsPrivate: diaryIsPrivate)
                    
                    diarys.append(diary)
                    
                    group.leave()
                }
                
                group.notify(queue: .global(qos: .userInteractive)) {
                    if diarys.count > 10 {
                        
                        var sortedDiarys = diarys.sorted{ $0.diaryLike.count > $1.diaryLike.count}
                        
                        sortedDiarys.removeSubrange(10...diarys.count - 1)
                        

                        for sortedDiary in sortedDiarys {
                            
                            group.enter()
                            database.collection("UserList").document(sortedDiary.uid).getDocument { document, error in
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
                                let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                                
                                let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                                
                                userInfoDiarys.append(UserInfoDiary(diary: sortedDiary, user: user))
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                promise(.success(userInfoDiarys))
                            }
                        }
                    } else {
                        
                        let sortedDiarys = diarys.sorted{ $0.diaryLike.count > $1.diaryLike.count}

                        for sortedDiary in sortedDiarys {
                            
                            group.enter()
                            database.collection("UserList").document(sortedDiary.uid).getDocument { document, error in
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
                                let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                                
                                let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                                
                                userInfoDiarys.append(UserInfoDiary(diary: sortedDiary, user: user))
                                group.leave()

                            }
                        }
                        group.notify(queue: .main) {
                            promise(.success(userInfoDiarys))
                        }
                    }
                }
                
            }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: 캠핑장 디테일 뷰에 들어갈 캠핑노트 리스트 받아오는 함수
    func readCampingSpotsDiariesService(contentId: String) -> AnyPublisher<LastDocWithDiaryList, Error> {
        Future<LastDocWithDiaryList, Error> { promise in
            database.collection("Diarys")
                .whereField("diaryIsPrivate", isEqualTo: false)
                .whereField("diaryAddress", isEqualTo: contentId)
                .order(by: "diaryCreatedDate", descending: true)
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
                            let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                            
                            let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                            
                            userInfoDiarys.append(UserInfoDiary(diary: diary, user: user))
                            group.leave()
                            
                        }
                    }
                    
                    group.notify(queue: .main) {
                        if snapshot.documents.count > 0 {
                            let sortedDiarys = userInfoDiarys.sorted(by: { $0.diary.diaryCreatedDate.compare($1.diary.diaryCreatedDate) == .orderedDescending })
                            let lastDocWithDiaryList: LastDocWithDiaryList = LastDocWithDiaryList(userInfoDiarys: sortedDiarys, lastDoc: snapshot.documents.last!)
                            promise(.success(lastDocWithDiaryList))
                        } else {
                            promise(.success(LastDocWithDiaryList(userInfoDiarys: [], lastDoc: nil)))
                        }
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
}

