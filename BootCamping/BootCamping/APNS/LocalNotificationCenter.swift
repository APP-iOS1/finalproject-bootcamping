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
     enum UNAuthorizationStatus
     
     case notDetermined
     사용자는 앱이 알림을 예약하도록 허용할지 여부를 아직 선택하지 않았습니다.
     case denied
     앱이 알림을 예약하거나 받을 수 있는 권한이 없습니다.
     case authorized
     앱이 알림을 예약하거나 받을 수 있는 권한이 있습니다.
     case provisional
     응용 프로그램은 비방해 사용자 알림을 게시할 수 있는 임시 권한이 있습니다.
     case ephemeral
     앱은 제한된 시간 동안 알림을 예약하거나 수신할 수 있는 권한이 있습니다.
     */
    
    /*
     스케줄에 대한 알림 설정 시,
     현재 앱에 대한 알림 설정 권한 확인 후
     권한이 .notdetermined인 경우 권한 요청을 하고
     권한이 .authorized인 경우 푸시 알림 추가
     권한이 .notdetermined 또는 .authorized이 아닌 경우
     */
    
    func getCurrentSetting() async {

        // 현재의 인증현황을 확인하고
        let currentSetting = await notificationCenter.notificationSettings()

        // isGranted 프로퍼티에 현재 인증상태 값을 할당함 (거절을 눌렀다면 false, 동의를 눌렀으면 true로 변환되는걸 볼 수 있음)
        isSettingAppPN = (currentSetting.authorizationStatus == .authorized)
        isSettingSchedulePN = isSettingAppPN
    }

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
