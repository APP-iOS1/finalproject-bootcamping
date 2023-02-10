//
//  NotificationSettingsView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/02/10.
//

import SwiftUI

struct NotificationSettingsView: View {
    
    @EnvironmentObject var localNotificationCenter: LocalNotificationCenter
    
    @State private var isSettingSchedulePN: Bool = false
    @State private var isSettingAppPN: Bool = false
    
    var body: some View {
        List{
            Section {
                schedulePushNotification
                appPushNotification
            }
        }
        .listStyle(.plain)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar{
            ToolbarItem(placement: .principal) {
                Text("알림 설정")
            }
        }
        .task{
        }
    }
}

extension NotificationSettingsView {
    private var schedulePushNotification: some View{
        HStack{
            Toggle(isOn: $isSettingSchedulePN) {
                VStack(alignment: .leading) {
                    Text("스케줄 Push 알림")
                    Text("추가한 캠핑 일정에 대한 알림")
                    Text("*기기의 Push 설정이 필요합니다")
                }
            }
        }
    }
    private var appPushNotification: some View{
        HStack{
            Toggle(isOn: $isSettingAppPN){
                VStack(alignment: .leading) {
                    Text("앱 전체에 대한 Push 알림")
                    Text("앱에서 보내는 푸시 알림")
                    Text("*기기의 Push 설정이 필요합니다")
                }
            }
        }
    }
}

struct NotificationSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationSettingsView()
    }
}
