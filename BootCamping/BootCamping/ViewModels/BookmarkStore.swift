//
//  BookmarkStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/03.
//

import Combine
import Firebase


class BookmarkStore: ObservableObject {
    //저장된 다이어리 리스트
    @Published var firebaseBookmarkDiaryServiceError: FirebaseBookmarkDiaryServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    
    //파베 기본 경로
    let database = Firestore.firestore()
    
    //
    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Add bookmark to Diary Combine
    func addBookmarkDiaryCombine(diaryId: String) {
        FirebaseBookmarkService().addBookmarkDiaryService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Add bookmark to Diary")
                    return
                case .finished:
                    print("Finished Add bookmark to Diary")
                    // TODO: - fetch,,
                    /// 현재 로그인된 유저의 데이터를 가져오는 게 bookmark에서의 fetch,, !
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: remove bookmark in Diary Combine
    
    func removeBookmarkDiaryCombine(diaryId: String) {
        FirebaseBookmarkService().removeBookmarkDiaryService(diaryId: diaryId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed remove bookmark in Diary")
                    return
                case .finished:
                    // TODO: - fetch,,
                    /// 현재 로그인된 유저의 데이터를 가져오는 게 bookmark에서의 fetch,, !
                    print("Finished remove bookmark in Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}
