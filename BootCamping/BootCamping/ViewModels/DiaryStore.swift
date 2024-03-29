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

// MARK: - 다이어리 정보를 가지고 있는 스토어

class DiaryStore: ObservableObject {
    //저장된 다이어리 리스트
    @Published var diaryList: [Diary] = []
    @Published var firebaseDiaryServiceError: FirebaseDiaryServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    // 다이어리 CRUD 진행상태
    @Published var isProcessing: Bool = false
    // 다이어리 에러 상태
    @Published var isError: Bool = false
    
    // 내 다이어리 마지막 다큐먼트
    @Published var myDiarylastDoc: QueryDocumentSnapshot?
    // 내 다이어리 뷰 유저 및 다이어리 정보
    @Published var myDiaryUserInfoDiaryList: [UserInfoDiary] = []
    
    // 실시간 다이어리 마지막 다큐먼트
    @Published var realTimeDiarylastDoc: QueryDocumentSnapshot?
    // 실시간 다이어리 뷰 유저 및 다이어리 정보
    @Published var realTimeDiaryUserInfoDiaryList: [UserInfoDiary] = []
    
    // 인기글 다이어리 뷰 유저 및 다이어리 정보
    @Published var popularDiaryList: [UserInfoDiary] = []
    
    // 다이어리 생성함수 상태 변화에따라 뷰의 온체인지 함수 기능 작동
    @Published var createFinshed: Bool = false
    
    //댓글 눌렀을때
    @Published var isCommentButtonClicked: Bool = false
    
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
                    self.isProcessing = false
                    self.isError = false
                    return
                case .finished:
                    print("Finished Create Diary")
                    self.createFinshed.toggle()
                    self.isProcessing = false
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Update Diary Combine
    
    func updateDiaryCombine(diary: Diary) {
        FirebaseDiaryService().updateDiarysService(diary: diary)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Update Diary")
                    self.firebaseDiaryServiceError = .updateDiaryError
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                    self.isProcessing = false
                    self.isError = false
                    return
                case .finished:
                    print("Finished Update Diary")
                    self.createFinshed.toggle()
                    self.isProcessing = false
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: updateUserDiaryCombine 유저 업데이트
    
    func updateDiarysNickNameCombine(userUID: String, nickName: String) {
        FirebaseDiaryService().updateDiarysNickNameService(userUID: userUID, nickName: nickName)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed update Diary Nickname")
                    self.firebaseDiaryServiceError = .updateDiaryError
                    self.showErrorAlertMessage = self.firebaseDiaryServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished update Diary Nickname")
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
                    self.firstGetMyDiaryCombine()
                    self.firstGetRealTimeDiaryCombine()
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
                    self.firstGetMyDiaryCombine()
                    self.firstGetRealTimeDiaryCombine()
                    print("Finished Delete Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }  
    //MARK: - 내 다이어리 불러오기 함수
    
    // 첫번째 불러오기 함수
    func firstGetMyDiaryCombine() {
        FirebaseDiaryService().firstGetMyDiaryService()
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
            } receiveValue: { [weak self] mylastDocWithDiaryList in
                self?.myDiarylastDoc = mylastDocWithDiaryList.lastDoc
                self?.myDiaryUserInfoDiaryList = mylastDocWithDiaryList.userInfoDiarys
            }
            .store(in: &cancellables)
    }
    
    func nextGetMyDiaryCombine() {
        FirebaseDiaryService().nextGetMyDiaryService(lastDoc: self.myDiarylastDoc)
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
            } receiveValue: { [weak self] mylastDocWithDiaryList in
                self?.myDiarylastDoc = mylastDocWithDiaryList.lastDoc
                self?.myDiaryUserInfoDiaryList.append(contentsOf: mylastDocWithDiaryList.userInfoDiarys)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 실시간 다이어리 불러오기 함수
    
    // 첫번째 불러오기 함수
    func firstGetRealTimeDiaryCombine() {
        FirebaseDiaryService().firstGetRealTimeDiaryService()
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
            } receiveValue: { [weak self] realTimelastDocWithDiaryList in
                self?.realTimeDiarylastDoc = realTimelastDocWithDiaryList.lastDoc
                self?.realTimeDiaryUserInfoDiaryList = realTimelastDocWithDiaryList.userInfoDiarys
            }
            .store(in: &cancellables)
    }
    
    func nextGetRealtimeDiaryCombine() {
        FirebaseDiaryService().nextGetRealTimeDiaryService(lastDoc: self.realTimeDiarylastDoc)
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
            } receiveValue: { [weak self] realTimelastDocWithDiaryList in
                self?.realTimeDiarylastDoc = realTimelastDocWithDiaryList.lastDoc
                self?.realTimeDiaryUserInfoDiaryList.append(contentsOf: realTimelastDocWithDiaryList.userInfoDiarys)
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 좋아요 많은 다이어리 불러오기 함수
    
    func mostLikedGetDiarysCombine() {
        FirebaseDiaryService().mostLikedGetDiarysService()
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
                    print("\(self.popularDiaryList.count)")
                    return
                }
            } receiveValue: { [weak self] popularList in
                let sortedArray = popularList.sorted{ $0.diary.diaryLike.count > $1.diary.diaryLike.count}
                self?.popularDiaryList = sortedArray
            }
            .store(in: &cancellables)
    }
    
    //MARK: - 캠핑장 디테일뷰에 들어갈 노트 Read하는 함수
    
    func readCampingSpotsDiariesCombine(contentId: String) {
        FirebaseDiaryService().readCampingSpotsDiariesService(contentId: contentId)
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

            } receiveValue: { [weak self] realTimelastDocWithDiaryList in
                self?.realTimeDiaryUserInfoDiaryList = realTimelastDocWithDiaryList.userInfoDiarys
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
