//
//  NotificationCenter.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/08.
//

import SwiftUI

class LocalNotification: ObservableObject {
    
    // MARK: - setNotification
    /// 시뮬레이터에서는 확인이 안 됨에 주의해주세요!
    /// 실 기기로 테스트 하는 경우에만 푸시 알림 확인이 가능합니다
    func setNotification(startDate: Date) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == UNAuthorizationStatus.notDetermined {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert,.sound,.badge], completionHandler: { didAllow, Error in
                        print(didAllow) //
                    })
            }
            if settings.authorizationStatus == UNAuthorizationStatus.authorized{
                let content = UNMutableNotificationContent()
                content.badge = 1
                content.title = "에휴"
                content.body = "왜 안 되는데.."
                content.userInfo = ["name" : "민콩"]
                
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: startDate)
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "민콩noti", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("set Notification Error \(error)")
                    }
                }
            }
        }
    }
}
