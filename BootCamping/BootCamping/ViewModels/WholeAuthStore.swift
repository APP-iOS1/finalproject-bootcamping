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
import CryptoKit
import AuthenticationServices

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

enum LoginPlatform {
    case email
    case google
    case kakao
    case apple
    case none
}


class WholeAuthStore: ObservableObject {
    
    //로그인상태 저장
    @AppStorage("login") var isSignIn: Bool = false
    //로그인 진행상태
    @Published var isProcessing: Bool = false
    //유저리스트
    @Published var userList: [User]
    //현재 Auth 로그인 유저 정보
    @Published var currentUser: Firebase.User?
    //현재 로그인한 유저의 파이어스토어 정보
    @Published var currnetUserInfo: User?
    //로그인 플랫폼
    @Published var loginPlatform: LoginPlatform = .none
    //서비스 오류 존재여부  있으면 True 없으면 False
    @Published var isError: Bool = false
    //서비스 오류 상태 메세지
    @Published var showErrorAlertMessage: String = "오류"
    //파이어베이스 유저 서비스 오류
    @Published var firebaseUserServiceError: FirebaseUserServiceError = .badSnapshot
    //로그인 서비스 오류
    @Published var authServiceError: AuthServiceError = .emailDuplicated
    // 이메일 중복상태
    @Published var duplicatedEmailState: Bool = true
    //애플 로그인 Published
    @Published var nonce = ""
    
    init() {
        currentUser = Auth.auth().currentUser
        userList = []
        currnetUserInfo = userInit
    }
    
