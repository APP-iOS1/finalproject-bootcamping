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

/*
 struct Diary {
     let id: String //글
     let uid: String //유저
     let diaryTitle: String //다이어리 제목
     let diaryAddress: String //장소
     let diaryContent: String //다이어리 내용
     let diaryImageURL: [String] //사진
     let diaryCreatedDate: Timestamp //작성날짜
     let diaryVisitedDate: Date //방문날짜 (피커로..?)
     let diaryLike: String //다이어리 좋아요
 }
 */
class DiaryStore: ObservableObject {
    //저장된 다이어리 리스트
    @Published var diaryList: [Diary] = []
    //파베 기본 경로
    let database = Firestore.firestore()
    
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
                    
                    let newDiary = Diary(id: diary.id, uid: userUID, diaryTitle: diary.diaryTitle, diaryAddress: diary.diaryAddress, diaryContent: diary.diaryContent, diaryImageNames: diaryImageNames, diaryImageURLs: diaryImageURLs, diaryCreatedDate: Timestamp(), diaryVisitedDate: Date.now, diaryLike: "56", diaryIsPrivate: true)
                    
                    let _ = try await Firestore.firestore().collection("Diarys").document(diary.id).setData([
                        "id": newDiary.id,
                        "uid": newDiary.uid,
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
        removeImage(diaryToDelete)
        getData()
    }
    
    //MARK: Remove Storage
    func removeImage(_ diary: Diary) {
        let storageRef = Storage.storage().reference().child("DiaryImages")
        for diaryImage in diary.diaryImageNames {
            storageRef.child(diaryImage).delete { error in
                if let error = error {
                    print("Error removing image from storage: \(error.localizedDescription)")
                }
            }
        }
    }
 
}
