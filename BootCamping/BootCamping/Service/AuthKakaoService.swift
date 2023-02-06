//
//  AuthKakaoService.swift
//  BootCamping
//
//  Created by 박성민 on 2023/02/06.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser
import Firebase
import FirebaseCore
import FirebaseFirestore


struct AuthKakaoService {
    
    // MARK: - 카카오 로그아웃
    
    func kakaoLogOutService() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            UserApi.shared.logout {(error) in
                if let error = error {
                    print("로그아웃 에러 : \(error)")
                    promise(.failure(AuthServiceError.signOutError))
                }
                else {
                    print("logout() success.")
                    promise(.success(()))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - 카카오 로그인
    
    func kakaoLogInService() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            // 카카오 설치 되어있을때
            if (UserApi.isKakaoTalkLoginAvailable()) {
                
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        print(error)
                        promise(.failure(AuthServiceError.signInError))
                    } else {
                        print("kakaoLogin success")
                        _ = oauthToken
                        promise(.success(()))
                    }
                }
            } else {
                // 카카오 설치 안되어있을때
                UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                    if let error = error {
                        print("에러: \(error)")
                        promise(.failure(AuthServiceError.signInError))
                    }
                    else {
                        print("loginWithKakaoAccount() success.")
                        _ = oauthToken
                        promise(.success(()))

                    }
                    
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
}
