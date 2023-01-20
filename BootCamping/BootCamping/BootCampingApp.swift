//
//  BootCampingApp.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI
import FirebaseCore
import KakaoSDKCommon
import KakaoSDKAuth


class AppDelegate: NSObject, UIApplicationDelegate/*, UIResponder */{
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        return true
    }
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
    }
}

@main
struct BootCampingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("login") var isSignIn: Bool = false
    
    init() {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
            // Kakao SDK 초기화
            KakaoSDK.initSDK(appKey: kakaoAppKey as! String)

        }
    
    var body: some Scene {
        WindowGroup {
            if isSignIn {
            ContentView()
                .environmentObject(AuthStore())
                .environmentObject(DiaryStore())
//                kakaoLoginViewTEST()
            } else {
                
                ContentView()
                    .environmentObject(AuthStore())
                    .environmentObject(DiaryStore())
//                LoginView(isSignIn: $isSignIn)
//                    .environmentObject(AuthStore())
//                kakaoLoginViewTEST()

            }
            // onOpenURL()을 사용해 커스텀 URL 스킴 처리
//            ContentView().onOpenURL(perform: { url in
//                if (AuthApi.isKakaoTalkLoginUrl(url)) {
//                    AuthController.handleOpenUrl(url: url)
//                }
//            })
            
        }
    }
}
