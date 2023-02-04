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
    
    let wholeAuthStore = WholeAuthStore.shared
    
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
                    self.wholeAuthStore.readUserListCombine()
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
                    self.wholeAuthStore.readUserListCombine()
                    print("Finished remove bookmark in Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}

extension BookmarkStore{
    // MARK: - 북마크 된 다이어리인지 확인하기
    func checkBookmarkedDiary(diaryId: String) -> Bool {
        if let currentUser = wholeAuthStore.currentUser {
            for user in wholeAuthStore.userList {
                if user.id == currentUser.uid {
                    if user.bookMarkedDiaries.isEmpty { return false }
                    // TODO: - 자기가 쓴 다이어리도 북마크가 가능하게 할 것인가,, !
                    if user.bookMarkedDiaries.contains(diaryId) { return true }
                }
            }
        }
        return false
    }
}
