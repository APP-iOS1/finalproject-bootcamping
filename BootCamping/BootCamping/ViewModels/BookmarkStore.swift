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
                    self.wholeAuthStore.readUserListCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - remove bookmark in Diary Combine
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
                    self.wholeAuthStore.readUserListCombine()
                    print("Finished remove bookmark in Diary")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Add bookmark to CampingSpot Combine
    func addBookmarkSpotCombine(campingSpotId: String) {
        FirebaseBookmarkService().addBookmarkSpotService(campingSpotId: campingSpotId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Add bookmark to CampingSpot")
                    return
                case .finished:
                    print("Finished Add bookmark to CampingSpot")
                    self.wholeAuthStore.readUserListCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - remove bookmark in CampingSpot Combine
    func removeBookmarkCampingSpotCombine(campingSpotId: String) {
        FirebaseBookmarkService().removeBookmarkSpotService(campingSpotId: campingSpotId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed remove bookmark in CampingSpot")
                    return
                case .finished:
                    self.wholeAuthStore.readUserListCombine()
                    print("Finished remove bookmark in CampingSpot")
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
    
    // MARK: - 북마크 된 캠핑장인지 확인하기
    func checkBookmarkedSpot(campingSpotId: String) -> Bool {
        if let currentUser = wholeAuthStore.currentUser {
            for user in wholeAuthStore.userList {
                if user.id == currentUser.uid {
                    if user.bookMarkedSpot.isEmpty { return false }
                    print(user.bookMarkedSpot)
                    print("camping id\(campingSpotId)")
                    if user.bookMarkedSpot.contains(campingSpotId) { return true }
                }
            }
        }
        return false
    }
}
