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
    
    //서비스 오류 상태
    @Published var showErrorAlertMessage: String = "오류"

    //파이어베이스 서비스 오류
    @Published var firebaseUserServiceError: FirebaseUserServiceError = .badSnapshot
    
    //이메일 서비스 오류
    @Published var authImailLoginServiceError: AuthImailLoginServiceError = .emailDuplicated
    
    // 이메일 중복상태
    @Published var duplicatedEmailState: Bool = true
    
    init() {
        currentUser = Auth.auth().currentUser
        userList = []
    }
    
    let database = Firestore.firestore()
    
    private var cancellables = Set<AnyCancellable>()

    static let shared = WholeAuthStore()
    
    // MARK: - Firebase UserList CRUD Combine

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
    
    // MARK: createUserCombine 유저 생성

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
    
    // MARK: updateUserCombine 유저 업데이트
    
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
    
    // MARK: deleteUserCombine 유저 삭제

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
    
    /// true = 중복됨
    /// false = 중복 안됨

    func checkUserEmailDuplicatedCombine(userEmail: String){
        AuthImailLoginService().checkUserEmailDuplicatedService(userEmail: userEmail)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    self.duplicatedEmailState = true
                    return
                case .finished:
                    print("Finished delete User")
                    return
                }
            } receiveValue: { value in
                self.duplicatedEmailState = value
            }
            .store(in: &cancellables)
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
    
    // MARK: Auth SignIn Combine

    func authSignInCombine(userEmail: String, password: String) {
        AuthImailLoginService().authSignInService(userEmail: userEmail, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed SingUp User")
                    self.authImailLoginServiceError = .signInError
                    self.showErrorAlertMessage = self.authImailLoginServiceError.errorDescription!
                    self.isLogin = false
                    return
                case .finished:
                    print("Finished SingIn User")
                    self.isLogin = true
                    return
                }
            } receiveValue: { user in
                self.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    // MARK: Auth LogOut
    
    func authSignOut() {
        try? Auth.auth().signOut()
        self.isLogin = false
        self.currentUser = Auth.auth().currentUser
    }
    
    // MARK: Auth SignUp Combine
    
    func authSignUpCombine(userEmail: String, password: String, confirmPassword: String) {
        AuthImailLoginService().authSignUpService(userEmail: userEmail, password: password, confirmPassword: confirmPassword)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed SingUp User")
                    print(error)
                    self.authImailLoginServiceError = .signUpError
                    self.showErrorAlertMessage = self.authImailLoginServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished SingUp User")
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 구글 로그인
    
    
    // MARK: - 카카오 로그인
    
    
    // MARK: - 애플 로그인
    


    
}
