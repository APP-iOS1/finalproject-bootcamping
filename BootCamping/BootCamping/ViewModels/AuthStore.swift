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

class AuthStore: ObservableObject {
    
    @Published var isLogin: Bool = false
    @Published var userList: [User]
    @Published var currentUser: Firebase.User?
    
    init() {
        currentUser = Auth.auth().currentUser
        userList = []
    }
    
    let database = Firestore.firestore()
    
    func testFunc(test: String) -> String {
        return test
    }
    
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
    func checkUserEmailDuplicated(userEmail: String) async throws -> Bool {
        do {
            let result = try await database.collection("UserList").whereField("userEmail", isEqualTo: "\(userEmail)").getDocuments()
            print(#function, result)
            return !(result.isEmpty)
        } catch {
            print(error)
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
            print(password, confirmPassword)
            return false
        }
    }
    
    // MARK: - authSignIn 로그인 함수
    func authSignIn(userEmail: String, password: String) async throws {
        
        do {
            let result = try await Auth.auth().signIn(withEmail: userEmail, password: password)
            print("Successfully logged in as user: \(result.user.uid)")
            self.currentUser = result.user
            self.isLogin = true
        } catch {
            print(error)
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
}
