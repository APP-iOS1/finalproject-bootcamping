//
//  DiaryLIkeStore.swift
//  BootCamping
//
//  Created by Deokhun KIM on 2023/02/08.
//


import Combine
import Firebase


class DiaryLikeStore: ObservableObject {
    //저장된 다이어리 라이크
    @Published var diaryLikeList: [String] = [] //유저 UID
    //파베 기본 경로
    let database = Firestore.firestore()
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Add diaryLike Combine
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
                    self.readDiaryLikeCombine(diaryId: diaryId)
                     return
                }
            } receiveValue: { _ in

            }
            .store(in: &cancellables)
    }
    
    //MARK: - Read diaryLike Combine
    func readDiaryLikeCombine(diaryId: String) {
        FirebaseDiaryLikeService().readDiaryLikeService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get diaryLikes")
                    return
                case .finished:
                    print("Finished get diaryLike")
                    return
                }
            } receiveValue: { [weak self] diaryLikeValue in
                self?.diaryLikeList = diaryLikeValue
            }
            .store(in: &cancellables)
    }
    
    //MARK: - remove diaryLike in Diary Combine
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
                    self.readDiaryLikeCombine(diaryId: diaryId)
                    print("Finished remove diaryLike in Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}
