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
                Text("내 정보 관리")
            }
            NavigationLink(destination: EmptyView()) {
                Text("서비스 이용 약관")
            }
            NavigationLink(destination: EmptyView()) {
                Text("개인정보 처리방침")
            }
            NavigationLink(destination: EmptyView()) {
                Text("라이선스")
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
