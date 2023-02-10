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
    
    // 알림 설정 권한 확인을 위한 변수
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var notificationRequests: [UNNotificationRequest] = []
    
    override init() {
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
     권한이 .notDetermined인 경우 권한 요청을 하고
     권한이 .authorized인 경우 푸시 알림 추가
     권한이 .notdetermined 또는 .authorized이 아닌 경우 알림 추가 못 함~
     */
    
    // MARK: - getCurrentSetting 현재 앱에 대한 알림 설정 권한을 업데이트한다
    func getCurrentSetting() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
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
    @MainActor
    func setNotification(startDate: Date) async {
        self.getCurrentSetting()
        
        if authorizationStatus == UNAuthorizationStatus.notDetermined {
            notificationCenter.requestAuthorization(
                options: [.alert,.sound,.badge], completionHandler: { didAllow, Error in
                    print(didAllow) //
                })
        }
        if authorizationStatus == UNAuthorizationStatus.authorized{
            let content = UNMutableNotificationContent()
            content.badge = 1
            content.title = "헐랭방구"
            content.body = "수료 일주일 남음"
            content.userInfo = ["name" : "민콩"]
            
            let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            //                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "CampingSchedule", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("set Notification Error \(error)")
                }
            }
        }
    }
}
