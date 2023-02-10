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
    // 다이어리 CRUD 진행상태
    @Published var isProcessing: Bool = false
    // 다이어리 에러 상태
    @Published var isError: Bool = false
    // 마지막 다큐먼트
    @Published var lastDoc: QueryDocumentSnapshot?
    // 개선된 다이어리 리스트
    @Published var userInfoDiaryList: [UserInfoDiary] = []
    //파베 기본 경로
    let database = Firestore.firestore()
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    //TODO: -싱글톤에서 enviroment로 바꾸기
    static var shared = DiaryStore()
    
    //MARK: - Read Diary Combine
    
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
    
    
    //MARK: - Create Diary Combine
    
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
    
    //MARK: - Update Diary Combine
    
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
    
    //MARK: - update IsPrivate Diary Combine
    
    func updateIsPrivateDiaryCombine(diaryId: String, isPrivate: Bool) {
        FirebaseDiaryService().updateIsPrivateDiaryService(diaryId: diaryId, isPrivate: isPrivate)
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
    
    //MARK: - Delete Diary Combine
    
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
    
    //MARK: - 실시간 다이어리 불러오기 함수
    
    // 첫번째 불러오기 함수
    func firstGetDiaryCombine() {
        FirebaseDiaryService().firstGetDiaryService()
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
            } receiveValue: { [weak self] lastDocWithDiaryList in
                self?.lastDoc = lastDocWithDiaryList.lastDoc
                self?.userInfoDiaryList = lastDocWithDiaryList.userInfoDiarys
            }
            .store(in: &cancellables)
    }
    
    func nextGetDiaryCombine() {
        FirebaseDiaryService().nextGetDiaryService(lastDoc: self.lastDoc)
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
            } receiveValue: { [weak self] lastDocWithDiaryList in
                self?.lastDoc = lastDocWithDiaryList.lastDoc
                self?.userInfoDiaryList.append(contentsOf: lastDocWithDiaryList.userInfoDiarys)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 캠핑장 디테일뷰에 들어갈 일기 Read하는 함수
    
    func readCampingSpotsDiarysCombine(contentId: String) {
        FirebaseDiaryService().readCampingSpotsDiarysService(contentId: contentId)
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
    
    // 다음불러오기 함수
    
    
    
    // 다이어리 다큐먼트 20개 가져오기 20번돌리고
    // 페이지네이션은 동훈님꺼 보자
    // 다큐먼트 1개가져오고 > 이것 유아이디로 유저데이터 불러와야함. 데이터 불러오면 같이 나가야되는데
    //

    // 내 다이어리 페이지네이션, 리스너 추가만들기

}
