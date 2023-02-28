//
//  SettingView.swift
//  BootCamping
//
//  Created by 이민경 on 2023/01/18.
//

import SwiftUI

// MARK: - View: SettingView
/// 설정 뷰(마이프로필 - 설정)
struct SettingView: View {
    @EnvironmentObject var wholeAuthStore: WholeAuthStore
    
    //로그아웃 시 탭 변경하기 위한 변수
    @EnvironmentObject var tabSelection: TabSelector
    //로그아웃시 isSignIn을 false로 변경
    //로그아웃 알럿
    @State var showingAlertLogOut: Bool = false
    @AppStorage("login") var isSignIn: Bool?
    //보안설정 들어갈때 페이스id 사용
    @EnvironmentObject var faceId: FaceId
    @AppStorage("faceId") var usingFaceId: Bool?
    
    var body: some View {
        List{
            NavigationLink(destination: AnnouncementView()) {
                Text("공지사항")
            }
            NavigationLink(destination: ContactUsView()) {
                Text("자주 묻는 질문 FAQ")
            }
            Link("앱 정보", destination: URL(string: "https://thekoon0456.notion.site/thekoon0456/BootCamping-5e0a340949c24aec8c76913a84407c52")!)
            NavigationLink(destination: NotificationSettingsView()) {
                Text("알림설정")
            }
            NavigationLink(destination: PrivacyView()) {
                Text("개인/보안설정") //페이스아이디, 비밀번호 수정, 회원탈퇴
            }
            NavigationLink(destination: BusinessView()) {
                Text("비즈니스 문의")
            }
            
            Button {
                showingAlertLogOut.toggle()
            } label: {
                Text("로그아웃")
            }
            .alert(isPresented: $showingAlertLogOut) {
                Alert(title: Text("로그아웃하시겠습니까?"),
                      primaryButton: .default(Text("취소"), action: {} ),
                      secondaryButton: .destructive(Text("로그아웃"),action: {
                    tabSelection.screen = .one
                    wholeAuthStore.combineLogOut()
                })
                )
            }
        }
        .listStyle(.plain)
        .alert("로그아웃에 실패하였습니다. 다시 시도해 주세요.", isPresented: $wholeAuthStore.isError) {
            Button("확인", role: .cancel) {
                wholeAuthStore.isError = false
            }
        }
        
    }
}
