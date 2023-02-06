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

enum AuthServiceError: Error {
    case emailDuplicated
    case signInError
    case signUpError
    case signOutError
    
    var errorDescription: String? {
        switch self {
        case .emailDuplicated:
            return "중복된 이메일 입니다."
        case .signInError:
            return "로그인에 실패하였습니다."
        case .signOutError:
            return "로그아웃에 실패하였습니다."
        case .signUpError:
            return "회원가입에 실패하였습니다."
        }
    }
}

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

    //파이어베이스 유저 서비스 오류
    @Published var firebaseUserServiceError: FirebaseUserServiceError = .badSnapshot
    
    //로그인 서비스 오류
    @Published var authServiceError: AuthServiceError = .emailDuplicated
    
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
        AuthEmailService().checkUserEmailDuplicatedService(userEmail: userEmail)
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
        AuthEmailService().authSignInService(userEmail: userEmail, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error)
                    print("Failed SingUp User")
                    self.authServiceError = .signInError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    self.loginState = .fail
                    self.loginPlatform = .none
                    return
                case .finished:
                    print("Finished SingIn User")
                    self.isLogin = true
                    self.state = .signIn
                    self.loginState = .success
                    self.loginPlatform = .email
                    return
                }
            } receiveValue: { user in
                self.currentUser = user
            }
            .store(in: &cancellables)
    }
    
    // MARK: Auth LogOut
    
    func authSignOut() {
        
        do {
            try Auth.auth().signOut()
            self.isLogin = false
            self.state = .signOut
            self.loginState = .none
            self.loginPlatform = .email
            self.currentUser = nil
        } catch {
            print(#function, error.localizedDescription)
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
        }
    }
    
    // MARK: Auth SignUp Combine
    
    func authSignUpCombine(nickName: String, userEmail: String, password: String, confirmPassword: String) {
        AuthEmailService().authSignUpService(userEmail: userEmail, password: password, confirmPassword: confirmPassword)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed SingUp User")
                    print(error)
                    self.authServiceError = .signUpError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    return
                case .finished:
                    print("Finished SingUp User")
                    return
                }
            } receiveValue: { userUID in
                self.createUserCombine(user: User(id: userUID, profileImageName: "", profileImageURL: "", nickName: nickName, userEmail: userEmail, bookMarkedDiaries: [], bookMarkedSpot: []))
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 구글 로그인
    
    // MARK: 구글 로그인 함수
    func googleSignIn() {
        // 한번 로그인한 적이 있음(previous Sign-In ?)
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            // 있으면 복원 (yes then restore)
            GIDSignIn.sharedInstance.restorePreviousSignIn { [unowned self] user, error in
                authenticateUser(for: user, with: error)
                
            }
        } else {// 처음 로그인
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            
            // 3
            let configuration = GIDConfiguration(clientID: clientID)
            
            // 4 .first 맨 위에 뜨게 하도록
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.configuration = configuration
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [unowned self] result, error in
                guard let user = result?.user else { return }
                authenticateUser(for: user, with: error)
                
            }
            
        }
    }
    
    //MARK: 구글 인증 함수
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1
        if let error = error {
            print(#function, error.localizedDescription)
            self.authServiceError = .signInError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            self.isLogin = false
            self.loginState = .fail
            self.loginPlatform = .none
            return
        }
        
        // 2 user 인스턴스에서 idToken 과 accessToken을 받아온다
        // 인증
        /* 원래
         guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
         
         let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
         */
        
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else {return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        // 3
        Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
            if let error = error {
                print(#function, error.localizedDescription)
                self.authServiceError = .signInError
                self.showErrorAlertMessage = self.authServiceError.errorDescription!
                self.isLogin = false
                self.loginState = .fail
                self.loginPlatform = .none
            } else {
                UserDefaults.standard.set(result?.user.uid, forKey: "userIdToken")
                self.createUserCombine(user: User(id: (result?.user.uid)!, profileImageName: "", profileImageURL: "", nickName: (result?.user.uid)!, userEmail: (result?.user.uid)!, bookMarkedDiaries: [], bookMarkedSpot: []))
                self.currentUser = result?.user
                self.isLogin = true
                self.state = .signIn
                self.loginState = .success
                self.loginPlatform = .google
            }
        }
    }
    
    // MARK: 구글 로그아웃 함수
    func googleSignOut() {
        // 1
        GIDSignIn.sharedInstance.signOut()
        
        do {
            // 2
            try Auth.auth().signOut()
            
            self.isLogin = false
            self.state = .signOut
            self.loginState = .none
            self.loginPlatform = .none
            
        } catch {
            print(#function, error.localizedDescription)
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
        }
    }
    
    // MARK: - 카카오 로그인
    
    
    // MARK: - 애플 로그인
    
}
