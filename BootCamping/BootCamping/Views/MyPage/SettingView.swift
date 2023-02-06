//
//  SettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// TODO: 목업으로 뷰 추가해놓기
struct SettingView: View {
    @EnvironmentObject var authStore: AuthStore
    @EnvironmentObject var kakaoAuthStore: KakaoAuthStore
    
    //로그아웃 시 탭 변경하기 위한 변수
    @EnvironmentObject var tabSelection: TabSelector
    //로그아웃시 isSignIn을 false로 변경
    @AppStorage("login") var isSignIn: Bool?
    
    var body: some View {
        List{
            NavigationLink(destination: CampingSpotView().environmentObject(CampingSpotStore())) {
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
            NavigationLink(destination: EmptyView()) {
                Text("보안설정") //페이스아이디
            }
            Button {
                authStore.googleSignOut()
                authStore.authSignOut()
                kakaoAuthStore.kakaoLogout()
                isSignIn = false
                tabSelection.change(to: .one)
            } label: {
                Text("로그아웃")
            }
            Button {
                // TODO: 회원 탈퇴
                /// 얼럿 띄우고 탈퇴하는 뷰에 연결하기
            } label: {
                Text("회원 탈퇴")
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
