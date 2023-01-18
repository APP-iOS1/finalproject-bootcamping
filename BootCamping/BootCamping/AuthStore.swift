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
        userList = []
    }
    
    let database = Firestore.firestore()
    
    func testFunc(test: String) -> String {
        return test
    }
    
    // MARK: -checkUserEmailDuplicated 이메일 중복 체크
    func checkUserEmailDuplicated(userEmail: String) async throws -> Bool {
        do {
            let result = try await database.collection("UserList").whereField("userEmail", isEqualTo: "\(userEmail)").getDocuments()
            return !(result.isEmpty)
        } catch {
            print(error)
            return false
        }
    }
    
    // MARK: -checkAuthFormat 이메일 정합성 체크
    func checkAuthFormat(userEmail: String) -> Bool {
        let emailRegex = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        return userEmail.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    // MARK: -checkPasswordFormat 비밀번호 정규식 체크
    func checkPasswordFormat(password: String, confirmPassword: String) -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&()_+=-]).{8,50}$"
        
        if password == confirmPassword {
            return password.range(of: passwordRegex, options: .regularExpression) != nil
        } else {
            print(password, confirmPassword)
            return false
        }
    }
    
    func authSignIn(userEmail: String, password: String) async {

        do {
            await Auth.auth().signIn(withEmail: userEmail, password: password) { result, _ in
                print("Successfully logged in as user: \(result?.user.uid ?? "")")
                self.currentUser = result?.user
                self.isLogin = true
            }
        } catch {
            print(error)
        }
    }
    
    func authSignOut() {
        self.currentUser = nil
        self.isLogin = false
        try? Auth.auth().signOut()
    }
    
    
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
}
