//
//  BlockedUserStore.swift
//  BootCamping
//
//  Created by 이소영 on 2023/02/09.
//

import Combine
import Firebase
import FirebaseFirestore
import FirebaseAuth

class BlockedUserStore: ObservableObject {

    let database = Firestore.firestore()

    private var cancellables = Set<AnyCancellable>()
    
    //MARK: - Add Blocked User to Blocked User Combine
    /// 해당 함수 호출 후 현재 유저의 정보를 업데이트 해주어야 한다
    /// -> wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!) 호출해주어야 한다
    func addBlockedUserCombine(blockedUserId: String) {
        FirebaseBlockedUserService().addBlockedUserService(blockedUserId: blockedUserId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Add Blocked User")
                    return
                case .finished:
                    print("Finished Add Blocked User")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Update Blocked User to Blocked User Combine
    /// 해당 함수 호출 후 현재 유저의 정보를 업데이트 해주어야 한다
    /// -> wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!) 호출해주어야 한다
    func updateBlockedUserCombine(blockedUsers: [String]) {
        FirebaseBlockedUserService().updateBlockedUserService(blockedUsers: blockedUsers)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed Update Blocked User")
                    return
                case .finished:
                    print("Finished Update Blocked User")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - remove Blocked User in Blocked User Combine
    /// ** 현재 사용되지 않는 함수
    /// 해당 함수 호출 후 현재 유저의 정보를 업데이트 해주어야 한다
    /// -> wholeAuthStore.readMyInfoCombine(user: wholeAuthStore.currnetUserInfo!) 호출해주어야 한다
    func removeBlockedUserCombine(blockedUserId: String) {
        FirebaseBlockedUserService().removeBlockedUserService(blockedUserId: blockedUserId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed remove Blocked User")
                    return
                case .finished:
                    print("Finished remove Blocked User")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}
