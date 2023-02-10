//
//  BlockedUserStore.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import Combine
import Firebase

class BlockedUserStore: ObservableObject {
    
    let database = Firestore.firestore()

    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Add Blocked User to Blocked User Combine
    func addBlockedUserCombine(blockedUserId: String) {
        FirebaseBlockedUserService().addBlockedUserService(blockedUserId: blockedUserId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Add Block User")
                    return
                case .finished:
                    print("Finished Add Block User")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
//    //MARK: - remove Blocked User in Blocked User Combine
//    func removeBlockedUserCombine(diaryId: String) {
//        FirebaseBookmarkService().removeBookmarkDiaryService(diaryId: diaryId)
//            .receive(on: DispatchQueue.main)
//            .sink { completion in
//                switch completion {
//                case .failure(let error):
//                    print(error)
//                    print("Failed remove bookmark in Diary")
//                    return
//                case .finished:
//                    print("Finished remove bookmark in Diary")
//                    return
//                }
//            } receiveValue: { _ in
//                
//            }
//            .store(in: &cancellables)
//    }
    
}
