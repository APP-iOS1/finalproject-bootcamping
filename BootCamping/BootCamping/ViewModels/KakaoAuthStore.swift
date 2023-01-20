//
//  KakaoAuthStore.swift
//  BootCamping
//
//  Created by 차소민 on 2023/01/20.
//

import Foundation
import Combine
import KakaoSDKAuth
import KakaoSDKUser

class KakaoAuthStore: ObservableObject {
    
    @Published var isLoggedIn: Bool = false
    
    @MainActor
    func kakaoLogout(){
        Task{
            if await handleKakaoLogout() {
                isLoggedIn = false
            }
        }
    }
    

    
    func handleKakaoLogout() async -> Bool {
        await withCheckedContinuation{ continueation in
            
            UserApi.shared.logout {(error) in
                if let error = error {
                    print("로그아웃 에러 : \(error)")
                    continueation.resume(returning: false)
                }
                else {
                    print("logout() success.")
                    continueation.resume(returning: true)
                }
            }
        }
    }

    
    // 카카오 앱을 통해 로그인
    func handleLoginWithKakaoApp() async -> Bool {
        await withCheckedContinuation{ continuation in
            UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                if let error = error {
                    print(error)
                    continuation.resume(returning: false)
                }
                else {
                    print("loginWithKakaoTalk() success.")
                    //do something
                    _ = oauthToken
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    // 카카오 웹뷰를 열어서 로그인
    func handleLoginWithKakaoWeb() async -> Bool{
        
        await withCheckedContinuation{ continuation in
            
            UserApi.shared.loginWithKakaoAccount {(oauthToken, error) in
                if let error = error {
                    print("에러: \(error)")
                    continuation.resume(returning: false)
                    
                }
                else {
                    print("loginWithKakaoAccount() success.")
                    
                    //do something
                    _ = oauthToken
                    continuation.resume(returning: true)
                    
                }
            }
            
        }
    }
    
    @MainActor
    func handleKakaoLogin() {
        Task{
            // 카카오톡 실행 가능 여부 확인 - 설치 되어있을때
            if (UserApi.isKakaoTalkLoginAvailable()) {
                isLoggedIn = await handleLoginWithKakaoApp()
            } else { // 설치 안되어있을때
                isLoggedIn = await handleLoginWithKakaoWeb()
            }
        }
        
    }
}
