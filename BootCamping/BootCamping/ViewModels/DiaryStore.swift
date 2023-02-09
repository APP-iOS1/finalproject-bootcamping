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

}
