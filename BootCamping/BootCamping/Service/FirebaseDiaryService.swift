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

struct FirebaseDiaryService {
    
    let database = Firestore.firestore()
    
    //MARK: Read FirebaseDiaryService
    
    func getDiarysService() -> AnyPublisher<[Diary], Error> {
        Future<[Diary], Error> { promise in
            database.collection("Diarys")
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
                                     diaryLike: d["diaryLike"] as? String ?? "",
                                     diaryIsPrivate: d["diaryIsPrivate"] as? Bool ?? false)
                        
                    }
                    promise(.success(diarys))
                }
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: Create FirebaseDiaryService
    func createDiaryService(diary: Diary, images: [Data]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            //첫번째 비동기 통신
            
            var imageNames: [String] = []
            var imageURLs: [String] = []
            
            //
            let group = DispatchGroup()
            guard let userUID = Auth.auth().currentUser?.uid else { return }

            for image in images {
                group.enter()
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
                        promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                       print("File doesn't exist")
                    case .unauthorized:
                        promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                       print("User doesn't have permission to access file")
                    case .cancelled:
                        promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                       print("User canceled the upload")
                    case .unknown:
                        promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                       print("Unknown error occurred, inspect the server response")
                    default:
                        promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                       print("A separate error occurred. This is a good place to retry the upload.")
                    }
                  }
                }
            }
            
            for imageName in imageNames {
                group.enter()
                let storageRef = Storage.storage().reference().child("DiaryImages")
                storageRef.child(imageName).downloadURL { url, error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryServiceError.imageDownloadURLError))
                    } else {
                        imageURLs.append(url!.absoluteString)
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main) {
                
                let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: "56", diaryIsPrivate: true)
                
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
                            promise(.failure(FirebaseDiaryServiceError.badSnapshot))
                        } else {
                            promise(.success(()))
                        }
                        
                    }
            }
            
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: Update FirebaseDiaryService
    
    func updateDiarysService(diary: Diary, images: [Data]) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            var imageNames: [String] = []
            var imageURLs: [String] = []
            
            guard let userUID = Auth.auth().currentUser?.uid else { return }

            
            let group = DispatchGroup()
            
            for image in images {
                group.enter()
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
                            promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                            print("File doesn't exist")
                        case .unauthorized:
                            promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                            print("User doesn't have permission to access file")
                        case .cancelled:
                            promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                            print("User canceled the upload")
                        case .unknown:
                            promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                            print("Unknown error occurred, inspect the server response")
                        default:
                            promise(.failure(FirebaseDiaryServiceError.imageUploadError))
                            print("A separate error occurred. This is a good place to retry the upload.")
                        }
                    }
                }
            }
            
            for imageName in imageNames {
                group.enter()
                let storageRef = Storage.storage().reference().child("DiaryImages")
                storageRef.child(imageName).downloadURL { url, error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryServiceError.imageDownloadURLError))
                    } else {
                        imageURLs.append(url!.absoluteString)
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                
                let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: "56", diaryIsPrivate: true)
                
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
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                        
                    }
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    
    
    //MARK: Delete FirebaseDiaryService
    func deleteDiaryService(diary: Diary) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            let storageRef = Storage.storage().reference().child("DiaryImages")
            
            let group = DispatchGroup()

            for diaryImage in diary.diaryImageNames {
                group.enter()
                storageRef.child(diaryImage).delete { error in
                    if let error = error {
                        print("Error removing image from storage: \(error.localizedDescription)")
                        promise(.failure(FirebaseDiaryServiceError.imageDeleteError))
                    } else {
                        group.leave()
                    }
                }
            }
            group.notify(queue: .main) {
                
                self.database.collection("Diarys")
                    .document(diary.id).delete() { error in
                    if let error = error {
                        print(error)
                        promise(.failure(FirebaseDiaryServiceError.imageDeleteError))
                    } else {
                        promise(.success(()))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}


enum FirebaseDiaryServiceError: Error {
    case badSnapshot
    case authError
    case imageUploadError
    case imageDownloadURLError
    case imageDeleteError
}



//MARK: Create FirebaseDiaryService

//func createDiaryService(diary: Diary, images: [Data]) -> AnyPublisher<Void, Error> {
//    Future<Void, Error> { promise in
//        var imageNames: [String] = []
//        var imageURLs: [String] = []
//
//        imageUpload(images: images) { imgNames in
//            imageNames.append(contentsOf: imgNames)
//            getDownloadURL(imageNames: imageNames) { imgURLs in
//                imageURLs.append(contentsOf: imgURLs)
//                guard let userUID = Auth.auth().currentUser?.uid else { return
//                }
//
//                let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: imageNames, diaryImageURLs: imageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: "56", diaryIsPrivate: true)
//
//                self.database.collection("Diarys").document(diary.id).setData([
//                    "id": newDiary.id,
//                    "uid": newDiary.uid,
//                    "diaryUserNickName": newDiary.diaryUserNickName,
//                    "diaryTitle": newDiary.diaryTitle,
//                    "diaryAddress": newDiary.diaryAddress,
//                    "diaryContent": newDiary.diaryContent,
//                    "diaryImageNames": newDiary.diaryImageNames,
//                    "diaryImageURLs": newDiary.diaryImageURLs,
//                    "diaryCreatedDate": newDiary.diaryCreatedDate,
//                    "diaryVisitedDate": newDiary.diaryVisitedDate,
//                    "diaryLike": newDiary.diaryLike,
//                    "diaryIsPrivate": newDiary.diaryIsPrivate,]) { error in
//                        if let error = error {
//                            promise(.failure(error))
//                        } else {
//                            promise(.success(()))
//                        }
//
//                    }
//            }
//        }
//    }
//    .eraseToAnyPublisher()
//}
//
//
//func imageUpload(images: [Data], completion: @escaping ([String]) -> ()) {
//    var imageNames: [String] = []
//    var count: Int = 0
//    for image in images {
//        let storageRef = Storage.storage().reference().child("DiaryImages")
//        let imageName = UUID().uuidString
//        let metadata = StorageMetadata()
//        metadata.contentType = "image/jpeg"
//        let uploadTask = storageRef.child(imageName).putData(image, metadata: metadata)
//        uploadTask.observe(.success) { snapshot in
//            count += 1
//            imageNames.append(imageName)
//            if count == images.count {
//                completion(imageNames)
//            }
//        }
//        uploadTask.observe(.failure) { snapshot in
//          if let error = snapshot.error as? NSError {
//            switch (StorageErrorCode(rawValue: error.code)!) {
//            case .objectNotFound:
//                count += 1
//                if count == images.count {
//                    completion(imageNames)
//                }
//               print("File doesn't exist")
//              break
//            case .unauthorized:
//                count += 1
//                if count == images.count {
//                    completion(imageNames)
//                }
//
//               print("User doesn't have permission to access file")
//              break
//            case .cancelled:
//                count += 1
//                if count == images.count {
//                    completion(imageNames)
//                }
//               print("User canceled the upload")
//              break
//
//            /* ... */
//
//            case .unknown:
//                count += 1
//                if count == images.count {
//                    completion(imageNames)
//                }
//               print("Unknown error occurred, inspect the server response")
//              break
//            default:
//                count += 1
//                if count == images.count {
//                    completion(imageNames)
//                }
//               print("A separate error occurred. This is a good place to retry the upload.")
//              break
//            }
//          }
//        }
//    }
//}
//
//func getDownloadURL(imageNames: [String], completion: @escaping ([String]) -> ()) {
//    var imageURLs: [String] = []
//    var count: Int = 0
//    for imageName in imageNames {
//        let storageRef = Storage.storage().reference().child("DiaryImages")
//        storageRef.child(imageName).downloadURL { url, error in
//            if let error = error {
//                count += 1
//                print(error)
//                if count == imageNames.count {
//                    completion(imageURLs)
//                }
//            } else {
//                count += 1
//                imageURLs.append(url!.absoluteString)
//                if count == imageNames.count {
//                    completion(imageURLs)
//                }
//            }
//        }
//    }
//}

//MARK: Delete FirebaseDiaryService
//func deleteDiaryService(diary: Diary) -> AnyPublisher<Void, Error> {
//    Future<Void, Error> { promise in
//        removeImage(diary: diary) {
//            self.database.collection("Diarys")
//                .document(diary.id).delete()
//            { error in
//                if let error = error {
//                    promise(.failure(error))
//                } else {
//                    promise(.success(()))
//                }
//            }
//        }
//    }
//    .eraseToAnyPublisher()
//}
//
////MARK: Remove Storage
//func removeImage(diary: Diary, completion: @escaping () -> ()) {
//    let storageRef = Storage.storage().reference().child("DiaryImages")
//    var count: Int = 0
//    for diaryImage in diary.diaryImageNames {
//        storageRef.child(diaryImage).delete { error in
//            if let error = error {
//                print("Error removing image from storage: \(error.localizedDescription)")
//                count += 1
//                if count == diary.diaryImageNames.count {
//                    completion()
//                }
//            } else {
//                count += 1
//                if count == diary.diaryImageNames.count {
//                    completion()
//                }
//            }
//        }
//    }
//}
