//
//  SettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// TODO: 목업으로 뷰 추가해놓기
struct SettingView: View {
    var body: some View {
        List{
            NavigationLink(destination: EmptyView()) {
                Text("공지사항")
            }
            NavigationLink(destination: EmptyView()) {
                Text("자주 묻는 질문")
            }
            NavigationLink(destination: EmptyView()) {
                Text("앱 정보")
            }
            NavigationLink(destination: EmptyView()) {
                Text("알림설정")
            }
        }
        .listStyle(.plain)
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}
