//
//  LocalNotificationCenter.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/08.
//

import SwiftUI

class LocalNotificationCenter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    // 알림 설정을 위한 인스턴스 선언
    let notificationCenter = UNUserNotificationCenter.current()
    
    @Published var isGranted: Bool = false
    
    @Published var isSettingSchedulePN: Bool = false
    @Published var isSettingAppPN: Bool = false
    
    @Published var notificationRequests: [UNNotificationRequest] = []
    
    override init () {
        super.init()
        notificationCenter.delegate = self
    }
    
    /*
     스케줄에 대한 알림 설정 시,
     현재 앱에 대한 알림 설정 권한 확인 후
     권한이 .notdetermined인 경우 권한 요청을 하고
     권한이 .not
     */
    
    func openAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    
    
    
    // MARK: - 알람 처리 메소드 구현
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /* 앱이 포어그라운드에서 실행될 때 도착한 알람 처리 */
        let userInfo = notification.request.content.userInfo
        
        print(#function, "+++ willPresent: userInfo: ", userInfo)
        
//        completionHandler([.banner, .sound, .badge])
        completionHandler([.banner, .list, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print(#function, "+++ didReceive: userInfo: ", userInfo)
        
        let identifier = response.notification.request.identifier
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
        print("Check Notification")
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
    
    
    // MARK: - setNotification
    /// 시뮬레이터에서는 확인이 안 됨에 주의해주세요!
    /// 실 기기로 테스트 하는 경우에만 푸시 알림 확인이 가능합니다
//    func setNotification(startDate: Date) {
//        UNUserNotificationCenter.current().getNotificationSettings { settings in
//            if settings.authorizationStatus == UNAuthorizationStatus.notDetermined {
//                UNUserNotificationCenter.current().requestAuthorization(
//                    options: [.alert,.sound,.badge], completionHandler: { didAllow, Error in
//                        print(didAllow) //
//                    })
//            }
//            if settings.authorizationStatus == UNAuthorizationStatus.authorized{
//                let content = UNMutableNotificationContent()
//                content.badge = 1
//                content.title = "에휴"
//                content.body = "왜 안 되는데.."
//                content.userInfo = ["name" : "민콩"]
//                
//                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
//                
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
////                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
//                
//                let request = UNNotificationRequest(identifier: "민콩noti", content: content, trigger: trigger)
//                UNUserNotificationCenter.current().add(request) { error in
//                    if let error = error {
//                        print("set Notification Error \(error)")
//                    }
//                }
//            }
//        }
//    }
}
