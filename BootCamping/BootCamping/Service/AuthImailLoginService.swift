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

enum AuthImailLoginServiceError: Error {
    case emailDuplicated
    case signInError
    case signUpError
    
    var errorDescription: String? {
        switch self {
        case .emailDuplicated:
            return "중복된 이메일 입니다."
        case .signInError:
            return "로그인에 실패하였습니다."
        case .signUpError:
            return "회원가입에 실패하였습니다."
        }
    }
}

struct AuthImailLoginService {
    
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
                    promise(.failure(AuthImailLoginServiceError.emailDuplicated))
                } else {
                    if snapshot != nil {
                        promise(.failure(AuthImailLoginServiceError.emailDuplicated))
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
                    promise(.failure(AuthImailLoginServiceError.signInError))
                } else {
                    if result != nil {
                        promise(.success(result!.user))
                    } else {
                        promise(.failure(AuthImailLoginServiceError.signInError))
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 이메일 회원가입
    func authSignUpService(userEmail: String, password: String, confirmPassword: String) -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            if checkPasswordFormat(password: password, confirmPassword: confirmPassword) && checkAuthFormat(userEmail: userEmail) {
                Auth.auth().createUser(withEmail: userEmail, password: password) {  result, error in
                    
                    if let error = error {
                        print(error)
                        promise(.failure(AuthImailLoginServiceError.signUpError))
                    } else {
                        if result != nil {
                            promise(.success(()))
                        } else {
                            promise(.failure(AuthImailLoginServiceError.signUpError))
                        }
                    }
                    
                }
            }
        }
        .eraseToAnyPublisher()
    }

}

