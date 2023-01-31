//
//  AuthStore.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI
import GoogleSignIn

class AuthStore: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var userList: [User]
    @Published var currentUser: Firebase.User?
    
    init() {
        currentUser = Auth.auth().currentUser
        userList = []
    }
    
    let database = Firestore.firestore()
    
    static let shared = AuthStore()
    
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
    
    //인증 상태를 관리하는 변수
    @Published var state: SignInState = .splash
    @Published var loginState: LogInState = .none
    @Published var loginPlatform: LoginPlatform = .none
    
    // MARK: - fecthUserList 유저리스트 조회
    func fetchUserList() {
        database.collection("UserList").getDocuments { (snapshot, error) in
            self.userList.removeAll()
            
            if let snapshot {
                for document in snapshot.documents {
                    let id: String = document.documentID
                    let docData = document.data()
                    let profileImage: String = docData["profileImage"] as? String ?? ""
                    let nickName: String = docData["nickName"] as? String ?? ""
                    let userEmail: String = docData["userEmail"] as? String ?? ""
                    let bookMarkedDiaries: [String] = docData["bookMarkedDiaries"] as? [String] ?? []
                    
                    let user: User = User(id: id, profileImage: profileImage, nickName: nickName, userEmail: userEmail, bookMarkedDiaries: bookMarkedDiaries)
                    self.userList.append(user)
                }
            }
        }
    }
    
    // MARK: - checkUserEmailDuplicated 이메일 중복 체크
    /// true = 중복됨
    /// false = 중복 안됨
    func checkUserEmailDuplicated(userEmail: String) async -> Bool {
        do {
            let result = try await database.collection("UserList").whereField("userEmail", isEqualTo: "\(userEmail)").getDocuments()
            print(#function, result)
            return !(result.isEmpty)
        } catch {
            print(#function, error)
            return false
        }
    }
    
    // MARK: - checkAuthFormat 이메일 정합성 체크
    func checkAuthFormat(userEmail: String) -> Bool {
        let emailRegex = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        return userEmail.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    // MARK: - checkPasswordFormat 비밀번호 정규식 체크
    func checkPasswordFormat(password: String, confirmPassword: String) -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&()_+=-]).{8,50}$"
        
        if password == confirmPassword {
            return password.range(of: passwordRegex, options: .regularExpression) != nil
        } else {
            print(#function, password, confirmPassword)
            return false
        }
    }
    
    // MARK: - authSignIn 로그인 함수
    func authSignIn(userEmail: String, password: String) async throws {
        
        do {
            let result = try await Auth.auth().signIn(withEmail: userEmail, password: password)
            print(#function, "Successfully logged in as user: \(result.user.uid)")
            self.currentUser = result.user
            self.isLogin = true
        } catch {
            print(#function, error)
        }
    }
    
    // MARK: - authSignOut 로그아웃 함수
    func authSignOut() {
        self.currentUser = nil
        self.isLogin = false
        try? Auth.auth().signOut()
    }
    
    // MARK: - authSignUp 회원가입 함수
    /// password와 이메일의 정규식 체크 후 참일 경우 회원가입 실행
    func authSignUp(userEmail: String, password: String, confirmPassword: String) async throws -> Bool {
        if checkPasswordFormat(password: password, confirmPassword: confirmPassword) && checkAuthFormat(userEmail: userEmail) {
            do {
                try await Auth.auth().createUser(withEmail: userEmail, password: password)
                print(#function, "password: \(password), confirmPassword: \(confirmPassword), email: \(userEmail)")
                return true
            } catch {
                return false
            }
        } else {
            return false
        }
    }
    
    // MARK: - 유저리스트에 추가하는 함수
    func addUserList(_ user: User) {
        database.collection("UserList").document(user.id).setData([
            "id": user.id,
            "profileImage": user.profileImage,
            "nickName": user.nickName,
            "userEmail": user.userEmail,
            "bookMarkedDiaries": user.bookMarkedDiaries,
        ])
        fetchUserList()
    }
        
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
    //TODO: -함수 이름 써주세요~
    private func authenticateUser(for user: GIDGoogleUser?, with error: Error?) {
        // 1
        if let error = error {
            print(#function, error.localizedDescription)
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
            } else {
                UserDefaults.standard.set(result?.user.uid, forKey: "userIdToken")
                self.state = .signIn
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
            
            state = .signOut
            loginState = .none
            
        } catch {
            print(#function, error.localizedDescription)
        }
    }
}