    let userInit: User = User(id: "", profileImageName: "", profileImageURL: "", nickName: "", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: [])
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
            } receiveValue: { [weak self] users in
                self.userList = users
            }
            .store(in: &cancellables)
    }
    
    //MARK: - readMyInfoCombine 현재유저 정보 조회
    func readMyInfoCombine(user: User) {
        FirebaseUserService().readMyInfoService(user: user)
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
            } receiveValue: { [weak self] user in
                self.currnetUserInfo = user
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
                    self.isError = true
                    self.isProcessing = false
                    return
                case .finished:
                    print("Finished create User")
                    self.getUserInfo(userUID: (Auth.auth().currentUser?.uid ?? "")) {
                        self.readUserListCombine()
                        if self.loginPlatform != .email {
                            withAnimation(.easeInOut) {
                                self.isError = false
                                self.isProcessing = false
                                self.isSignIn = true
                            }
                        } else {
                            self.isError = false
                            self.isProcessing = false
                        }
                    }
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }
    
    // MARK: updateUserCombine 유저 업데이트
    
    func updateUserCombine(image: Data?, user: User) {
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
                    self.getUserInfo(userUID: Auth.auth().currentUser?.uid ?? ""){
                        self.readUserListCombine()
                    }
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
    
    // MARK: - 통합 로그아웃
    func combineLogOut() {
        switch loginPlatform {
        case .email:
            self.authSignOut()
        case .apple:
            self.appleLogOut()
        case .google:
            self.googleSignOut()
        case .kakao:
            self.kakaoLogOutCombine()
        case .none:
            self.googleSignOut()
        }
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
                    print("Finished check User Email Duplicated")
                    return
                }
            } receiveValue: { [weak self] value in
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
                    self.loginPlatform = .none
                    self.isError = true
                    self.isProcessing = false
                    return
                case .finished:
                    print("Finished SingIn User")
                    return
                }
            } receiveValue: { [weak self] user in
                self.currentUser = user
                self.getUserInfo(userUID: user.uid) {
                    self.loginPlatform = .email
                    self.isProcessing = false
                    self.isError = false
                    withAnimation(.easeInOut) {
                        self.isSignIn = true
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: Auth LogOut
    
    func authSignOut() {
        
        do {
            try Auth.auth().signOut()
            self.isError = false
            self.loginPlatform = .email
            self.currentUser = nil
            self.currnetUserInfo = userInit
            withAnimation(.easeInOut) {
                self.isSignIn = false
            }

        } catch {
            print(#function, error.localizedDescription)
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            self.isError = true
        }
    }
    
    // MARK: Auth SignUp Combine
    
    func authSignUpCombine(nickName: String, userEmail: String, password: String, confirmPassword: String) {
        AuthEmailService().authSignUpService(userEmail: userEmail, password: password, confirmPassword: confirmPassword)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed SignUp User")
                    print(error)
                    self.authServiceError = .signUpError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    self.isError = true
                    self.isProcessing = false
                    return
                case .finished:
                    print("Finished SignUp User")
                    return
                }
            } receiveValue: { [weak self] userUID in
                self.loginPlatform = .email
                self.createUserCombine(user: User(id: userUID, profileImageName: "", profileImageURL: "", nickName: nickName, userEmail: userEmail, bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: []))
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
            self.loginPlatform = .none
            self.isError = true
            self.isProcessing = false
            return
        }
        
        // 2 user 인스턴스에서 idToken 과 accessToken을 받아온다
        // 인증
        /* 원래
         guard let authentication = user?.authentication, let idToken = authentication.idToken else { return }
         
         let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
         */
        
        guard let accessToken = user?.accessToken, let idToken = user?.idToken else {
            self.isError = true
            return
        }
        
        self.isProcessing = true

        let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString, accessToken: accessToken.tokenString)
        
        // 3
        Auth.auth().signIn(with: credential) { [unowned self] (result, error) in
            if let error = error {
                print(#function, error.localizedDescription)
                self.authServiceError = .signInError
                self.showErrorAlertMessage = self.authServiceError.errorDescription!
                self.loginPlatform = .none
                self.isError = true
                self.isProcessing = false
            } else {
                guard let result = result else { return }
                UserDefaults.standard.set(result.user.uid, forKey: "userIdToken")
                
                let query = database.collection("UserList").whereField("id", isEqualTo: (result.user.uid))
                query.getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error)
                    } else {
                        if snapshot?.documents.count == 0 {
                            print("파이어베이스에 저장된 유저정보가 없습니다.")
                            self.currentUser = result.user
                            self.loginPlatform = .google
                            self.createUserCombine(user: User(id: (result.user.uid), profileImageName: "", profileImageURL: "", nickName: (result.user.email!), userEmail: (result.user.email!), bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: []))
                        } else {
                            print("파이어베이스에 저장된 유저정보가 있습니다..")
                            self.currentUser = result.user
                            self.loginPlatform = .google
                            self.getUserInfo(userUID: result.user.uid) {
                                self.isError = false
                                self.isProcessing = false
                                self.loginPlatform = .google
                                withAnimation(.easeInOut) {
                                    self.isSignIn = true
                                }
                            }
                        }
                    }
                }
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
            self.isError = false
            self.loginPlatform = .none
            self.currentUser = nil
            self.currnetUserInfo = userInit
            withAnimation(.easeInOut) {
                self.isSignIn = false
            }
            
        } catch {
            print(#function, error.localizedDescription)
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            self.isError = true
        }
    }
    
    // MARK: - 카카오 로그인
    
    // MARK: 카카오 로그인
    func kakaoLogInCombine() {
        AuthKakaoService().kakaoLogInService()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed SignIn User")
                    print(error)
                    self.authServiceError = .signInError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    self.isError = true
                    self.isProcessing = false
                    return
                case .finished:
                    print("Finished SignIn User")
                    return
                }
            } receiveValue: { [weak self] user in
                self.isProcessing = true
                self.currentUser = user
                let query = self.database.collection("UserList").whereField("id", isEqualTo: (user.uid))
                query.getDocuments { (snapshot, error) in
                    if let error = error {
                        print(error)
                        self.isProcessing = false
                        self.isError = true
                    }
                    if let error = error {
                        print(error)
                        self.isProcessing = false
                        self.isError = true
                    } else {
                        if snapshot?.documents.count == 0 {
                            print("파이어베이스에 유저정보가 없습니다.")
                            self.loginPlatform = .kakao
                            self.createUserCombine(user: User(id: (user.uid), profileImageName: "", profileImageURL: "", nickName: (user.email)!, userEmail: (user.email!), bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: []))
                        } else {
                            print("파이어베이스에 유저정보가 있습니다..")
                            self.getUserInfo(userUID: user.uid) {
                                self.loginPlatform = .kakao
                                withAnimation(.easeInOut) {
                                    self.isSignIn = true
                                    self.isError = false
                                    self.isProcessing = false
                                }
                            }
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: 카카오 로그아웃
    
    func kakaoLogOutCombine() {
        AuthKakaoService().kakaoLogOutService()
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed LogOut User")
                    print(error)
                    self.authServiceError = .signInError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    self.isError = true

                    return
                case .finished:
                    print("Finished LogOut User")
                    self.loginPlatform = .none
                    self.currentUser = nil
                    self.currnetUserInfo = self.userInit
                    withAnimation(.easeInOut) {
                        self.isSignIn = false
                    }
                    self.isError = false
                    return
                }
            } receiveValue: { _ in
                
            }
            .store(in: &cancellables)
    }

    
    // MARK: - 애플 로그인
    
    func appleLogin(credential: ASAuthorizationAppleIDCredential) {
        // getting Token...
        guard let token = credential.identityToken else {
            print("error with firebase")
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            self.isError = true
            self.isProcessing = false
            return
        }
        // Token Stirng...
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            return
        }
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        self.isProcessing = true
        
        Auth.auth().signIn(with: firebaseCredential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                self.authServiceError = .signOutError
                self.showErrorAlertMessage = self.authServiceError.errorDescription!
                self.isError = true
                self.isProcessing = false
                return
            }
            // User Successfully Logged Into Firebase
            print("Logged In success")
            
            
            
            let query = self.database.collection("UserList").whereField("id", isEqualTo: (result?.user.uid)!)
            query.getDocuments { (snapshot, error) in
                
                if let error = error {
                    print(error)
                    self.authServiceError = .signOutError
                    self.showErrorAlertMessage = self.authServiceError.errorDescription!
                    self.isError = true
                    self.isProcessing = false
                    return
                } else {
                    if snapshot?.documents.count == 0 {
                        print("파이어베이스에 유저정보가 없습니다.")
                        self.currentUser = result?.user
                        self.loginPlatform = .apple
                        self.createUserCombine(user: User(id: (result?.user.uid)!, profileImageName: "", profileImageURL: "", nickName: String(describing: (result?.user.email)!), userEmail: String(describing: (result?.user.email)!), bookMarkedDiaries: [], bookMarkedSpot: [], blockedUser: []))
                    } else {
                        print("파이어베이스에 유저정보가 있습니다..")
                        self.getUserInfo(userUID: (result?.user.uid)!) {
                            self.currentUser = result?.user
                            self.loginPlatform = .apple
                            self.isError = false
                            self.isProcessing = false
                            withAnimation(.easeInOut) {
                                self.isSignIn = true
                            }
                        }
                    }
                }
            }
            
            // Directing User To Hom page...

        }
    }
    
    func appleLogOut() {
        do {
            try Auth.auth().signOut()
            
            self.loginPlatform = .none
            self.currentUser = nil
            self.currnetUserInfo = userInit
            withAnimation(.easeInOut) {
                self.isSignIn = false
            }
            self.isError = false
            
        } catch {
            print(#function, error.localizedDescription)
            self.authServiceError = .signOutError
            self.showErrorAlertMessage = self.authServiceError.errorDescription!
            self.isError = true
        }
    }
    
    // MARK: - 회원탈퇴
    
    func userWithdrawal() {

        Auth.auth().currentUser?.delete { error in
            if let error = error {
                print(error)
                print("회원 삭제 실패")
            } else {
                print("회원 삭제 성공")
                self.database.collection("UserList")
                    .document((self.currentUser?.uid)!).delete() { error in
                        if let error = error {
                            print(error)
                        }
                        print("파이어베이스 유저 삭제 성공")
                        self.loginPlatform = .none
                        self.currentUser = nil
                        self.currnetUserInfo = self.userInit
                        withAnimation(.easeInOut) {
                            self.isSignIn = false
                        }
                    }
            }
        }
    }


    
    // MARK: - 파이어베이스 유저 정보 읽기

    func getUserInfo(userUID: String, completion: @escaping () -> ()) {
        if userUID != "" {
            let database = Firestore.firestore()
            database.collection("UserList").document(userUID).getDocument { document, error in
                if let error = error {
                    print(error)
                    return
                }
                guard let document = document else { return }
                
                let docData = document.data()
                
                let id: String = docData?["id"] as? String ?? ""
                let profileImageName: String = docData?["profileImageName"] as? String ?? ""
                let profileImageURL: String = docData?["profileImageURL"] as? String ?? ""
                let nickName: String = docData?["nickName"] as? String ?? ""
                let userEmail: String = docData?["userEmail"] as? String ?? ""
                let bookMarkedDiaries: [String] = docData?["bookMarkedDiaries"] as? [String] ?? []
                let bookMarkedSpot: [String] = docData?["bookMarkedSpot"] as? [String] ?? []
                let blockedUser: [String] = docData?["blockedUser"] as? [String] ?? []
                let user: User = User(id: id, profileImageName: profileImageName, profileImageURL: profileImageURL, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries, bookMarkedSpot: bookMarkedSpot, blockedUser: blockedUser)
                self.currnetUserInfo = user
                completion()
            }
        } else {
            completion()
        }
    }
}

