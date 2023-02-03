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
import Firebase
import FirebaseCore
import FirebaseFirestore

class KakaoAuthStore: ObservableObject {
    
    @Published var userInfo: User = User(id: UUID().uuidString, profileImageName: "", profileImageURL: "", nickName: "", userEmail: "", bookMarkedDiaries: [], bookMarkedSpot: [])
    // 로그인 상태 저장
    @Published var currentUser: Firebase.User?
    
    init() {
        currentUser = Auth.auth().currentUser
    }
    
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
                    self.signUpInFirebase()
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
                    self.signUpInFirebase()
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
    
    // MARK: - 카카오톡 계정 파이어베이스 auth에 추가
    func signUpInFirebase() {
        UserApi.shared.me() { user, error in
            if let error = error {
                print("카카오톡 사용자 정보 가져오기 에러: \(error.localizedDescription)")
            } else {
                // 파이어베이스 유저 생성
                Auth.auth().createUser(withEmail: ("\(String(describing: user?.kakaoAccount?.profile?.nickname ?? "" ))@kakao.com"), password: "\(String(describing: user?.id))") { result, error in
                    print("email: \(String(describing: user?.kakaoAccount?.profile?.nickname))@kakao.com")
                    
                    print("userid: \(String(describing: user?.id))")
                    
                    
                    if let error = error {
                        print("파이어베이스 사용자 생성 실패: \(error.localizedDescription)")
                        print("파이어베이스 로그인 시작")
                        Auth.auth().signIn(withEmail: ("\(String(describing: user?.kakaoAccount?.profile?.nickname ?? ""))@kakao.com"), password: "\(String(describing: user?.id))") { result, error in
                            if let error = error {
                                print("로그인 에러: \(error.localizedDescription)")
                                return
                            } else {
                                self.currentUser = result?.user
                            }
                            
                        }
                       
                    } else {
                        print("파이어베이스 사용자 생성 성공")
                    }
                    
                }
                self.userInfo.userEmail = "\(String(describing: user?.kakaoAccount?.profile?.nickname ?? ""))@kakao.com"
                self.userInfo.nickName = user?.kakaoAccount?.profile?.nickname ?? ""
                self.userInfo.profileImageURL = user?.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? ""
            }
        }
    }
    
    // 로그인후 유저 정보 입력
    func inputUserInfo() {
        UserApi.shared.me() { user, error in
            if let error = error {
                print("유저 정보 에러 :\(error)")
            } else {
                self.userInfo.userEmail = "\(String(describing: user?.kakaoAccount?.profile?.nickname ?? ""))@kakao.com"
                self.userInfo.nickName = user?.kakaoAccount?.profile?.nickname ?? ""
                self.userInfo.profileImageURL = user?.kakaoAccount?.profile?.profileImageUrl?.absoluteString ?? ""
            }
            
        }
    }
}
