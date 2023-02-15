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
    
    @Published var blockedUsers: [String] = []
    
    let database = Firestore.firestore()

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: readUserListCombine 유저리스트 조회
    func readblockedUsersCombine() {
        FirebaseBlockedUserService().readBlockedUserService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    return
                case .finished:
                    print("Finished get Blocked Users")
                    return
                }
            } receiveValue: { [weak self] blockedUser in
                self?.blockedUsers = blockedUser
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Add Blocked User to Blocked User Combine
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
                    self.readblockedUsersCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    //MARK: - Add Blocked User to Blocked User Combine
    func addBlockedUserCombine(blockedUsers: [String]) {
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
                    self.readblockedUsersCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
//    //MARK: - remove Blocked User in Blocked User Combine
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
                    self.readblockedUsersCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
}

extension BlockedUserStore {
    // MARK: - 차단된 사용자인지 확인하기
    func checkBlockedUser(currentUser: Firebase.User?, userList: [User], blockedUserId: String) -> Bool {
        if let currentUser = currentUser {
            for user in userList {
                if user.id == currentUser.uid {
                    if user.blockedUser.isEmpty { return false }
                    print(user.blockedUser)
                    print("blocked user id\(blockedUserId)")
                    if user.blockedUser.contains(blockedUserId) { return true }
                }
            }
        }
        return false
    }
}
