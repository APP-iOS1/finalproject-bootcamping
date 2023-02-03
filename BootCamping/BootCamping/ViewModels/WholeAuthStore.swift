//
//  WholeAuthStore.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/03.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import GoogleSignIn
import Combine

//Google 로그인의 로그인 및 로그아웃 상태에 대한 enum
enum SignInState {
    case splash
    case signIn
    case signOut
}

enum LogInState {
    case success
    case fail
    case none
}

enum LoginPlatform {
    case email
    case google
    case none
}


class WholeAuthStore: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var userList: [User]
    @Published var currentUser: Firebase.User?
    //인증 상태를 관리하는 변수
    @Published var state: SignInState = .splash
    @Published var loginState: LogInState = .none
    @Published var loginPlatform: LoginPlatform = .none
    
    @Published var firebaseUserServiceError: FirebaseUserServiceError = .badSnapshot
    @Published var showErrorAlertMessage: String = "오류"
    
    
    init() {
        currentUser = Auth.auth().currentUser
        userList = []
    }
    
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()

    static let shared = WholeAuthStore()
    
    // MARK: - UserList CRUD Combine

    // MARK: readUserListCombine 유저리스트 조회
    func readUserListCombine() {
        FirebaseUserService().readUserListService()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed get UserList")
                    self.firebaseUserServiceError = .badSnapshot
                    self.showErrorAlertMessage = self.firebaseUserServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished get UserList")
                    return
                }
            } receiveValue: { users in
                self.userList = users
            }
            .store(in: &cancellables)
    }
    
    func createUserCombine(user: User) {
        FirebaseUserService().createUserService(user: user)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed create User")
                    self.firebaseUserServiceError = .createUserListError
                    self.showErrorAlertMessage = self.firebaseUserServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished create User")
                    self.readUserListCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func updateUserCombine(image: Data, user: User) {
        FirebaseUserService().updateUserService(image: image, user: user)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed update User")
                    self.firebaseUserServiceError = .updateUserListError
                    self.showErrorAlertMessage = self.firebaseUserServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished update User")
                    self.readUserListCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    func deleteUserCombine(user: User) {
        FirebaseUserService().deleteUserService(user: user)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed delete User")
                    self.firebaseUserServiceError = .updateUserListError
                    self.showErrorAlertMessage = self.firebaseUserServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished delete User")
                    self.readUserListCombine()
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 이메일 로그인 (Sign up, Sign In, Sign Out, Checking)

    // MARK: checkUserEmailDuplicated 이메일 중복 체크
    func checkUserEmailDuplicated(userEmail: String) -> Bool {
        var state: Bool = true
        Future<Bool, Error> {  promise in
            self.database.collection("UserList").whereField("userEmail", isEqualTo: "\(userEmail)").getDocuments() { error, arg  in
                if let error = error {
                    print(error)
                    return
                }
            }
        }
        .eraseToAnyPublisher()
        .sink { _ in
            
        } receiveValue: { _ in
            
        }
        .store(in: &cancellables)
        
        return state
    }
    
    // MARK: checkAuthFormat 이메일 정합성 체크
    func checkAuthFormat(userEmail: String) -> Bool {
        let emailRegex = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        return userEmail.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    // MARK: checkPasswordFormat 비밀번호 정규식 체크
    func checkPasswordFormat(password: String, confirmPassword: String) -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&()_+=-]).{8,50}$"
        
        if password == confirmPassword {
            return password.range(of: passwordRegex, options: .regularExpression) != nil
        } else {
            return false
        }
    }
    
    // MARK: - 구글 로그인
    
    
    // MARK: - 카카오 로그인
    
    
    // MARK: - 애플 로그인
    


    
}
