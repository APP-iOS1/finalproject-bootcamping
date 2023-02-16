//
//  BootCampingApp.swift
//  BootCamping
//
//  Created by Donghoon Bae on 2023/01/18.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import KakaoSDKCommon
import KakaoSDKAuth

//TODO: -구글, 카카오 로그인 연동 완료하기

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()

        /* It sets how much Firebase will log. Setting this to min reduces the amount of data you’ll see in your debugger. */
        FirebaseConfiguration.shared.setLoggerLevel(.min)
    
        return true
    }
    
    
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any])
    -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
        
    }
    
    func application(_ app: UIApplication, open url: URL, option: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if (AuthApi.isKakaoTalkLoginUrl(url)) {
            return AuthController.handleOpenUrl(url: url)
        }
        
        return false
        
    }
}

@main
struct BootCampingApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    init() {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_NATIVE_APP_KEY"] ?? ""
        // Kakao SDK 초기화
        KakaoSDK.initSDK(appKey: kakaoAppKey as! String)
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(TabSelector())
                .environmentObject(DiaryStore())
                .environmentObject(ScheduleStore())
                .environmentObject(FaceId())
                .environmentObject(BookmarkStore())
                .environmentObject(AuthStore())
                .environmentObject(CommentStore())
                .environmentObject(DiaryLikeStore())
                .environmentObject(BlockedUserStore())
                .environmentObject(LocalNotificationCenter())
                .environmentObject(ReportStore())
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
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

// MARK: - 앱 시작 시 APN과 통신
extension AppDelegate {
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken
                     deviceToken: Data) {
        print(#function, "+++ didRegister Success", deviceToken)
        
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError
                     error: Error) {
        print(#function, "DEBUG: +++ register error: \(error.localizedDescription)")
        // Try again later.
    }
}
