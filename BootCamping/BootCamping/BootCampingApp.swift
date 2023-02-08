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
import FirebaseMessaging
import FirebaseAnalytics
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
        
        /* Push Notification 대리자 설정 */
        Messaging.messaging().delegate = self
        
        // 원격 알림 등록
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
            
//            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//
//            UNUserNotificationCenter.current().requestAuthorization(
//                options: authOptions,
//                completionHandler: { _, _ in }
//            )
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        /* 앱이 실행중일 때의 Push Notification 대리자 설정 */
        UNUserNotificationCenter.current().delegate = self
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
                .environmentObject(WholeAuthStore())
                .environmentObject(CommentStore())
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

// MARK: - FCM 메시지 및 토큰 관리
extension AppDelegate: MessagingDelegate {
    /* 메시지 토큰 등록 완료 */
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(#function, "+++ didRegister Success", deviceToken)
        // Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    /* 메시지 토큰 등록 실패 */
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(#function, "DEBUG: +++ register error: \(error.localizedDescription)")
    }
    
    func messaging(_ messaging: Messaging,
                   didReceiveRegistrationToken fcmToken: String?) {
        print(#function, "Messaging")
        let deviceToken: [String: String] = ["token" : fcmToken ?? ""]
        print(#function, "+++ Device Test Token", deviceToken)
    }
    
    // TODO: - 추후 didReceive 메소드를 추가로 구현하여 Push Notification을 탭했을 때의 액션을 추가
}

// MARK: - 알람 처리 메소드 구현
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /* 앱이 포어그라운드에서 실행될 때 도착한 알람 처리 */
        let userInfo = notification.request.content.userInfo
        
        print(#function, "+++ willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .sound, .badge])
    }
    
    /* 전달 알림에 대한 사용자 응답을 처리하도록 대리인에 요청 */
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(#function, "+++ didReceive: userInfo: ", userInfo)
        completionHandler()
    }
}
