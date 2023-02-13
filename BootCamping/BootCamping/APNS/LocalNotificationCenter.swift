//
//  LocalNotificationCenter.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/08.
//

import SwiftUI

class LocalNotificationCenter: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    let localNotifications = [
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-DAY", body: "오늘 캠핑을 통해 얻은 좋은 추억들을 부트캠핑에 캠핑 일기로 남겨 기록해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-1", body: "캠핑 떠나기 1일 전, 빠뜨린 짐은 없는지 다시 한 번 확인해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-2", body: "캠핑 떠나기 2일 전, 이번 주 날씨를 확인해서 짐을 챙겨보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-3", body: "캠핑 떠나기 3일 전, 가시는 길을 다시 한 번 부트캠핑에서 확인해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-4", body: "캠핑 떠나기 4일 전, 부트캠핑에서 편의시설 및 서비스를 다시 한 번 확인해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-5", body: "캠핑 떠나기 5일 전, 부트캠핑에서 주변 이용 가능 시설까지 체크해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-6", body: "캠핑 떠나기 6일 전, 부트캠핑에서 다른 사람의 캠핑 일기를 보고 캠핑을 준비해보세요"),
            LocalNotification(title: "부트캠핑과 함께 떠나는 캠핑 D-7", body: "캠핑 떠나기 일주일 전, 부트캠핑에서 캠핑 일정을 다시 한 번 확인해보세요")
        ]
    
    // 알림 설정을 위한 인스턴스 선언
    let notificationCenter = UNUserNotificationCenter.current()
    
    // 알림 설정 권한 확인을 위한 변수
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    // 설정된 푸시 알림을 갖고 있는 배열
    @Published var notificationRequests: [UNNotificationRequest] = []
    // 푸시 알림을 통해 앱 진입 시 화면 이동(마이페이지 탭으로 이동)을 위한 변수
    @Published var pageToNavigationTo : TabViewScreen?
    
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
     */
    
    // MARK: - getCurrentSetting 현재 앱에 대한 알림 설정 권한을 업데이트한다
    func getCurrentSetting() {
        notificationCenter.getNotificationSettings { settings in
            DispatchQueue.main.async { [weak self] in
                self?.authorizationStatus = settings.authorizationStatus
            }
        }
    }
    
    // MARK: - 앱 설정 페이지를 열어 보여준다
    @MainActor
    func openAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        }
        self.getCurrentSetting()
    }
    

    // MARK: - 알람 처리 메소드 구현
    /** Handle notification when the app is in foreground */
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        /* 앱이 포그라운드에서 실행될 때 도착한 알람 처리 */
        let userInfo = notification.request.content.userInfo
        
        print(#function, "+++ willPresent: userInfo: ", userInfo)
        
        completionHandler([.banner, .list, .sound, .badge])
    }
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let identifier = response.notification.request.identifier
        
        // 알림을 통해 앱을 진입하면 뱃지 숫자를 0으로 바꿔준다
        UIApplication.shared.applicationIconBadgeNumber = 0
        // 알림을 통해 앱을 진입하면 네 번째 탭(마이페이지 탭)으로 바로 화면 전환하기 위해 할당
        self.pageToNavigationTo = TabViewScreen.four
        // 알림에 해당하는 identifier를 가진 알림이 남아 있으면 삭제해준다.
        notificationCenter.removeDeliveredNotifications(withIdentifiers: [identifier])
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])

        
        print("Check Notification")
        completionHandler()
    }
    
//    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
    
    // MARK: - requestAuthorization
    /// 앱의 알림 설정에 필요한 권한을 요청한다
    func requestAuthorization() async throws  {
        try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
           if success {
               print("User Accepted")
           } else if let error = error {
               print(error.localizedDescription)
          }
        }
        await getCurrentSetting()
    }
    
    // MARK: - getPendingNotificationRequests
    /// 보류 중인 알림 대기열의 정보를 얻을 수 있음
    /// 생성된 노티피케이션은 보류중인 상태이며 pending 관련 메서드를 통해 보류중인 노티피케이션을 해제해줘야 될 것 같습니다.
    func getPendingNotificationRequests(completionHandler: ([UNNotificationRequest]) -> Void) {}
    
    // MARK: - addNotification(startDate: Date)
    /// 캠핑 출발일을 기준으로 일주일 전부터 출발 당일까지 하루에 한 개씩 알림을 설정한다
    func addNotification(startDate: Date) async throws{
    
        if authorizationStatus == UNAuthorizationStatus.notDetermined {
            try await self.requestAuthorization()
        }
        if authorizationStatus == UNAuthorizationStatus.authorized{
            for index in localNotifications.indices {
                let calendar = Calendar.current
                
                if (calendar.date(byAdding: .day, value: index, to: startDate) ?? Date()) > startDate { continue }
                
                let content = UNMutableNotificationContent()
                content.badge = 1
                content.title = localNotifications[index].title
                content.body = localNotifications[index].body
                print(content)
                
                var dateComponents = calendar.dateComponents([.year, .month, .day], from: calendar.date(byAdding: .day, value: index, to: startDate) ?? Date())
                // 시간은 오후 12시에~
                dateComponents.hour = 12
                dateComponents.minute = 0
                
                print(dateComponents)

                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                
                let request = UNNotificationRequest(identifier: "\(startDate)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request) { error in
                    if let error = error {
                        print("set Notification Error \(error)")
                    }
                }
            }
        }
    }
}


// FIXME: - 테스트를 위해 남겨놓은 5초 뒤 푸시 알림 설정 함수 **나중에 없애야 함
extension LocalNotificationCenter{
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
                content.title = "부트캠핑"
                content.body = "출시 언제 하지.."
                content.userInfo = ["name" : "부트캠퍼 민콩"]
                
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