// MARK: - 애플 로그인 함수
func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: Array<Character> =
    Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    
    while remainingLength > 0 {
        let randoms: [UInt8] = (0 ..< 16).map { _ in
            var random: UInt8 = 0
            let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
            if errorCode != errSecSuccess {
                fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
            }
            return random
        }
        
        randoms.forEach { random in
            if remainingLength == 0 {
                return
            }
            
            if random < charset.count {
                result.append(charset[Int(random)])
                remainingLength -= 1
            }
        }
    }
    
    return result
}

func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
    }.joined()
    
    return hashString
}


// 회원 탈퇴시키려면 어스 삭제, 파베 삭제

//func deletegg() {
//    Auth.auth().currentUser?.delete { error in
//        if let error = error {
//            print(error)
//        } else {
//            print("삭제 성공")
//        }
//    }
//
//}
//
//func 파베에user저장되있어?() {
//    let database = Firestore.firestore()
//
//    let query = self.database.collection("UserList").whereField("id", isEqualTo: "야호오옹")
//    query.getDocuments { snapshot, error in
//        if let error = error {
//            print(error)
//        } else {
//            if snapshot?.documents.count == 0 {
//                print("없댕")
//            } else {
//                print("잇댕")
//            }
//        }
//    }
//}
// 파베에서 현재 유저 찾는법
// 1. uid가 있음
// 2. 경로에 정보 있는거 읽어오자
