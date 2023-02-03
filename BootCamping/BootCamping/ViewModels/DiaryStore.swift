//
//  DiaryStore.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/01/18.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import FirebaseStorage
import Combine

class DiaryStore: ObservableObject {
    //저장된 다이어리 리스트
    @Published var diaryList: [Diary] = []
    @Published var firebaseDiaryServiceError: FirebaseDiaryServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    //파베 기본 경로
    let database = Firestore.firestore()
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: Create
    func createDiary(diary: Diary, images: [Data]) {
            Task {
                do {
                    guard let userUID = Auth.auth().currentUser?.uid else { return }
                    var diaryImageURLs: [String] = []
                    var diaryImageNames: [String] = []
                    let storageRef = Storage.storage().reference().child("DiaryImages")
                    for image in images {
                        let imageName = UUID().uuidString
                        let _ = try await storageRef.child(imageName).putDataAsync(image)
                        let downlodURL = try await storageRef.child(imageName).downloadURL()
                        diaryImageURLs.append(downlodURL.absoluteString)
                        diaryImageNames.append(imageName)
                    }
                    
                    let newDiary = Diary(id: diary.id, uid: userUID, diaryUserNickName: diary.diaryUserNickName, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: "56", diaryIsPrivate: true)
                    
                    let _ = try await Firestore.firestore().collection("Diarys").document(diary.id).setData([
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
                        "diaryIsPrivate": newDiary.diaryIsPrivate,])
                    getData()
                } catch {
                    await MainActor.run(body: {
                        print("\(error.localizedDescription)")
                    })
                }
            }
        }
    
    //MARK: Read
    func getData() {
        database.collection("Diarys").getDocuments { snapshot, error in
            //에러체크
            if error == nil {
                if let snapshot = snapshot {
                    //백그라운드 스레드에서 실행되지만, 이 코드 실행시 UI가 변경됨. 스레드 메인으로 설정하기
                    DispatchQueue.main.async {
                        //document 가져오기
                        self.diaryList = snapshot.documents.map { d in
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
                    }
                    
                }
                
            } else {
                //에러처리
            }
            
        }
    }
    
    //MARK: Update
    func updateData(diaryToUpdate: Diary) {
        database.collection("Diarys").document(diaryToUpdate.id).setData([  //data: document내부 데이터, completion: 완료시 실행됨
            "uid": diaryToUpdate.uid,
            "diaryUserNickName": diaryToUpdate.diaryUserNickName,
            "diaryTitle": diaryToUpdate.diaryTitle,
            "diaryAddress": diaryToUpdate.diaryAddress,
            "diaryContent": diaryToUpdate.diaryContent,
            "diaryImageNames": diaryToUpdate.diaryImageNames,
            "diaryImageURL": diaryToUpdate.diaryImageURLs,
            "diaryCreatedDate": diaryToUpdate.diaryCreatedDate,
            "diaryVisitedDate": diaryToUpdate.diaryVisitedDate,
            "diaryLike": diaryToUpdate.diaryLike,
            "diaryIsPrivate": diaryToUpdate.diaryIsPrivate,], merge: true)                                                             //setData: 이 데이터로 새로 정의되고, 기존 데이터는 삭제됨 /merge하면 재정의하는 대신 합쳐짐
        { error in
            
            //에러체크
            if error == nil {
                //업데이트
                self.getData()
            } else {
                //에러처리
            }
        }
    }
    
    //MARK: Delete
    func deleteData(diaryToDelete: Diary) {
        database.collection("Diarys").document(diaryToDelete.id).delete { error in
            //에러 체크
            if error == nil {
                //삭제하면 UI가 바뀌므로 메인 스레드에서 업데이트
                DispatchQueue.main.async {
                    //Remove the diary that was just deleted
                    self.diaryList.removeAll { diary in
                        //Check for the diary to remove
                        return diary.id == diaryToDelete.id
                    }
                }
            } else {
                //에러처리
            }
            
        }
        getData()
    }

    //MARK: Read Diary Combine
    
    func readDiarysCombine() {
        FirebaseDiaryService().readDiarysService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get Diarys")
                    self.firebaseDiaryServiceError = .badSnapshot
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                        return
                case .finished:
                    print("Finished get Diarys")
                    return
                }
            } receiveValue: { [weak self] diarys in
                self?.diaryList = diarys
            }
            .store(in: &cancellables)
    }
    

    //MARK: Create Diary Combine

    func createDiaryCombine(diary: Diary, images: [Data]) {
        FirebaseDiaryService().createDiaryService(diary: diary, images: images)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Create Diary")
                    self.firebaseDiaryServiceError = .createDiaryError
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished Create Diary")
                    self.readDiarysCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: Update Diary Combine
    
    func updateDiaryCombine(diary: Diary, images: [Data]) {
        FirebaseDiaryService().createDiaryService(diary: diary, images: images)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Update Diary")
                    self.firebaseDiaryServiceError = .updateDiaryError
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished Update Diary")
                    self.readDiarysCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: Delete Diary Combine
    
    func deleteDiaryCombine(diary: Diary) {
        FirebaseDiaryService().deleteDiaryService(diary: diary)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Delete Diary")
                    self.firebaseDiaryServiceError = .deleteDiaryError
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                    return
                case .finished:
                    self.readDiarysCombine()
                    print("Finished Delete Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }

}
