//
//  AuthImailLoginService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/03.
//

import Foundation
import Firebase
import FirebaseFirestore
import SwiftUI
import FirebaseAuth
import Combine

struct AuthEmailService {
    
    let database = Firestore.firestore()
    
    // MARK: - checkPasswordFormat 비밀번호 정규식 체크
    func checkPasswordFormat(password: String, confirmPassword: String) -> Bool {
        let passwordRegex = "^(?=.*[a-zA-Z])(?=.*[0-9])(?=.*[!@#$%^&()_+=-]).{8,50}$"
        
        if password == confirmPassword {
            return password.range(of: passwordRegex, options: .regularExpression) != nil
        } else {
            return false
        }
    }
    // MARK: - checkAuthFormat 이메일 정합성 체크
    func checkAuthFormat(userEmail: String) -> Bool {
        let emailRegex = "^([a-zA-Z0-9._-])+@[a-zA-Z0-9.-]+.[a-zA-Z]{3,20}$"
        return userEmail.range(of: emailRegex, options: .regularExpression) != nil
    }
    
    // MARK: - checkUserEmailDuplicated 이메일 중복 체크
    /// true = 중복됨
    /// false = 중복 안됨
    func checkUserEmailDuplicatedService(userEmail: String) -> AnyPublisher<Bool, Error> {
        Future<Bool, Error> { promise in
            database.collection("UserList").whereField("userEmail", isEqualTo: "\(userEmail)").getDocuments() { snapshot, error in
                if let error = error {
                    print(error)
                    promise(.failure(AuthServiceError.emailDuplicated))
                } else {
                    if snapshot != nil {
                        promise(.failure(AuthServiceError.emailDuplicated))
                    } else {
                        promise(.success(false))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 이메일 로그인
    func authSignInService(userEmail: String, password: String) -> AnyPublisher<Firebase.User, Error> {
        Future<Firebase.User, Error> { promise in
            Auth.auth().signIn(withEmail: userEmail, password: password) { result, error in
                
                if let error = error {
                    print(error)
                    promise(.failure(AuthServiceError.signInError))
                } else {
                    if result != nil {
                        promise(.success(result!.user))
                    } else {
                        promise(.failure(AuthServiceError.signInError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 이메일 회원가입
    func authSignUpService(userEmail: String, password: String, confirmPassword: String) -> AnyPublisher<String, Error> {
        Future<String, Error> { promise in
            
            var userUID: String = ""
            
            
            let group = DispatchGroup()
            
            
            group.enter()
            if checkPasswordFormat(password: password, confirmPassword: confirmPassword) && checkAuthFormat(userEmail: userEmail) {
                Auth.auth().createUser(withEmail: userEmail, password: password) {  result, error in
                    
                    if let error = error {
                        print(error)
                        promise(.failure(AuthServiceError.signUpError))
                    } else {
                        if result != nil {
                            Auth.auth().signIn(withEmail: userEmail, password: password) { result, error in
                                
                                if let error = error {
                                    print(error)
                                    promise(.failure(AuthServiceError.signUpError))
                                } else {
                                    if result != nil {
                                        userUID = Auth.auth().currentUser!.uid
                                        group.leave()
                                        group.notify(queue: .main) {
                                            try? Auth.auth().signOut()
                                            promise(.success(userUID))
                                        }
                                    } else {
                                        promise(.failure(AuthServiceError.signUpError))
                                    }
                                }
                            }
                        } else {
                            promise(.failure(AuthServiceError.signUpError))
                        }
                    }
                    
                    
                }
            }
        }
        .eraseToAnyPublisher()
    }

}

