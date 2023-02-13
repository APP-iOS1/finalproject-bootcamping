//
//  NotificationSettingsView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/10.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @EnvironmentObject var localNotificationCenter: LocalNotificationCenter
    
    // 스케줄에 대한 알림 설정 부울값
    @State private var isSettingSchedulePN: Bool = false
    // 앱 전체 푸시 알림 설정 부울값
    @State private var isSettingAppPN: Bool = false
    // 푸시 알림 설정을 위한 얼럿 띄우는 부울값
    @State private var isShowingAlertForPN: Bool = false
    // 첫 번째로 실행되는 onChange 내부 액션들을 무시하기 위한 부울값
    @State private var isFirstEntry: Bool = true
    
    var body: some View {
        List{
            Section {
                schedulePushNotification
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("알림 설정")
            }
        }
        //MARK: - PUSH 알림 설정을 위한 alert
        /// PUSH 알림 설정은 처음 설정 이후 코드로 변경이 불가능해서 사용자가 직접 변경이 가능하도록 얼럿으로 고지한다.
        .alert("PUSH 알림 설정을 '설정 > 알림 > 부트캠핑 > 알림허용'에서 변경해주세요", isPresented: $isShowingAlertForPN) {
            Button("닫기", role: .cancel) {
                isShowingAlertForPN = false
            }
            Button("설정") {
                localNotificationCenter.openAppSetting()
            }
        }
        .task {
            isSettingSchedulePN = (localNotificationCenter.authorizationStatus == .authorized)
        }
    }
}

extension NotificationSettingsView {
    private var schedulePushNotification: some View{
        HStack{
            Toggle(isOn: $isSettingSchedulePN) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("내 캠핑 일정에 대한 Push 알림")
                        .bold()
                    Text("추가한 캠핑 일정에 대한 알림\n*기기의 Push 설정이 필요합니다.")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }
            .tint(Color.accentColor)
            .onChange(of: isSettingSchedulePN) { _ in
                if !isFirstEntry { isShowingAlertForPN = true}
                isFirstEntry = false
            }
        }
    }
    private var appPushNotification: some View{
        HStack{
            Toggle(isOn: $isSettingAppPN){
                VStack(alignment: .leading, spacing: 10) {
                    Text("앱 전체에 대한 Push 알림")
                        .bold()
                    Text("공지사항, 이벤트, 추천 소식 알림\n*기기의 Push 설정이 필요합니다.")
                        .font(.caption)
                        .multilineTextAlignment(.leading)
                }
            }
            .tint(Color.accentColor)
        }
    }
}
