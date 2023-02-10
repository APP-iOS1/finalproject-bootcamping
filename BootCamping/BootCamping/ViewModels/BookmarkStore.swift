//
//  BookmarkStore.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/03.
//

import Combine
import Firebase


class BookmarkStore: ObservableObject {
    
    //파베 기본 경로
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()
    
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
                    print("Finished remove bookmark in CampingSpot")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
}

extension BookmarkStore{
    // MARK: - 북마크 된 캠핑장인지 확인하기
    func checkBookmarkedSpot(currentUser: Firebase.User?, userList: [User], campingSpotId: String) -> Bool {
        if let currentUser = currentUser {
            for user in userList {
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
