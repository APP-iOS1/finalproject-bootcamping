//
//  DiaryLIkeStore.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/08.
//


import Combine
import Firebase


class DiaryLikeStore: ObservableObject {
    //저장된 다이어리 리스트
    //TODO: 싱글톤에서 environment로 수정
    let diaryStore = DiaryStore.shared
    
    //파베 기본 경로
    let database = Firestore.firestore()
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Add bookmark to Diary Combine
    func addDiaryLikeCombine(diaryId: String) {
        FirebaseDiaryLikeService().addDiaryLikeService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Add diaryLike to Diary")
                    return
                case .finished:
                    print("Finished Add diaryLike to Diary")
                    //TODO: -다이어리 패치
                    self.diaryStore.readDiarysCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - remove bookmark in Diary Combine
    func removeDiaryLikeCombine(diaryId: String) {
        FirebaseDiaryLikeService().removeDiaryLikeService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed remove diaryLike in Diary")
                    return
                case .finished:
                    print("Finished remove diaryLike in Diary")
                    //TODO: -다이어리 패치
                    self.diaryStore.readDiarysCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}
